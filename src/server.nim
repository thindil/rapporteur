# Copyright © 2024 Bartek Jasicki
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Provides simpel CGI program to receive errors' reports from clients,
## authenticate them and write in the selected directory. For more information
## about setting the server, please loot at the project's documentation.

import std/[cgi, envvars, files, hashes, os, parsecfg, paths, strtabs, strutils, streams]
import contracts

proc main() {.raises: [], tags: [ReadEnvEffect, WriteIOEffect, ReadDirEffect, ReadIOEffect,
    RootEffect], contractual.} =
  ## The main procedure of the server

  type AnswerString = string

  proc answer(message: AnswerString) {.raises: [], tags: [WriteIOEffect], contractual.} =
    ## Print the message into standard output to send it to the client
    ##
    ## * message - the message to print
    require:
      message.len > 0
    body:
      try:
        stdout.write(s = message & "\n")
      except IOError:
        discard

  # Test data
  when defined(debug):
    try:
      setTestData(keysvalues = ["key", "wertr45", "hash", "somehash", "content", "can't show error"])
    except OSError:
      answer(message = "Status: 500 Invalid test data")
      quit QuitFailure

  # Read the server's configuration
  let configFile = getEnv(key = "RAPPORT_CONFIG")
  var fileStream = configFile.newFileStream(mode = fmRead)
  if fileStream == nil:
    answer(message = "Status: 500 No server configuration")
    quit QuitFailure
  var config: CfgParser
  try:
    config.open(input = fileStream, filename = configFile)
  except IOError, Exception:
    answer(message = "Status: 500 Invalid config file")
    quit QuitFailure
  var
    keys: seq[string]
    dataDir: Path
  while true:
    var entry = try:
        config.next
      except ValueError, OSError, IOError:
        answer(message = "Status: 500 Invalid config value")
        quit QuitFailure
    case entry.kind
    of cfgEof:
      break
    of cfgKeyValuePair, cfgOption:
      case entry.key
      of "keys":
        keys = entry.value.split(sep = ';')
      of "datadir":
        dataDir = entry.value.Path
    of cfgError:
      answer(message = "Status: 500 " & entry.msg)
      quit QuitFailure
    else:
      discard
  try:
    config.close
  except OSError, IOError:
    answer(message = "Status: 500 Invalid config file")
  if keys.len == 0 or dataDir.string.len == 0:
    answer(message = "Status: 500 Server not configured")
    quit QuitFailure

  # Read the request data
  let request = try:
      readData()
    except ValueError, IOError:
      answer(message = "Status: 400 Invalid data sent")
      quit QuitFailure
  for key in ["key", "hash", "content"]:
    if key notin request:
      answer(message = "Status: 400 No " & key & " sent.")
      quit QuitFailure
  try:
    if request["key"] notin keys:
      answer(message = "Status: 401 Unauthorized")
      quit QuitFailure
  except KeyError:
    answer(message = "Status: 500 Can't check the key")
    quit QuitFailure

  # Check if the same report exist
  let
    newHash = try:
        hash(x = request["key"] & request["hash"])
      except KeyError:
        answer(message = "Status: 500 Invalid key")
        quit QuitFailure
    reportFile = dataDir.string & DirSep & $newHash & ".txt"
  if fileExists(filename = reportFile.Path):
    answer(message = "Status: 208 Report exists")
    quit QuitSuccess

  # Create a new report file and save it in the data directory
  let report = try:
      reportFile.open(mode = fmWrite)
    except IOError:
      answer(message = "Status: 500 Can't create report")
      quit QuitFailure
  try:
    report.writeLine(x = "KEY: " & request["key"])
    report.writeLine(x = request["content"])
  except KeyError, IOError:
    answer(message = "Status: 500 Invalid key")
    quit QuitFailure
  finally:
    report.close

  answer(message = "Status: 201 Created")

when isMainModule:
  main()

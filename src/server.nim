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

import std/[cgi, envvars, files, hashes, os, parsecfg, paths, strtabs, strutils, streams]

proc main() {.tags: [ReadEnvEffect, WriteIOEffect, ReadDirEffect, ReadIOEffect,
    RootEffect].} =
  # Test data
  when defined(debug):
    setTestData("key", "wertr45", "hash", "somehash", "content", "can't show error")

  # Read the server's configuration
  let configFile = getEnv("RAPPORT_CONFIG")
  var fileStream = configFile.newFileStream(fmRead)
  if fileStream == nil:
    stdout.write("Status: 500 No server configuration\n")
    quit QuitFailure
  var config: CfgParser
  config.open(fileStream, configFile)
  var
    keys: seq[string]
    dataDir: Path
  while true:
    var entry = try:
        config.next
      except ValueError, OSError, IOError:
        stdout.write("Status: 500 Invalid config value\n")
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
      stdout.write("Status: 500 " & entry.msg & "\n")
      quit QuitFailure
    else:
      discard
  config.close
  if keys.len == 0 or dataDir.string.len == 0:
    stdout.write("Status: 500 Server not configured\n")
    quit QuitFailure

  # Read the request data
  let request = readData()
  for key in ["key", "hash", "content"]:
    if key notin request:
      stdout.write("Status: 400 No " & key & " sent.\n")
      quit QuitFailure

  # Check if the same report exist
  let
    newHash = hash(x = request["key"] & request["hash"])
    reportFile = dataDir.string & DirSep & $newHash & ".txt"
  if fileExists(reportFile.Path):
    stdout.write("Status: 208 Report exists\n")
    quit QuitSuccess

  # Create a new report file and save it in the data directory
  let report = reportFile.open(mode = fmWrite)
  report.writeLine("KEY: " & request["key"])
  report.writeLine(request["content"])
  report.close

  stdout.write("Status: 201 Created\n")

when isMainModule:
  main()

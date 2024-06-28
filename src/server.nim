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

import std/[cgi, envvars, parsecfg, strtabs, streams]

# Test data
when defined(debug):
  setTestData("key", "wertr45", "hash", "somehash", "content", "can't show error")

let configFile = getEnv("RAPPORT_CONFIG")

# Read the server's configuration
var fileStream = configFile.newFileStream(fmRead)
if fileStream == nil:
  stdout.write("Status: 500 Server not configured.\n")
  quit QuitFailure
var config: CfgParser
config.open(fileStream, configFile)
while true:
  var entry = config.next
  case entry.kind
  of cfgEof:
    break
  of cfgKeyValuePair, cfgOption:
    echo "key-value-pair: " & entry.key & ": " & entry.value
  of cfgError:
    stdout.write("Status: 500 " & entry.msg & ".\n")
    quit QuitFailure
  else:
    discard
config.close

let request = readData()
for key in ["key", "hash", "content"]:
  if key notin request:
    stdout.write("Status: 400 No " & key & " sent.\n")
    quit QuitFailure
stdout.write("Status: 200 OK\n")

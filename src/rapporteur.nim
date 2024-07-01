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

## Provides API to send reports from an application to the project's server.
## Usually, before sending a report, the library requires initialization with
## procedure `initRapport`:
##
##     initRapport(httpAddress = 'https://mysite.com', key = "myAppKey")
##
## Setting key to **DEADBEEF** value will disable sending reports.
##
## To send a report to a server, use procedure `sendRapport`:
##
##     sendRapport(content = "My message here")

import std/[hashes, httpclient, uri]
import contracts

type
  RapportError* = object of CatchableError
    ## Raised when there is a problem with the project, like not initialized,
    ## etc.
  RapportKey* = string
    ## Used to store the application key
  RapportContent* = string
    ## Used to store a report's content

var
  serverAddress: Uri = parseUri(uri = "")
  appKey: RapportKey = ""

proc initRapport*(httpAddress: Uri; key: RapportKey) {.raises: [RapportError],
    tags: [], contractual.} =
  ## Initialize the library. Sets its configuration.
  ##
  ## * httpAddress - the HTTP address to which a server to which a report will
  ##                 be send. Must be a valid address.
  ## * key         - the application key used in the server authentication. Must
  ##                 be the same as on the server. Setting it to `DEADBEEF` will
  ##                 disable sending reports.
  ensure:
    serverAddress == httpAddress
    appKey == key
  body:
    if ($httpAddress).len == 0:
      raise newException(exceptn = RapportError,
          message = "HTTP address can't be empty")
    if key.len == 0:
      raise newException(exceptn = RapportError,
          message = "Application key can't be empty")
    serverAddress = httpAddress
    appKey = key

proc sendRapport*(content: RapportContent): string {.raises: [RapportError],
    tags: [ReadIOEffect, WriteIOEffect, TimeEffect], contractual.} =
  ## Send a report to the project's server.
  ##
  ## * content - the content of the report
  ##
  ## Returns the response from the server
  # Check do rapporteur was initialized
  if ($serverAddress).len == 0 or appKey.len == 0:
    raise newException(exceptn = RapportError,
        message = "Rapporteur not initialized")
  # Check do content of the report was supplied
  if content.len == 0:
    raise newException(exceptn = RapportError,
        message = "Content can't be empty")
  # If key is set to DEADBEEF, don't send anything
  if appKey == "DEADBEEF":
    return
  let client = newHttpClient()
  client.headers = try:
      newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
    except KeyError:
      raise newException(exceptn = RapportError,
          message = "Can't set the request HTTP header")
  let newHash: Hash = hash(x = content)
  try:
    result = client.request(serverAddress, httpMethod = HttpPost,
        body = "key=" & appKey & "&hash=" & $newHash & "&content=" &
        content).status
  except:
    raise newException(exceptn = RapportError,
        message = "Can't set the HTTP request")


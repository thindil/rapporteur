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

import std/uri
import contracts

type
  RapportError* = object of CatchableError
  RapportKey* = string
  RapportContent* = string

var
  serverAddress: Uri = parseUri(uri = "")
  appKey: RapportKey = ""

proc initRapport*(httpAddress: Uri; key: RapportKey) {.raises: [RapportError],
    tags: [], contractual.} =
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

proc sendRapport*(content: RapportContent) {.raises: [RapportError], tags: [],
    contractual.} =
  if ($serverAddress).len == 0 or appKey.len == 0:
    raise newException(exceptn = RapportError,
        message = "rapporteur not initialized")
  if content.len == 0:
    raise newException(exceptn = RapportError,
        message = "content can't be empty")

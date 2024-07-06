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

# It is a very simple example how the bug reporting can be used. It require
# working somewhere the project's server. For more information about setting
# the server, please look at the project's documenation. To send the report,
# you have to define appKey option during compilation. For example:
# nim c -d:ssl -d:appKey=mykey testrapport.nim

import std/uri
import ../src/rapporteur

# The application key used for authentication on the server. Here it is read
# during compilation. If not set via compilation option, it default value is
# DEADBEEF.
const appKey {.strdefine.}: string = "DEADBEEF"

# Initialize the library, set the server's HTTP address and the authentication
# key for it. Perhaps the best option for setting the key, is to read it
# from outside source, like environment variable or as an option during
# compilation. If you set the key to DEADBEEF value, sending reports will be
# disabled.
initRapport(httpAddress = "https://www.laeran.pl.eu.org/rap".parseUri, key = appKey)

# Send a report to the server, via HTTP POST method. Content is the text which
# will be encoded and send to the server. As the result, show the tuple which
# contains the server HTTP response status and the full answer of the server.
let response: tuple[status: Natural, body: RapportContent] = sendRapport(
    content = "hello")
echo "Status code:\n", response.status
echo "Response body:\n", response.body

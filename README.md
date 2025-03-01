### General information

Rapporteur is a suite to automatically send bug reports from a program to the
server. **At this moment, the whole project is in alpha stage. It offers very
basic functionality and may contain bugs. Use at your own risk.** If you read
this file on GitHub: **please don't send pull requests here**. All will be
automatically closed. Any code propositions should go to the
[Fossil](https://www.laeran.pl.eu.org/repositories/rapporteur) repository.

**IMPORTANT:** If you read the file in the project code repository: This
version of the file is related to the future version of the project. It may
contain information not present in released versions of the program. For
that information, please refer to the README.md file included into the release.

### Build from the source

You will need:

* [Nim compiler](https://nim-lang.org/install.html)
* [Contracts](https://github.com/Udiknedormin/NimContracts)

You can install them manually or by using [Nimble](https://github.com/nim-lang/nimble).
In that second option, type `nimble install https://github.com/thindil/rapporteur` to
install the project and all dependencies. Generally it is recommended to use
`nimble release` to build the project in release (optimized) mode or
`nimble debug` to build it in the debug mode. This step will install the library and
build the CGI script to use on a server. You can cross compile the CGI script from
Linux to Linux ARM with command `nimble releasearm` or to Windows 64-bit with command
`nimble releasewindows`.

### Using Rapporteur in your code

#### Setting the server
The first step is to set the Rapporteur's script on a server. It requires a
HTTP server with support for CGI scripts. The CGI script will need writing
permissions on the server to some directory. Additionally, you will need to create
a shell script and configuration file for the CGI script. Detailed instructions
may vary and depends on the operating system of the server.

1. Compile the CGI script with one of the commands mentioned above.
2. Place the CGI script somewhere on the server, and give the server permissions
   to run the script.
3. Create a configuration file for the CGI script. It must contain two options:

   `keys = "key1;key2;key3"` - the list of keys for applications which are allowed
    to send reports. Separated by semicolon. Generally, very basic authentication.
   `datadir = "/path/to/dir/with/reports"` - the full path to the directory where
    the reports will be stored. The web server must have permissions to write to
    that directory.
4. Create a simple CGI script which will run the project's server. The script must
   be in the path where the server expect CGI script. Usually it is directory *cgi-bin*
   etc. It depends on the server configuration. The script must contain the
   environment variable `RAPPORT_CONFIG` with full path to the project's
   configuration file, created in the step 3. For example, for Linux the shell
   script could look that:

        #!/usr/bin/sh
        export RAPPORT_CONFIG=/path/to/config.cfg
        /path/to/bin/rapporteur

And the server should be set up. :)

#### Sending a report to the server
The second step is to send a report from your code. It is done with two steps:

1. Initialize the `rapporteur` module somewhere in your code, but before the
   first message which will be sent to the server. Initialization is made by
   calling procedure `initRapport` to set the HTTP address of the project's
   server and the key of the application used to authenticate the send request.
   For example:

        import rapporteur

        initRapport(httpAddress = "https://www.myserver.com/rapporteur".parseUri, key = "myKey")

   It is a good idea to not store the key value in the code, but read it, for
   example, from an environment variable during compilation. The key is the
   simple authentication method for requests, to prevent spam, etc. Setting
   the key value to **DEADBEEF** will disable sending reports to the server.

2. Send a report by calling procedure `sendRapport` with content of the report
   to send. The procedure returns a tuple with response from the server: the
   response's status code and the response's content. For example:

        import rapporteur

        let response = sendRapport(content = "hello")
        if response.status in {201, 208}:
          echo "OK"
        else:
          echo response.body

   The server returns status code *201* when the report was created, *208* when
   the same report exists on the server, *400* when an invalid data was sent,
   *401* when the application key is invalid (the application isn't authorized
   to send reports) and *500* when something wrong was on the server side. In
   that situation, the response body contains more technical information about
   what was wrong.

You can find an example how to send a report in *tools* directory, the file
*testrapport.nim*

#### Note
If you want to send reports to the server via HTTPS, which means usually, you
have to compile your code with parameter "-d:ssl". For example:
`nim c -d:ssl myapp.nim`

### License

The project released under 3-Clause BSD license.

---
That's all for now, as usual, I have probably forgotten about something important ;)

Bartek thindil Jasicki

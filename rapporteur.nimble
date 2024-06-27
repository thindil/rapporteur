import std/os

# Package

version = "0.1"
author = "Bartek thindil Jasicki"
description = "A client/server suite to auto send bug report"
license = "BSD-3-Clause"
namedBin["main"] = "rapporteur"
binDir = "bin"
srcDir = "src"
installFiles = @["rapporteur.nim"]

# Dependencies

requires "nim >= 2.0.0"
requires "contracts >= 0.2.2"
requires "unittest2"

# Tasks

var execName = changeFileExt("rapporteur", ExeExt)

task debug, "builds the project in debug mode":
  exec "nim c -d:debug --styleCheck:hint --spellSuggest:auto --errorMax:0 --outdir:" &
      binDir & " --out:" & binDir & DirSep & execName & " src" & DirSep & "main.nim"

task release, "builds the project in release mode":
  exec "nim c -d:release --passc:-flto --passl:-s --outdir:" & binDir &
      " --out:" & binDir & DirSep & execName & " src" & DirSep &
      "main.nim"

task test, "run the project unit tests":
  for file in listFiles("tests"):
    if file.endsWith("nim"):
      exec "nim c --verbosity:0 -r " & file & " -v"

task releasewindows, "builds the project in release mode for Windows 64-bit":
  exec "nim c -d:mingw --os:windows --cpu:amd64 --amd64.windows.gcc.exe:x86_64-w64-mingw32-gcc --amd64.windows.gcc.linkerexe=x86_64-w64-mingw32-gcc  -d:release --passc:-flto --passl:-s --outdir:" &
      binDir & " -out:" & binDir & "/rapporteur.exe src" & DirSep & "main.nim"

task releasearm, "builds the project in release mode for Linux on arm":
  exec "nim c --cpu:arm -d:release --passc:-flto --passl:-s --outdir:" &
      binDir & " " & srcDir & DirSep & "main.nim"

task docs, "builds the project's documentation":
  exec "nim doc --project --outdir:htmldocs src" & DirSep & "main.nim"

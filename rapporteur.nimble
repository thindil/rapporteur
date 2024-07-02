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

# Tasks

var execName = changeFileExt("rapporteur", ExeExt)

task debug, "builds the project in debug mode":
  exec "nim c -d:debug --styleCheck:hint --spellSuggest:auto --errorMax:0 --outdir:" &
      binDir & " --out:" & binDir & DirSep & execName & " " & srcDir & DirSep & "server.nim"

task release, "builds the project in release mode":
  exec "nim c -d:release --passc:-flto --passl:-s --outdir:" & binDir &
      " --out:" & binDir & DirSep & execName & " " & srcDir & DirSep & "server.nim"

task releasewindows, "builds the project in release mode for Windows 64-bit":
  exec "nim c -d:mingw --os:windows --cpu:amd64 --amd64.windows.gcc.exe:x86_64-w64-mingw32-gcc --amd64.windows.gcc.linkerexe=x86_64-w64-mingw32-gcc  -d:release --passc:-flto --passl:-s --outdir:" &
      binDir & " -out:" & binDir & "/rapporteur.exe " & srcDir & DirSep & "server.nim"

task releasearm, "builds the project in release mode for Linux on arm":
  exec "nim c --cpu:arm -d:release --passc:-flto --passl:-s --outdir:" &
      binDir & " " & " --out:" & binDir & DirSep & execName & " " & srcDir &
      DirSep & "server.nim"

task docs, "builds the project's documentation":
  exec "nim doc --project --outdir:htmldocs " & srcDir & DirSep & "server.nim"
  exec "nim doc --project --outdir:htmldocs " & srcDir & DirSep & "rapporteur.nim"

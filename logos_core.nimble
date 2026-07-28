# Package

version = "0.1.0"
author = "Jacek Sieka"
description = "logos code poc"
license = "MIT"
srcDir = "src"
installExt = @["nim"]
bin = @[]

# Dependencies

requires "nim >= 2.2.10"
requires "chronos >= 4.4.0"
requires "cbor_serialization"
requires "illwill"

task build2, "Build that can do .so":
  exec "nim c src/runtime_cli"
  exec "nim c src/runtime_tui"
  exec "nim c src/exploit"

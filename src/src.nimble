# Package

version       = "0.1.0"
author        = "Jacek Sieka"
description   = "Logos"
license       = "MIT"
srcDir        = ""
installExt    = @["nim"]
bin           = @["lph", "tpc", "runtime_tui"]


# Dependencies

requires "nim >= 2.2.10","chronos","cbor_serialization","results","illwill"

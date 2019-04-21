version       = "0.1.0"
author        = "Julian Fondren"
description   = "Benchmarking wrapper around getrusage()"
license       = "MIT"
srcDir        = "src"
bin           = @["getr"]

requires "nim >= 0.19.4"

task markdown, "Generate MANPAGE.md from mdoc":
  exec "mandoc -T markdown < getr.mdoc > MANPAGE.md"

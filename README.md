# getrusage() wrapper
- known to work on Linux and macOS
- created as my simple "time for x in {1..100}; ..." benchmarks were a lot less pleasant on OpenBSD.

## Nim notes
- this is a Nim translation of the C version at https://github.com/jrfondren/getr
- os.getAppFilename() isn't the desired argv[0]
- this translation uses more Nim library code than other (Ada, Zig) translations
- the first committed getr.nim had pretty terrible Nim styling compared to the
  current version
- system.quit writes to stdout
- parseopt.getopt returns a full enum, requiring the caller to have a
  this-never-happens case, when it could just return a range.
- parseopt doesn't respect -- anyway and can't be told to stop mangling
  arguments (as getr would after getting its first positional argument), so
  it's not used.

## build, etc.
```
nimble build
nimble install    # will put binary in a place like ~/.nimble/bin
nimble markdown   # will (re)generate MANPAGE.md from the mdoc
```

## usage and examples
```
$ getr 1000 ./fizzbuzz >/dev/null
User time      : 0 s, 292213 us
System time    : 0 s, 145760 us
Time           : 438 ms (0.438 ms/per)
Max RSS        : 1688 kB
Page reclaims  : 78325
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 999
invol ctx switches : 16

$ getr 100 python3 -c ''
User time      : 1 s, 156005 us
System time    : 1 s, 790951 us
Time           : 2946.956 ms (29.470 ms/per)
Max RSS        : 4.0 MB
Page reclaims  : 134105
Page faults    : 20
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 21
invol ctx switches : 2959

$ getr 100 perl -le ''
User time      : 0 s, 311100 us
System time    : 0 s, 284004 us
Time           : 595.104 ms (5.951 ms/per)
Max RSS        : 1.6 MB
Page reclaims  : 69773
Page faults    : 9
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 6
invol ctx switches : 2687

$ getr -b 29.470 100 perl -le ''
| 0.193x | 5.70241 ms | 1.5 MB |

$ getr -b 7.70241 100 python3 -c ''
| 3.777x | 29.09106 ms | 6.1 MB |
```

## defects and room for improvement
- output is in an ad-hoc text format that machine consumers would need to parse manually
- 'getr' is probably a poor name

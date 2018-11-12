# getrusage() wrapper
- known to work on Linux
- created as my simple "time for x in {1..100}; ..." benchmarks were a lot less pleasant on OpenBSD.

## Nim notes
- this is a Nim translation of the C version at https://github.com/jrfondren/getr
- os.getAppFilename() isn't the desired argv[0]
- this translation uses more Nim library code than other (Ada, Zig) translations

## build
```
make
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

$ getr 100 $(which python3) -c ''
User time      : 1 s, 505550 us
System time    : 0 s, 282703 us
Time           : 1788 ms (17.9 ms/per)
Max RSS        : 8704 kB
Page reclaims  : 100361
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 104
invol ctx switches : 20

$ getr 100 $(which perl) -le ''
User time      : 0 s, 89124 us
System time    : 0 s, 64512 us
Time           : 154 ms (1.54 ms/per)
Max RSS        : 5060 kB
Page reclaims  : 23831
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 104
invol ctx switches : 1
```

## defects and room for improvement
- no $PATH resolution occurs
- output is in an ad-hoc text format that machine consumers would need to parse manually
- this command lacks a manpage
- 'getr' is probably a poor name
- kB and ms are always used even when number ranges might be easier to understand in MB or s, or GB or min:s

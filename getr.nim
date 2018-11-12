import strformat, os, osproc, strutils

type
   Timeval = object
      sec: int64
      usec: int64
   Usage = ref object
      utime: Timeval
      stime: Timeval
      maxrss: int64
      ixrss: int64
      idrss: int64
      isrss: int64
      minflt: int64
      majflt: int64
      nswap: int64
      inblock: int64
      oublock: int64
      msgsnd: int64
      msgrcv: int64
      nsignals: int64
      nvcsw: int64
      nivcsw: int64
   Who = enum
      RUSAGE_CHILDREN = -1, RUSAGE_SELF = 0

proc getrusage(who: Who, report: Usage): int {.header: "<sys/resource.h>", importc: "getrusage".}
proc `*`(a: float, b: int64): float =
   {.emit: [result, " = ", a, " * ", b, ";"].}

proc toString(rep: Usage, count: int): string =
   var
      secs = 1.0 * (rep.utime.sec + rep.stime.sec)
      usecs = 1.0 * (rep.utime.usec + rep.stime.usec)
      ms = secs*1000.0 + usecs/1000.0
      ms_per = ms/toFloat(count)
   return &"""
User time      : {rep.utime.sec} s, {rep.utime.usec} us
System time    : {rep.stime.sec} s, {rep.stime.usec} us
Time           : {toInt(ms)} ms ({ms_per:.3} ms/per)
Max RSS        : {rep.maxrss} kB
Page reclaims  : {rep.minflt}
Page faults    : {rep.majflt}
Block inputs   : {rep.inblock}
Block outputs  : {rep.oublock}
vol ctx switches   : {rep.nvcsw}
invol ctx switches : {rep.nivcsw}
"""

proc main() =
   var argv = commandLineParams()
   if argv.len > 1:
      var count = parseInt(argv[0])
      for i in 0 .. count:
         var pid = startProcess(argv[1], args=argv[2 .. ^1], options={poParentStreams})
         discard waitForExit(pid)

      var rep: Usage
      new(rep)
      discard getrusage(RUSAGE_CHILDREN, rep)
      write(stderr, toString(rep, count))
   else:
      write(stderr, getAppFilename() & " <n> <command> [<args> ...]\n")

main()

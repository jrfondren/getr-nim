{.passC: "-Wno-error=incompatible-pointer-types".}  # gcc 14
import os, osproc, strformat, strutils

# system.quit writes to stdout instead of stderr
proc myQuit(msg: string) =
  programResult = 1
  stderr.write msg
  quit()

const
  version = "0.1.0"

type
  Timeval = object
    sec, usec: int64
  Usage = ref object
    utime, stime: Timeval
    maxrss: int64
    ixrss, idrss, isrss: int64
    minflt, majflt: int64
    nswap: int64
    inblock, oublock: int64
    msgsnd, msgrcv: int64
    nsignals: int64
    nvcsw: int64
    nivcsw: int64
  Who = enum
    RUSAGE_CHILDREN = -1, RUSAGE_SELF = 0
  Mode = enum
    Normal, Brief

var
  mode = Normal
  speedRef : float
  spawnCount = -1
  spawnArgs: seq[string]  # including subcommand

proc getrusage(who: Who, report: Usage): int {.header: "<sys/resource.h>", importc: "getrusage".}
func `*`(a: float, b: int64): float =
   {.emit: [result, " = ", a, " * ", b, ";"].}
func `/`(a: int64, b: int64): float =
   {.emit: [result, " = (double)", a, " / (double)", b, ";"].}

func smartTime(ms: float): string =
  if ms < 3000: return &"{ms} ms"
  if ms < 60*1000: return &"{toInt(ms/1000)} s {ms.toInt mod 1000} ms"
  else: return &"{toInt(ms/60/1000)} min {ms.toInt mod (60*1000)} s"

func smartRSS(maybe_kb: int64): string =
  let 
    k = 1024i64
    kb =
      when hostOS == "macosx": int64(maybe_kb / k)
      else: maybe_kb
  if kb < k: return &"{kb} kB"
  if kb < k * k: return &"{kb/k:.1f} MB"
  else: return &"{kb/(k*k):.2f} GB"

proc report(rep: Usage) =
  let
    secs = 1.0 * (rep.utime.sec + rep.stime.sec)
    usecs = 1.0 * (rep.utime.usec + rep.stime.usec)
    ms = secs*1000.0 + usecs/1000.0
    ms_per = ms/toFloat(spawnCount)
  case mode
  of Brief:
    let speed = ms_per / speedRef
    stderr.write &"| {speed:5.3f}x | {smartTime ms_per} | {smartRSS rep.maxrss} |\n"
  of Normal: stderr.write &"""
User time      : {rep.utime.sec} s, {rep.utime.usec} us
System time    : {rep.stime.sec} s, {rep.stime.usec} us
Time           : {smartTime ms} ({ms_per:.3f} ms/per)
Max RSS        : {smartRSS rep.maxrss}
Page reclaims  : {rep.minflt}
Page faults    : {rep.majflt}
Block inputs   : {rep.inblock}
Block outputs  : {rep.oublock}
vol ctx switches   : {rep.nvcsw}
invol ctx switches : {rep.nivcsw}
"""

proc usage =
  myQuit &"""
usage: {getAppFilename()} [-h] [-b <ref>] <n> <command> [<args> ...]

options:
  -h             print this text and exit
  -b <ref>       print only | Speed | Runtime | MaxRSS | table output
                 'Speed' is presented as 3.8x, 0.11x, etc., and is
                 calculated as 'ref' * Speed = Runtime
"""

proc options =
  let argv = commandLineParams()
  var i = 0

  if argv.len < 2: usage()
  if argv[0] == "-h": usage()
  if argv[0] == "-b":
    mode = Brief
    speedRef = parseFloat argv[1]
    i += 2

  spawnCount = parseInt argv[i]
  spawnArgs = argv[i+1 .. ^1]

proc main =
  for i in 1 .. spawnCount:
    var pid = startProcess(spawnArgs[0], args=spawnArgs[1 .. ^1], options={poParentStreams, poUsePath})
    discard waitForExit(pid)

  var rep: Usage
  new(rep)
  discard getrusage(RUSAGE_CHILDREN, rep)
  report rep

when isMainModule:
  options()
  main()

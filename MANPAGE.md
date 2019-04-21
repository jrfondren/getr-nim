GETR(1) - General Commands Manual

# NAME

**getr** - getrusage() wrapper for simple benchmarks

# SYNOPSIS

**getr**
\[*-h*]
\[*-b* *ref*]
*count*
*program*
\[*args* *...*]

# OUTPUT

	$ getr 1000 ./fizzbuzz >/dev/null
	User time      : 0 s, 894347 us
	System time    : 0 s, 673832 us
	Time           : 1568.179 ms (1.568 ms/per)
	Max RSS        : 952 kB
	Page reclaims  : 239344
	Page faults    : 1
	Block inputs   : 0
	Block outputs  : 0
	vol ctx switches   : 0
	invol ctx switches : 1298
	
	$ getr -b 1.568 1000 perl -le ''
	| 3.738x | 5.86151 ms | 1.6 MB |

# DESCRIPTION

**getr** is a simple wrapper around the **getrusage**(2)
syscall, which can be relied on for basic resource usage reports
under Linux, OpenBSD, and macOS (among others). A child command
is repeatedly spawned and waited for, and then a
**RUSAGE\_CHILDREN** report is generated. This program was
created as the author was used to very simple bash loops to test
performance, which he then found didn't work at all under ksh on
OpenBSD. **getr** is just as easy and just as simple.

# EXIT STATUS

**getr** exits with status 1 if any **waitpid**(2) or
**posix\_spawn**(2) syscalls fail, or if its own arguments
aren't understood. It exits with status 0 in all other cases,
including if the spawned program returns a nonzero exit status.

# EXAMPLES

**getr 1000 ./fizzbuzz &gt; /dev/null**

**fizzbuzz** is invoked 1000 times, with no arguments, and with
**getr**'s own (and therefore **fizzbuzz**'s) standard output
piped to **/dev/null**. The resulting usage report would still
be printed to standard error.

**getr 100 python3 -c ''**

The **python3** in PATH is asked, 100 times, to evaluate
the empty string as a Python script.

**getr -b 5.86 100 python3 -c ''**

As above. Instead of the normal listing, the output is a single row
suitable for adding to an org-mode table, with columns Speed, Runtime,
and MaxRSS. Speed is calculated as Ref \* Speed = Runtime, where Ref is
5\.86 in the above example. In the **OUTPUT** section you can see
that Perl, asked to do nothing, takes 3.7 times as long as fizzbuzz
takes to produce its output.

# SEE ALSO

getrusage(2),
which(1),
time(1),
perf(1),
valgrind(1).

POSIX - April 21, 2019

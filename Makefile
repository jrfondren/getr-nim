all:: getr

clean::
	rm -fv getr

getr: getr.nim
	nim c -d:release $<

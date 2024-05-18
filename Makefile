all:: getr

clean::
	rm -fv getr

getr: src/getr.nim
	nim c -d:release $<

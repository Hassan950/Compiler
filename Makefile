INPUT ?= fb1-1.l
OUTPUTFILE ?= output

a: $(INPUT) lib/libfl.a lib/liby.a lib/flex.exe lib/bison.exe
	./lib/flex -obuild/$(OUTPUTFILE).yy.c $(INPUT)
	gcc build/$(OUTPUTFILE).yy.c -Llib -lfl -o build/$(OUTPUTFILE).exe

clear:
	rm build/*
INPUT_LEXER ?= lexer.l
INPUT_PARSER ?= parser.y
SCANNER_OUTPUT ?= lex
PARSER_OUTPUT ?= parser
EXE_OUTPUT ?= output

N ?= 1
INPUT_FILE ?= inputs/input$(N).txt
OUTPUT_FILE ?= outputs/output$(N).txt


all: scan parse build

parse: $(INPUT_PARSER) lib/bison.exe
	bison -d $(INPUT_PARSER) -b build/$(PARSER_OUTPUT)

scan: $(INPUT_LEXER) lib/flex.exe 
	flex -obuild/$(SCANNER_OUTPUT).yy.c $(INPUT_LEXER)

build: build/$(SCANNER_OUTPUT).yy.c build/$(PARSER_OUTPUT).tab.c  lib/libfl.a lib/liby.a
	g++ compiler.c build/$(PARSER_OUTPUT).tab.c build/$(SCANNER_OUTPUT).yy.c -I. -Llib -lfl -o build/$(EXE_OUTPUT).exe

clear:
	rm build/*

run:
	./build/$(EXE_OUTPUT).exe

test:
	./build/$(EXE_OUTPUT).exe < $(INPUT_FILE) > $(OUTPUT_FILE)

bt: all test
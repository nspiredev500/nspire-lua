#n-as lua GUI

DEBUG = FALSE

GCC = nspire-gcc
AS  = nspire-as
GXX = nspire-g++
LD  = nspire-ld
LUNA = "$(shell nspire-tools path)/tools/luna/luna"
GENZEHN = genzehn

GCCFLAGS = -Wall -W -marm
LDFLAGS =
ZEHNFLAGS = --name "n-as" --240x320-support true

ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
endif

OBJS = $(patsubst %.c, %.o, $(shell find . -name \*.c))
OBJS += $(patsubst %.cpp, %.o, $(shell find . -name \*.cpp))
OBJS += $(patsubst %.S, %.o, $(shell find . -name \*.S))
EXE = n-as.luax.tns
DISTDIR = .
vpath %.tns $(DISTDIR)
vpath %.elf $(DISTDIR)

all: n-as.tns n-as.luax.tns



n-as.tns: ../input/input.lua ../window/window.lua n-as.lua instructions.lua wrapp-words.lua escape-xml.py architecture.xml instruction-list.xml Document.xml Problem_header.xml Problem_mid.xml Problem_end.xml notepad_header.xml notepad_end.xml card_header.xml card_end.xml script-header.xml script-end.xml
	cat ../input/input.lua ../window/window.lua > libs.lua
	lua wrapp-words.lua
	python3 escape-xml.py
	cat Problem_header.xml libs-escaped.lua Problem_mid.xml card_header.xml notepad_header.xml architecture-wrapped-escaped.xml notepad_end.xml card_end.xml card_header.xml script-header.xml n-as-escaped.lua script-end.xml card_end.xml card_header.xml script-header.xml instructions-escaped.lua script-end.xml card_end.xml card_header.xml notepad_header.xml instruction-list-wrapped-escaped.xml notepad_end.xml card_end.xml Problem_end.xml > Problem1.xml
	$(LUNA) Document.xml Problem1.xml n-as.tns



n-as.luax.tns: n-as.c ../nspire-toolchain/n-as/main.c ../nspire-toolchain/n-as/logic.c ../nspire-toolchain/n-as/assembler.h ../nspire-toolchain/n-as/definitions.h ../nspire-toolchain/n-as/parser.y ../nspire-toolchain/n-as/lexer.l
	cd ../nspire-toolchain/n-as && \
	bison -d parser.y && \
	flex lexer.l && \
	$(GCC) -Os lex.yy.c parser.tab.c ../../n-as/n-as.c -o ../../n-as/lexer
	$(GENZEHN) --input lexer --output n-as.luax.tns $(ZEHNFLAGS)


clean:
	-rm -f n-as.tns n-as.luax.tns ../nspire-toolchain/n-as/lex.yy.c ../nspire-toolchain/n-as/parser.tab.c ../nspire-toolchain/n-as/parser.tab.h lexer n-as-escaped.lua instructions-escaped.lua architecture-wrapped.xml architecture-wrapped-escaped.xml libs-escaped.lua Problem1.xml instruction-list-wrapped.xml instruction-list-wrapped-escaped.xml

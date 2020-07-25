# lua input library

LUNA = "$(shell nspire-tools path)/tools/luna/luna"


all: input.tns

input.tns: input.lua test.lua
	cat input.lua test.lua | $(LUNA) - input.tns



clean:
	-rm -f input.tns

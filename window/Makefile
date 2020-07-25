# lua window library

LUNA = "$(shell nspire-tools path)/tools/luna/luna"


all: window.tns

window.tns: window.lua test.lua
	cat window.lua test.lua | $(LUNA) - window.tns



clean:
	-rm -f window.tns

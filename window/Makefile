# lua window library

LUNA = "$(shell nspire-tools path)/tools/luna/luna"


all: window.tns

window.tns: window.lua test.lua ../input/input.lua
	cat ../input/input.lua window.lua test.lua | $(LUNA) - window.tns



clean:
	-rm -f window.tns

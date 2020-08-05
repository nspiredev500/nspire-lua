---  TI-Lua input library by nspiredev500  ---
--[[
	You have to supply a on.input function.
	The first argument is a input string. It's either the char of the pressed key or one of the special key strings.
	The second arguments is a whether it is a digit.
	The third argument is whether it is a alphabetic character.
	The fourth argument is whether it is a punctuation character ('.', ',', '!',...)
	The fifth argument is whether the character is a whitespace
	The sixth argument is the string length.
	
	The special key strings are:
	"enter"
	"esc"
	"del" (delete key, only available in the computer software)
	"tab"
	"bsp" (backspace, del)
	"ret" (return, the little arrow on the bottom-right)
	"cont" (context menu, ctrl+menu)
	"btab" (backtab, shift+tab)
	"clear" (ctrl+del)
	"help" (ctrl+trig)
	"up"
	"down"
	"left"
	"right"
	
	And the strings from the special Nspire keys:
	"^2" (x^2 key)
	"√(" (ctrl + x^2 key)
	"root(" (ctrl + ^ key)
	"exp(" (e^x key)
	"ln(" (ctrl + e^x key)
	"10^("
	"log(" (ctrl + 10^x key)
	string.char(239)..string.char(128)..string.char(128) (EE key)
	"\" (shift + division)
	string.char(226)..string.char(136)..string.char(171).."(" (shift + plus)
	string.char(239)..string.char(128)..string.char(136).."(" (shift + minus)
	string.char(226)..string.char(136)..string.char(246) (the sign minus)
	"_" (ctrl + space)
	
	
	The input table contains definitions for some of the hard-to-write ones.
	
	
]]--

input = {
sq="^2",
sqrt="√(",
root="root(",
exp="exp(",
ln="ln(",
pow10="10^(",
log="log(",
ee=string.char(239)..string.char(128)..string.char(128),
int=string.char(226)..string.char(136)..string.char(171).."(",
deriv=string.char(239)..string.char(128)..string.char(136).."(",
mathmin=string.char(226)..string.char(136)..string.char(146)
}



function on.charIn(c)
	local len = c:len()
	if len == 1 then
		if string.match(c,"%d") ~= nil then
			on.input(c,true,false,false,false,len)
			return
		end
		if string.match(c,"%a") ~= nil then
			on.input(c,false,true,false,false,len)
			return
		end
		if string.match(c,"%p") ~= nil then
			on.input(c,false,false,true,false,len)
			return
		end
		if string.match(c,"%s") ~= nil then
			on.input(c,false,false,false,true,len)
			return
		end
	end
	on.input(c,false,false,false,false,len)
end

function on.enterKey()
	on.input("enter",false,false,false,false,string.len("enter"))
end

function on.escapeKey()
	on.input("esc",false,false,false,false,string.len("esc"))
end

function on.tabKey()
	on.input("tab",false,false,false,false,string.len("tab"))
end

function on.deleteKey()
	on.input("del",false,false,false,false,string.len("del"))
end

function on.backspaceKey()
	on.input("bsp",false,false,false,false,string.len("bsp"))
end

function on.returnKey()
	on.input("ret",false,false,false,false,string.len("ret"))
end

function on.contextMenu()
	on.input("cont",false,false,false,false,string.len("cont"))
end

function on.backtabKey()
	on.input("btab",false,false,false,false,string.len("btab"))
end

function on.clearKey()
	on.input("clear",false,false,false,false,string.len("clear"))
end

function on.help()
	on.input("help",false,false,false,false,string.len("help"))
end

function on.arrowUp()
	on.input("up",false,false,false,false,string.len("up"))
end

function on.arrowDown()
	on.input("down",false,false,false,false,string.len("down"))
end

function on.arrowLeft()
	on.input("left",false,false,false,false,string.len("left"))
end

function on.arrowRight()
	on.input("right",false,false,false,false,string.len("right"))
end


---  end lua input library  ---
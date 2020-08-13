-- libraries: 1028 lines



main_window = nil
textbox = nil
textfield = nil

instructions = {
adc = "adc rd, rn, rm\n adds rn to rm and adds the carry bit,\nstores it into rd.",
add = "add rd, rn, rm\n adds the value of rn to rm\nand stores the result in rd.",
['and'] = "and rd, rn, rm\n performs biwise and with rn and rm\nand stores the result in rd.",
b = "b #number\n jumps to the offset specified,\nrelative to the instruction.\n\nb label\n jumps to the label.",
bl = "Same as b, but puts the address of the\nnext instruction into lr.",
bic = "bic rd, rn, rm\n Bit clear\nclears the bits of rn that are set\nin rm and puts the result into rd.",
bkpt = "Breakpoint\nCan be used in an emulator tostop execution",
blx = "Same as bx, but puts the address of the\nnext instruction into lr.",
bx = "bx rn\njumps to the address in rn.\nIf the first bit is one, enters thumb mode",
bxj = "bjs rn\n jumps to jazelle state at rn",
cdp = "cdp\nperforms a operation on coprocessor registers.",
clz = "clz rd, rm\nstores the number of 0 bits before a 1 bit in rm into rd",
cmn = "same as cmp, but negates 2. operand",
cmp = "compares 2 operands and sets the condition flags",
cpy = "synonym for mov",
eor = "eor rd, rn, rm\n performs an exclusive-or operation.",
lcd = "loads from memory into coprocessor register",
ldm = "ldm rn, {reglist}\nloads from multiple consecutive memory addresses into registers",
ldr = "ldr rd, [rn]\n loads the value at the address rn\ninto rd\n the address has to be a multiple\n of 4",
ldrb = "same as ldr, but only a byte",
ldrbt = "same as ldrb, but with user privileges",
ldrd = "same as ldr, but only 8 bytes and 2 consecutive registers\nthe destination register specified has to be even.",
ldrsh = "same as ldr, but only 2 bytes and 2 byte alignment",
ldrt = "same as ldr, but with user privileges",
mcr = "moves a value from an arm register\n to a coprocessor",
mov = "mov rd, rn\nMoves the value of register rn into register rd.\n\nmov rd, #number\nMoves the number into rd.\nThe number has to be 8 bits wide, and the 8 bits\ncan be anywhere in the\nfull 4 bytes of the register.",
mrc = "moves a value from a coprocessor\nregister into an arm register",
mrs = "mrs rd, (cpsr/spsr)\nmoves the value of the cpsr or the spsr\n into rd",
msr = "msr (cpsr/spsr), rm\nmoves the value rn into the\ncpsr or spsr",
mul = "mul rd, rn, rm\n multiplies rn and rm",
mvn = "same as mov, but uses bitwise not on the operand",
orr = "bitwise or",
rsb = "rsb rd, rn, rm\nreverse subtract\nsubtracts rn from rm",
rsc = "same as rsb, but with borrow from the carry bit",
sbc = "same as sub, but with borrow from the carry bit",
stc = "stores a value in a coprocessor register",
stm = "stm rn, {regslist}\n stores the registers in consecutive addresses at rn",
str = "str rn,[rm]\n stores rn at the address specified by rm",
strb = "same as ldrb, but store",
strbt = "same as ldrbt, but store",
strd = "same as ldrd, but store",
strh = "same as ldrh, but store",
strt = "same as ldrt, but store",
swi = "swi #number\n calls the specified system call",
swp = "swp rd, rm, [rn]\n swaps the value at address rn with rm\nand stores the original value at rd",
swpb = "same as swp, but only a byte",
teq = "test equality",
tst = "does a and on the operands and updates the condition flags"
}


function on.construction()
	loadstring(var.recall("libs"))()
	
	main_window = window.window(0,0,320,240,true,"")
	main_window:setFullscreen(true)
	
	textbox = window.textField(5,5,"",200,20)
	
	textfield = window.textEditor(0,30,"",317,211-30)
	textfield:setReadOnly(true)
	
	
	textbox:registerFilter(textbox_filter)
	textfield:registerFilter(textfield_filter)
	
	main_window:add(textbox)
	main_window:add(textfield)
	
	main_window:focus(textbox)
	window.focus(main_window)
	
	platform.window:invalidate()
end


function on.getSymbolList()
	return {"libs"}
end


function textbox_filter(e,d,a,p,w,l,m,x,y,win)
	if e == "enter" then
		for i,j in pairs(instructions) do
			if i == textbox:getText() then
				textfield:setText(j)
				main_window:focus(textfield)
				window._damage(0,0,320,240)
				return true
			end
		end
		textfield:setText("instruction not found")
		window._damage(0,0,320,240)
		return true
	end
	window._damage(0,0,320,240)
end

function textfield_filter(e,d,a,p,w,l,m,x,y,win)
	if e == "help" then
		main_window:focus(textbox)
		return true
	end
end








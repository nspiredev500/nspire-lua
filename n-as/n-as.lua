-- libraries: 1028 lines
ndless = true
as_lib_loaded = true
if nrequire then
	if pcall(nrequire,"n-as") == false then
		as_lib_loaded = false;
	end
else
	ndless = false
end






file_name = ""
file_dirty = false


asm_error_window = nil
main_window = nil
options_window = nil
no_ndless_dialog = nil
no_asm_lib_dialog = nil
file_name_dialog = nil
file_open_dialog = nil
registers_dialog = nil
stack_dialog = nil




checkbox_hex = nil
checkbox_dec = nil



checkbox_swi = nil
checkbox_coproc = nil
checkbox_psr = nil


asm_error_label = nil
filename_label = nil
filename_textbox = nil

fileopen_canvas = nil




files = {
{"Hello World", ".entry start\n.text\nstart: mov r0, #1\nbx lr"},
{"Hello Stack", ".entry start\n.text\nstart: mov r0, #1\npush {r0}\nbx lr"},
{"Fibonacci", ";switch to decimal in the options\n;run and check the stack\n.entry start\n.text\n;r0 and r1 are the last 2 fibonaccis\n;r3 is the loop counter\nstart: mov r0, #0\nmov r1, #1\nmov r3, #0\npush {r0}\npush {r1}\nloop: add r2, r1, r0\npush {r2}\nmov r0, r1\n mov r1, r2\nadd r3, r3, #1\n cmp r3, #15\nblt loop\nbx lr"}
}


registers_field = nil

stack_field = nil


editor = nil
function on.construction()
	toolpalette.register(menu)
	
	loadstring(var.recall("libs"))()
	
	no_ndless_dialog = window.window(320/2-150,240/2-50,300,50,false,"No Ndless")
	no_ndless_dialog.decoration:setColor(150,255,150)
	no_asm_lib_dialog = window.window(320/2-100,240/2-50,200,50,false,"No ASM lib")
	no_asm_lib_dialog.decoration:setColor(150,255,150)
	
	options_window = window.window(320/2-150,240/2-75,300,150,false,"Options")
	options_window.decoration:setColor(150,255,150)
	
	asm_error_window = window.window(320/2-150,240/2-50,300,50,false,"Assembler error")
	asm_error_window.decoration:setColor(255,150,150)
	
	file_name_dialog = window.window(320/2-150,240/2-75,300,150,false,"Save as")
	file_name_dialog.decoration:setColor(150,255,150)
	
	file_open_dialog = window.window(320/2-150,240/2-75,300,150,false,"Open")
	file_open_dialog.decoration:setColor(150,255,150)
	
	
	registers_dialog = window.window(320/2-150,240/2-75,300,150,false,"Registers")
	registers_dialog.decoration:setColor(150,255,150)
	
	stack_dialog = window.window(320/2-150,240/2-75,300,150,false,"Stack")
	stack_dialog.decoration:setColor(150,255,150)
	
	
	
	main_window = window.window(0,0,320,240,true,"")
	main_window:setFullscreen(true)
	
	editor = window.textEditor(0,20,"",317,211-20)
	editor:showLines(true)
	editor:registerFilter(editor_filter)
	editor:setText(files[1][2])
	main_window:add(editor)
	
	asm_error_label = window.textEditor(0,0,"",300,50)
	asm_error_label:setReadOnly(true)
	filename_label = window.label(1,1,"")
	filename_label:setText(files[1][1],main_window)
	file_name = files[1][1]
	
	filename_textbox = window.textField(10,10,"",290,20)
	
	file_name_dialog:add(filename_textbox)
	filename_textbox:registerFilter(filename_filter)
	
	
	
	
	fileopen_canvas = window.canvas(0,0,300,150,fileopen_draw,fileopen_event)
	fileopen_canvas.selected = 1
	fileopen_canvas.scroll = 0
	file_open_dialog:add(fileopen_canvas)
	
	
	registers_field = window.textEditor(0,0,"",300,150)
	registers_field:setReadOnly(true)
	registers_dialog:add(registers_field)
	registers_dialog:registerFilter(dialog_filter)
	registers_dialog:focus(registers_field)
	
	stack_field = window.textEditor(0,0,"",300,150)
	stack_field:setReadOnly(true)
	stack_dialog:add(stack_field)
	stack_dialog:registerFilter(dialog_filter)
	stack_dialog:focus(stack_field)
	
	
	main_window:add(filename_label)
	
	
	
	local l = window.label(10,10,"Ndless not installed")
	no_ndless_dialog:add(l)
	l:setFont("sansserif","r",12,no_ndless_dialog)
	l = window.label(5,30,"visit https://github.com/ndless-nspire/Ndless")
	no_ndless_dialog:add(l)
	l:setFont("sansserif","r",11,no_ndless_dialog)
	
	l = window.label(10,10,"n-as.luax.tns not found")
	no_asm_lib_dialog:add(l)
	l:setFont("sansserif","r",12,no_asm_lib_dialog)
	
	
	checkbox_swi = window.checkbox(10,130,10,10)
	checkbox_coproc = window.checkbox(110,130,10,10)
	checkbox_psr = window.checkbox(210,130,10,10)
	
	checkbox_hex = window.checkbox(10,30,10,10)
	checkbox_hex:check(true)
	checkbox_dec = window.checkbox(10,50,10,10)
	
	checkbox_hex:registerFilter(checkbox_filter)
	checkbox_dec:registerFilter(checkbox_filter)
	
	
	options_window:add(window.label(5,70,"These are instructions for advanced users."))
	options_window:add(window.label(5,90,"For safety, these options are initially disabled."))
	
	options_window:add(window.label(5,110,"swi"))
	options_window:add(window.label(90,110,"mrc/mcr"))
	options_window:add(window.label(190,110,"mrs/msr"))
	
	options_window:add(checkbox_swi)
	options_window:add(checkbox_coproc)
	options_window:add(checkbox_psr)
	
	options_window:add(window.label(30,25,"Hex"))
	options_window:add(window.label(30,45,"Decimal"))
	
	options_window:add(checkbox_hex)
	options_window:add(checkbox_dec)
	
	options_window:registerFilter(dialog_filter)
	
	asm_error_window:add(asm_error_label)
	asm_error_window:registerFilter(dialog_filter)
	asm_error_window:focus(asm_error_label)
	
	if ndless == false then
		no_ndless_dialog:setVisible(true)
	else
		if as_lib_loaded == false then
			no_asm_lib_dialog:setVisible(true)
		end
	end
	
	window.focus(main_window)
	main_window:focus(editor)
	
	
	window._damage(0,0,320,240)
	platform.window:invalidate()
end

function on.getSymbolList()
	return {"libs"}
end

function checkbox_filter(e,d,a,p,w,l,m,x,y,win,self)
	if e == "mouseup" then
		if self == checkbox_hex then
			checkbox_dec:check(false)
		end
		if self == checkbox_dec then
			checkbox_hex:check(false)
		end
		window._damage(0,0,320,240)
	end
	return false
end

function dialog_filter(e,d,a,p,w,l,m,x,y,win)
	if e == "esc" then
		win:setVisible(false)
		window.focus(main_window)
		window._damage(0,0,320,240)
		return true
	end
end
function editor_filter(e,d,a,p,w,l,m,x,y,win)
	if e == "cont" then
		if as_lib_loaded then
			local ret, err = asm.runString(editor:getText(),checkbox_swi:isChecked(),checkbox_psr:isChecked(),checkbox_coproc:isChecked())
			if ret == false then
				asm_error_label:setText(err,asm_error_window)
				asm_error_window:setVisible(true)
				window.focus(asm_error_window)
			else
				local regs_string = ""
				local regs = asm.getRegs()
				if checkbox_dec:isChecked() then
					regs_string = regs_string..string.format("r%d=%d\n",0,regs[0])
				end
				if checkbox_hex:isChecked() then
					regs_string = regs_string..string.format("r%d=0x%x\n",0,regs[0])
				end
				for i,j in ipairs(regs) do
					if checkbox_dec:isChecked() then
						regs_string = regs_string..string.format("r%d=%d\n",i,j)
					end
					if checkbox_hex:isChecked() then
						regs_string = regs_string..string.format("r%d=0x%x\n",i,j)
					end
				end
				registers_field:setText(regs_string,registers_dialog)
				local stack_string = ""
				local stack = asm.getStack()
				for i,j in ipairs(stack) do
					if checkbox_dec:isChecked() then
						stack_string = stack_string..string.format("%d: %d\n",i,j)
					end
					if checkbox_hex:isChecked() then
						stack_string = stack_string..string.format("%d: 0x%x\n",i,j)
					end
				end
				stack_field:setText(stack_string,stack_dialog)
			end
		end
		return true;
	end
	if e == input.int then
		editor:event(":",false,false,true,false,1,false,0,0,main_window)
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
		return true
	end
	if e == input.deriv then
		editor:event("#",false,false,false,false,1,false,0,0,main_window)
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
		return true
	end
	if e == "help" then
		options_window:setVisible(true)
		window.focus(options_window)
		return true
	end
	if e == input.root then
		registers_dialog:setVisible(true)
		window.focus(registers_dialog)
		return true
	end
	if e == "exp(" then
		editor:event("{",false,false,false,false,1,false,0,0,main_window)
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
		return true
	end
	if e == "10^(" then
		editor:event("}",false,false,false,false,1,false,0,0,main_window)
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
		return true
	end
	if e == input.mathmin then
		editor:event(";",false,false,false,false,1,false,0,0,main_window)
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
		return true
	end
	if e == input.sqrt then
		stack_dialog:setVisible(true)
		window.focus(stack_dialog)
		return true
	end
	if l == 1 or e == "cut" or e == "paste" or e == "bsp" or e == "enter" then
		file_dirty = true
		filename_label:setText(file_name.."*",main_window)
		document.markChanged()
	end
	return false;
end

function filename_filter(e,d,a,p,w,l,m,x,y,win)
	if e == "enter" then
		file_name_dialog:setVisible(false)
		window.focus(main_window)
		file_name = filename_textbox:getText()
		filename_textbox:setText("")
		save_file()
		window._damage(0,0,320,240)
		return true
	end
	if e == "esc" then
		file_name_dialog:setVisible(false)
		window.focus(main_window)
		filename_textbox:setText("")
		window._damage(0,0,320,240)
		return true
	end
	return false
end

function on.save()
	return {file_name,file_dirty,checkbox_swi:isChecked(),checkbox_coproc:isChecked(),checkbox_psr:isChecked(),files,editor:getText(),checkbox_hex:isChecked(),checkbox_dec:isChecked()};
end

function on.restore(s)
	file_name = s[1]
	file_dirty = s[2]
	if file_dirty then
		filename_label:setText(file_name.."*",main_window)
	else
		filename_label:setText(file_name,main_window)
	end
	checkbox_swi:check(s[3])
	checkbox_coproc:check(s[4])
	checkbox_psr:check(s[5])
	files = s[6]
	editor:setText(s[7])
	checkbox_hex:check(s[8])
	checkbox_dec:check(s[9])
	window._damage(0,0,320,240)
end


function fileopen_draw(self,w,gc)
	local th = self.x
	gc:setColorRGB(0,0,0)
	for i = self.scroll, #files do
		if th > self.height then
			break
		end
		if files[i] ~= nil then
			gc:setColorRGB(0,0,0)
			if i == self.selected then
				gc:setColorRGB(0,255,0)
			end
			gc:drawString(files[i][1],w.x+self.x,w.y+th,"top")
			th = th + gc:getStringHeight(files[i][1])
		end
	end
end
function fileopen_event(self,e,d,a,p,w,l,m,x,y,win)
	if e == "up" and self.selected ~= 1 then
		self.selected = self.selected -1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "down" and self.selected < #files then
		self.selected = self.selected +1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "enter" then
		file_name = files[self.selected][1]
		filename_label:setText(file_name,main_window)
		editor:setText(files[self.selected][2])
		file_open_dialog:setVisible(false)
		window.focus(main_window)
		window._damage(0,0,320,240)
	end
	if e == "clear" then
		table.remove(files,self.selected)
		self.selected = 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "esc" then
		file_open_dialog:setVisible(false)
		window.focus(main_window)
		window._damage(0,0,320,240)
	end
end




















function open_file()
	fileopen_canvas.selected = 1
	fileopen_canvas.scroll = 0
	file_open_dialog:setVisible(true)
	window.focus(file_open_dialog)
	file_open_dialog:focus(fileopen_canvas)
end


function save_file()
	if string.len(file_name) == 0 then
		save_as_file()
		return
	end
	file_dirty = false
	filename_label:setText(file_name,main_window)
	--files[file_name] = editor:getText()
	local found = false
	for i,j in ipairs(files) do
		if j[1] == file_name then
			j[2] = editor:getText()
			found = true
			break
		end
	end
	if not found then
		table.insert(files,{file_name,editor:getText()})
	end
	window._damage(0,0,320,240)
end

function save_as_file()
	file_name_dialog:setVisible(true)
	file_name_dialog:focus(filename_textbox)
	window.focus(file_name_dialog)
end


menu = {
	{ "File",
		{"open",open_file},
		{"save",save_file},
		{"save as",save_as_file}
	}
}
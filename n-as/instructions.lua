-- libraries: 1028 lines



main_window = nil
textbox = nil
textfield = nil

instructions = {
mov = "mov rd, rn\nMoves the value of register rn into register rd.\n\nmov rd, #number\nMoves the number into rd.\nThe number has to be 8 bits wide, and the 8 bits\ncan be anywhere in the\nfull 4 bytes of the register."




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
			end
		end
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








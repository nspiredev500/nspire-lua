




function on.construction()
	local w1 = window.window(100,60,100,100,true,"test")
	w1.decoration:setColor(150,255,150)
	local b
	b = window.button(10,10,"Test",function() b:setVisible(false) end)
	--w1:add(b)
	local t = window.textEditor(10,10,"",80,80)
	w1:add(t)
	t:setFont("sansserif","r",20,w1)
	--window.window(20,20,50,100,true,"test2").decoration:setColor(150,255,150)
	--window.window(20,80,50,50,true,"test3").decoration:setColor(150,255,150)
	window.focus(w1)
	w1:focus(t)
	platform.window:invalidate()
end











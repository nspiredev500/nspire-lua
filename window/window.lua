---  TI-Lua window manager library by nspiredev500  ---
--[[
	This is a window manager library.
	It requires my input library.
	
	
	
	
	
	
]]--


window = {}
window.window = class()
window.decoration = class()
window.bare = class(decoration)
window._initialized = false
window._w = 0
window._h = 0
window._windows = {}
window._moving = nil
window._grabx = 0
window._graby = 0


function window.window:init(relx,rely,width,height,visible,name,decoration)
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	assert(tonumber(relx),"window: relx has to be a number")
	assert(tonumber(rely),"window: rely has to be a number")
	self.width = width
	self.height = height
	self.relx = relx
	self.rely = rely
	if visible then
		self.visible = true
	else
		self.visible = false
	end
	if name ~= nil then
		if tostring(name) == nil then
			error("window: name has to be a string")
		end
		self.name = tostring(name)
	end
	if decoration == nil then
		self.decoration = window.decoration(0.1,0.008,0.008,0.008)
	else
		self.decoration = decoration
	end
	table.insert(window._windows,self)
end

function window.window:visible()
	return self.visible
end

function window.window:setVisible(visible)
	if visible then
		self.visible = true
	else
		self.visible = false
	end
end

function window.window:size()
	return self.size
end

function window.window:position()
	return self.relx, self.rely
end

function window.window:setPosition(relx,rely)
	assert(tonumber(relx),"window: relx has to be a number")
	assert(tonumber(rely),"window: rely has to be a number")
	self.relx = relx
	self.rely = rely
end

function window.window:setSize(width,height)
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	self.width = width
	self.height = height
end

function window.window:destroy()
	if window._moving == self then
		window._moving = nil
	end
	for i,j in ipairs(window._windows) do
		if j == self then
			table.remove(window._windows,i)
			return
		end
	end
end





function window.decoration:init(top,bottom,left,right,r,g,b)
	assert(tonumber(top),"window: top has to be a number")
	assert(tonumber(bottom),"window: bottom has to be a number")
	assert(tonumber(left),"window: left has to be a number")
	assert(tonumber(right),"window: right has to be a number")
	self.top = top
	self.bottom = bottom
	self.left = left
	self.right = right
	if tonumber(r) == nil then
		self.r = 255
	else
		self.r = r
	end
	if tonumber(g) == nil then
		self.g = 255
	else
		self.g = g
	end
	if tonumber(b) == nil then
		self.b = 255
	else
		self.b = b
	end
end

function window.decoration:paint(gc,w)
	gc:setColorRGB(0,0,0)
	local absx = w.relx * window._w
	local absy = w.rely * window._h
	local absw = w.width * window._w
	local absh = w.height * window._h
	local left = self.left * window._w
	local right = self.right * window._w
	local top = self.top * window._h
	local bottom = self.bottom * window._h
	gc:fillRect(absx-left,absy-top,left,absh+bottom+top)
	gc:fillRect(absx+absw,absy-top,right,absh+bottom+top)
	
	gc:fillRect(absx-left,absy+absh,absw+right,bottom)
	gc:drawRect(absx-left,absy-top,absw+right,top)
	gc:setColorRGB(self.r,self.g,self.b)
	gc:fillRect(absx,absy-top+1,absw,top-1)
	
	gc:setColorRGB(0,0,0)
	gc:drawString(w.name,absx+1,absy-top,"top")
end

function window.decoration:setColor(r,g,b)
	if tonumber(r) == nil then
		self.r = 255
	else
		self.r = r
	end
	if tonumber(g) == nil then
		self.g = 255
	else
		self.g = g
	end
	if tonumber(b) == nil then
		self.b = 255
	else
		self.b = b
	end
end

function window.bare:init()
	window.decoration.init(self,1,5,1,1)
end

function window.bare:paint(gc)
	gc:setColorRGB(0,0,0)
	local absx = w.relx * window._w
	local absy = w.rely * window._h
	local absw = w.width * window._w
	local absh = w.height * window._h
	local left = self.left * window._w
	local right = self.right * window._w
	local top = self.top * window._h
	local bottom = self.bottom * window._h
	gc:fillRect(absx-left,absy-top,left,absh+bottom+top)
	gc:fillRect(absx+absw,absy-top,right,absh+bottom+top)
	
	gc:fillRect(absx-left,absy+absh,absw+right,bottom)
	gc:drawRect(absx-left,absy-top,absw+right,top)
end

function on.grabDown(x,y)
	for i,w in ipairs(window._windows) do
		local self = w.decoration
		local absx = w.relx * window._w
		local absy = w.rely * window._h
		local absw = w.width * window._w
		local absh = w.height * window._h
		local left = self.left * window._w
		local right = self.right * window._w
		local top = self.top * window._h
		if x > absx-left and x < absx+absw+right and y > absy-top and y < absy+top then
			cursor.set("drag grab")
			return
		end
	end
end

function on.grabUp(x,y)
	if window._moving ~= nil then
		local w = window._moving
		local self = w.decoration
		local absx = w.relx * window._w
		local absy = w.rely * window._h
		local absw = w.width * window._w
		local absh = w.height * window._h
		local left = self.left * window._w
		local right = self.right * window._w
		local top = self.top * window._h
		if absx-left < 0 then
			w.relx = self.left
		end
		if absy-top < 0 then
			w.rely = self.top
		end
		window._moving = nil
		cursor.set("default")
		platform.window:invalidate()
		return
	end
	for i,w in ipairs(window._windows) do
		local self = w.decoration
		local absx = w.relx * window._w
		local absy = w.rely * window._h
		local absw = w.width * window._w
		local absh = w.height * window._h
		local left = self.left * window._w
		local right = self.right * window._w
		local top = self.top * window._h
		if x > absx-left and x < absx+absw+right and y > absy-top and y < absy+top then
			window._moving = w
			window._grabx = x - (absx)
			window._graby = y - (absy)
			cursor.set("drag grab")
			return
		end
	end
end


function on.mouseDown(x,y)
	
end

function on.mouseUp(x,y)
	
end

function on.mouseMove(x,y)
	if window._moving ~= nil then
		window._moving.relx = (x - window._grabx) / window._w
		window._moving.rely = (y - window._graby) / window._h
		platform.window:invalidate()
	end
end


function on.input()
	
	
	
	
	platform.window:invalidate()
end


function on.paint(gc)
	if window._initialized == false then
		window._w = platform.window:width()
		window._h = platform.window:height()
		window._initialized = true
	end
	gc:setColorRGB(255,255,255)
	gc:fillRect(0,0,window._w,window._h)
	for i,w in ipairs(window._windows) do
		w.decoration:paint(gc,w)
	end
end













---  end window manager library  ---
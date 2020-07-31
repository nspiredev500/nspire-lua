---  TI-Lua window manager library by nspiredev500  ---
--[[
	This is a window manager library.
	It requires my input library.
	
	
	
	
	
	
]]--


window = {}
window.window = class()
window.decoration = class()
window.button = class()
window.label = class()
window.textField = class()
window.textEditor = class()
window.bare = class(decoration)
window._initialized = false
window._w = 0
window._h = 0
window._windows = {}
window._moving = nil
window._grabx = 0
window._graby = 0

function window._setVisible(self,vis)
	self.visible = vis
end
function window._recomputeSize(self,gc)
	self.width = gc:getStringWidth(self.text)
	self.height = gc:getStringHeight(self.text)
end
function window.button:init(x,y,text,onPress)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	self.visible = true
	self.x = x
	self.y = y
	self.text = text
	self.onPress = onPress
	platform.withGC(window._recomputeSize,self)
end
window.button.setVisible = window._setVisible
function window.button:paint(w,gc)
	gc:setColorRGB(0,0,0)
	gc:drawRect(w.x+self.x,w.y+self.y,self.width,self.height)
	gc:drawString(self.text,w.x+self.x,w.y+self.y,"top")
end
function window.button:event(e,d,a,p,w,l,m,x,y)
	if e == "mouseup" then
		self.onPress()
	end
end
function window.label:init(x,y,text)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	self.visible = true
	self.x = x
	self.y = y
	if text == nil then
		self.text = ""
	else
		self.text = tostring(x,y,text)
	end
	platform.withGC(window._recomputeSize,self)
end
function window.label:paint(w,gc)
	gc:setColorRGB(0,0,0)
	gc:drawString(self.text,w.x+self.x,w.y+self.y,"top")
end
function window.label:event(e,d,a,p,w,l,m,x,y)
end
function window.textField:init(x,y,text,width,height)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	self.visible = true
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	if text == nil then
		self.text = ""
	else
		self.text = tostring(text)
	end
end
function window.textEditor:init(x,y,text,width,height)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	self.visible = true
	self.width = width
	self.height = height
	self.x = x
	self.y = y
	if text == nil then
		self.text = ""
	else
		self.text = tostring(text)
	end
end


function window.window:init(x,y,width,height,visible,name,decoration)
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	self.components = {}
	self.width = width
	self.height = height
	self.x = x
	self.y = y
	self.fullscreen = false
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
		self.decoration = window.decoration(20,1,1,1)
	else
		self.decoration = decoration
	end
	table.insert(window._windows,self)
	window._focused = self
end

function window.window:add(c)
	table.insert(self.components,c)
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

function window.window:setFullscreen(full)
	self.fullscreen = full
	if full == true then
		self.x = 0
		self.y = 0
		self.width = window._w
		self.h = window._h
	end
end

function window.window:setPosition(x,r)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	self.x = x
	self.y = y
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
	if window._focused == self then
		window._focused = nil
	end
	for i,j in ipairs(window._windows) do
		if j == self then
			table.remove(window._windows,i)
			return
		end
	end
end

function window.window:paint(gc)
	gc:setColorRGB(255,255,255)
	gc:fillRect(self.x,self.y,self.width,self.height)
	for i,j in ipairs(self.components) do
		if j.visible == true then
			j:paint(self,gc)
		end
	end
end

function window.window:event(e,d,a,p,w,l,m,x,y)
	if m == true then
		for i,j in ipairs(self.components) do
			if x >= self.x+j.x and x <= self.x+j.x+j.width and y >= self.y+j.y and y <= self.y+j.y+j.height then
				j:event(e,d,a,p,w,l,m,x-self.x,y-self.y)
				return
			end
		end
	else
		if self.focused ~= nil then
			self.focused:event(e,d,a,p,w,l,m,x,y)
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
	gc:fillRect(w.x-self.left,w.y-self.top,self.left,w.height+self.top+self.bottom)
	gc:fillRect(w.x+w.width,w.y-self.top,self.right,w.height+self.top+self.bottom)
	
	gc:fillRect(w.x-self.left,w.y+w.height,w.width+self.left+self.right,self.bottom)
	gc:drawRect(w.x-self.left,w.y-self.top,w.width+self.left,self.top-1)
	
	gc:setColorRGB(self.r,self.g,self.b)
	gc:fillRect(w.x,w.y-self.top+1,w.width,self.top-2)
	
	gc:setColorRGB(0,0,0)
	gc:drawString(w.name,w.x,w.y-self.top,"top")
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
	
	
	
	
end

function on.grabDown(x,y)
	
end

function on.grabUp(x,y)
	if window._moving ~= nil then
		local w = window._moving
		local self = w.decoration
		if w.x-self.left < 0 then
			w.x = self.left
		end
		if w.y-self.top < 0 then
			w.y = self.top
		end
		window._moving = nil
		cursor.set("default")
		platform.window:invalidate()
		return
	end
	for i = #window._windows, 1, -1 do
		local w = window._windows[i]
		local self = w.decoration
		if x > w.x-self.left and x < w.x+w.width+self.right and y > w.y-self.top and y < w.y then
			window._moving = w
			window._grabx = x - w.x
			window._graby = y - w.y
			table.remove(window._windows,i)
			table.insert(window._windows,w)
			cursor.set("drag grab")
			platform.window:invalidate()
			return
		end
	end
end


function on.mouseDown(x,y)
	
end

function on.mouseUp(x,y)
	for i = #window._windows, 1, -1 do
		local w = window._windows[i]
		if x >= w.x and x <= w.x+w.width and y >= w.y and y <= w.y+w.height then
			window._focused = w
			w:event("mouseup",false,false,false,false,string.len("mouseup"),true,x,y)
			platform.window:invalidate()
			return
		end
	end
	window._focused = nil
end

function on.mouseMove(x,y)
	if window._moving ~= nil then
		window._moving.x = x - window._grabx
		window._moving.y = y - window._graby
		platform.window:invalidate()
	end
end


function on.input(e,d,a,p,w,l)
	if window._focused ~= nil then
		window._focused:event(e,d,a,p,w,l,false,0,0)
		platform.window:invalidate()
	end
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
		if not w.fullscreen == true then
			w.decoration:paint(gc,w)
		end
		w:paint(gc)
	end
end













---  end window manager library  ---
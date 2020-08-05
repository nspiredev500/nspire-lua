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
window._damaged = {}

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
function window.button:event(e,d,a,p,w,l,m,x,y,win)
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
function window.label:event(e,d,a,p,w,l,m,x,y,win)
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
	self.cursor = 0
	self.scroll = 0
	if text == nil then
		self.text = ""
	else
		self.text = tostring(text)
	end
end
function window.textField:paint(w,gc)
	gc:setColorRGB(0,0,0)
	gc:drawRect(w.x+self.x,w.y+self.y,self.width,self.height)
	gc:clipRect("set",w.x+self.x,w.y+self.y,self.width,self.height)
	gc:drawString(self.text,w.x+self.x+2+self.scroll,w.y+self.y,"top")
	local scr = gc:getStringWidth(self.text:sub(1,self.cursor))
	gc:fillRect(w.x+self.x+scr+2+self.scroll,w.y+self.y+2,1,self.height-4)
	gc:clipRect("reset")
end
function window.textField._adjustScroll(self,gc)
	local w = gc:getStringWidth(self.text:sub(1,self.cursor)) + self.scroll + 3
	if w > self.width then
		self.scroll = self.scroll - (w - self.width) - 1
	end
	if w - gc:getStringWidth(self.text:sub(self.cursor,self.cursor)) < 2 then
		self.scroll = self.scroll - w + gc:getStringWidth(self.text:sub(self.cursor,self.cursor)) + 3
	end
end
function window.textField:event(e,d,a,p,w,l,m,x,y,win)
	if l == 1 then
		self.text = self.text:sub(1,self.cursor) .. e .. self.text:sub(self.cursor+1)
		self.cursor = self.cursor + 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "bsp" then
		local c = self.cursor - 1
		if c < 0 then
			c = 0
		end
		self.text = self.text:sub(1,c) .. self.text:sub(self.cursor+1)
		self.cursor = self.cursor - 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "left" then
		self.cursor = self.cursor - 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "right" then
		self.cursor = self.cursor + 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if self.cursor < 0 then
		self.cursor = 0
	end
	if self.cursor > self.text:len() then
		self.cursor = self.text:len()
	end
	platform.withGC(window.textField._adjustScroll,self)
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
	self.cursor = 0
	self.scroll = 0
	self.scrollline = 0
	self.line = 1
	self.text = {}
	if text == nil then
		self.text[1] = ""
	else
		self.text[1] = tostring(text)
	end
end
function window.textEditor:paint(w,gc)
	gc:setColorRGB(0,0,0)
	gc:drawRect(w.x+self.x,w.y+self.y,self.width,self.height)
	gc:clipRect("set",w.x+self.x,w.y+self.y,self.width,self.height)
	local h = 0
	local lineh = -100
	for i, j in ipairs(self.text) do
		if i > self.scrollline then
			gc:drawString(j,w.x+self.x+2+self.scroll,w.y+self.y+h,"top")
			if i == self.line then
				lineh = h
			end
			h = h + gc:getStringHeight(j)
		end
	end
	local scr = gc:getStringWidth(self.text[self.line]:sub(1,self.cursor))
	gc:fillRect(w.x+self.x+scr+2+self.scroll,w.y+self.y+lineh+2,1,gc:getStringHeight(self.text[self.line])-4)
	gc:clipRect("reset")
end
function window.textEditor._adjustScroll(self,gc)
	local w = gc:getStringWidth(self.text[self.line]:sub(1,self.cursor)) + self.scroll + 3
	if w > self.width then
		self.scroll = self.scroll - (w - self.width) - 1
	end
	if w - gc:getStringWidth(self.text[self.line]:sub(self.cursor,self.cursor)) < 2 then
		self.scroll = self.scroll - w + gc:getStringWidth(self.text[self.line]:sub(self.cursor,self.cursor)) + 3
	end
	if self.line <= self.scrollline then
		self.scrollline = self.line - 1
	end
	local lineh = -100
	local h = 0
	for i, j in ipairs(self.text) do
		if i > self.scrollline then
			if i == self.line then
				lineh = h
			end
			h = h + gc:getStringHeight(j)
		end
	end
	if lineh + gc:getStringWidth(self.text[self.line]) > self.height then
		local lines = 0
		local h = 0
		for i, j in ipairs(self.text) do
			if i > self.scrollline then
				h = h + gc:getStringHeight(j)
				lines = lines + 1
				if h >= lineh + gc:getStringWidth(self.text[self.line]) - self.height then
					self.scrollline = self.scrollline + lines
					return
				end
			end
		end
	end
end
function window.textEditor:event(e,d,a,p,w,l,m,x,y,win)
	if l == 1 then
		self.text[self.line] = self.text[self.line]:sub(1,self.cursor) .. e .. self.text[self.line]:sub(self.cursor+1)
		self.cursor = self.cursor + 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "bsp" then
		local c = self.cursor - 1
		if c < 0 then
			c = 0
		end
		if self.cursor == 0 and self.line ~= 1 then
			self.line = self.line - 1
			self.cursor = self.text[self.line]:len()
			self.text[self.line] = self.text[self.line] .. self.text[self.line+1]
			table.remove(self.text,self.line+1)
		else
			self.text[self.line] = self.text[self.line]:sub(1,c) .. self.text[self.line]:sub(self.cursor+1)
			self.cursor = self.cursor - 1
		end
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "enter" then
		table.insert(self.text,self.line+1,self.text[self.line]:sub(self.cursor+1))
		self.text[self.line] = self.text[self.line]:sub(1,self.cursor)
		self.cursor = 0
		self.line = self.line + 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "up" then
		if self.line > 1 then
			self.line = self.line - 1
			window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
		end
	end
	if e == "down" then
		if self.line < #self.text then
			self.line = self.line + 1
			window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
		end
	end
	if e == "left" then
		self.cursor = self.cursor - 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if e == "right" then
		self.cursor = self.cursor + 1
		window._damage(win.x+self.x,win.y+self.y,self.width,self.height)
	end
	if self.cursor < 0 then
		if self.line ~= 1 then
			self.line = self.line - 1
			self.cursor = self.text[self.line]:len()
		else
			self.cursor = 0
		end
	end
	if self.cursor > self.text[self.line]:len() then
		if self.line < #self.text then
			self.cursor = 0
			self.line = self.line +1
		else
			self.cursor = self.text[self.line]:len()
		end
	end
	platform.withGC(window.textEditor._adjustScroll,self)
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
	local w = self
	local d = w.decoration
	window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
end

function window.window:add(c)
	table.insert(self.components,c)
	window._damage(self.x+c.x,self.y+c.y,c.width,c.height)
end
function window.window:visible()
	return self.visible
end

function window.window:setVisible(visible)
	if visible then
		if self.visible ~= true then
			self.visible = true
			local w = self
			local d = w.decoration
			window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
		end
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
	window._damage(0,0,window._w,window._h)
end

function window.window:setPosition(x,r)
	assert(tonumber(x),"window: x has to be a number")
	assert(tonumber(y),"window: y has to be a number")
	local w = self
	local d = w.decoration
	window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
	self.x = x
	self.y = y
	window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
end

function window.window:setSize(width,height)
	assert(tonumber(width),"window: width has to be a number")
	assert(tonumber(height),"window: height has to be a number")
	local w = self
	local d = w.decoration
	window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
	self.width = width
	self.height = height
	window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
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
			local w = self
			local d = w.decoration
			window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
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

function window.window:focus(c)
	for i,j in ipairs(self.components) do
		if j == c then
			self.focused = j
			return
		end
	end
end

function window.window:event(e,d,a,p,w,l,m,x,y)
	if m == true then
		for i,j in ipairs(self.components) do
			if x >= self.x+j.x and x <= self.x+j.x+j.width and y >= self.y+j.y and y <= self.y+j.y+j.height then
				self.focused = j
				j:event(e,d,a,p,w,l,m,x-self.x,y-self.y,self)
				return
			end
		end
	else
		if self.focused ~= nil and self.focused.visible == true then
			self.focused:event(e,d,a,p,w,l,m,x,y,self)
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
	window._damage(0,0,window._w,window._h) -- the decoration doesn't know where the window is, so do a full redraw
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
		return
	end
	for i = #window._windows, 1, -1 do
		local w = window._windows[i]
		local self = w.decoration
		if x > w.x-self.left and x < w.x+w.width+self.right and y > w.y-self.top and y < w.y then
			window._moving = w
			window._grabx = x - w.x
			window._graby = y - w.y
			if i ~= #window._windows then
				table.remove(window._windows,i)
				table.insert(window._windows,w)
				local d = w.decoration
				window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
			end
			cursor.set("drag grab")
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
			if i ~= #window._windows then
				table.remove(window._windows,i)
				table.insert(window._windows,w)
				local d = w.decoration
				window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
			end
			w:event("mouseup",false,false,false,false,string.len("mouseup"),true,x,y)
			return
		end
	end
	window._focused = nil
end

function window.focus(w)
	for i,j in ipairs(window._windows) do
		if j == w then
			window._focused = j
			if i ~= #window._windows then
				table.remove(window._windows,i)
				table.insert(window._windows,w)
				local d = w.decoration
				window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
			end
			return
		end
	end
end
function window._damage(x,y,w,h)
	if w == nil then
	error("damage width == nil",2)
	end
	table.insert(window._damaged,{x = x, y = y, w = w, h = h})
	platform.window:invalidate(x,y,w,h)
end

function on.mouseMove(x,y)
	if window._moving ~= nil then
		local w = window._moving
		local oldx = w.x
		local oldy = w.y
		window._moving.x = x - window._grabx
		window._moving.y = y - window._graby
		local d = w.decoration
		window._damage(w.x-d.left,w.y-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
		window._damage(oldx-d.left,oldy-d.top,w.width+d.left+d.right,w.height+d.top+d.bottom)
	end
end


function on.input(e,d,a,p,w,l)
	if window._focused ~= nil and window._focused.visible == true then
		window._focused:event(e,d,a,p,w,l,false,0,0)
	end
end
function on.paint(gc)
	if window._initialized == false then
		window._w = platform.window:width()
		window._h = platform.window:height()
		window._initialized = true
		window._damage(0,0,window._w,window._h)
	end
	for i, j in ipairs(window._damaged) do
		local x = j.x
		local y = j.y
		local w = j.w
		local h = j.h
		for k, l in ipairs(window._windows) do
			local d = l.decoration
			if (not (x >= l.x + l.width + d.right or l.x - d.left >= x + w)) and (not (y >= l.y + l.height + d.bottom or l.y - d.top >= y + h)) then
				if not l.fullscreen == true then
					l.decoration:paint(gc,l)
				end
				l:paint(gc)
			end
		end
	end
	if #window._damaged == 0 then
		for i,w in ipairs(window._windows) do
			if not w.fullscreen == true then
				w.decoration:paint(gc,w)
			end
			w:paint(gc)
		end
	end
	window._damaged = {}
	--[[
	gc:setColorRGB(255,255,255)
	gc:fillRect(0,0,window._w,window._h)
	for i,w in ipairs(window._windows) do
		if not w.fullscreen == true then
			w.decoration:paint(gc,w)
		end
		w:paint(gc)
	end
	]]--
end













---  end window manager library  ---
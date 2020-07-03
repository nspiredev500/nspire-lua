nrequire "io"
local f = io.open("/documents/iotest.tns","w");
f:write("Hello world from my lua io module!");
f:close();
io.write("Hello to c stdout");
io.flush();
f = io.open("/documents/iotest.tns","r");
io.write("reading from the file:\n");
readstring = f:read(100);
io.write(readstring);


function on.construction()
	io.write("construction")
	
	
	platform.window:invalidate();
end


function on.enterKey()
	io.write("enter pressed");
	platform.window:invalidate();
end


function on.paint(gc)
	
	gc:setColorRGB(255,255,255);
	gc:fillRect(0,0,320,240);
	
	gc:setColorRGB(0,0,0);
	gc:drawString(readstring,0,100);
	
	
	
end






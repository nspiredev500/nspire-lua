nrequire "io"
local f = io.open("/documents/iotest.tns","w");
f:write("Hello world from my lua io module!");
f:close();
io.write("Hello to c stdout");
io.flush();



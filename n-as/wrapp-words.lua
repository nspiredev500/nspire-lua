local r = io.open("architecture.xml","r")
local text = r:read("a")
local o = io.open("architecture-wrapped.xml","w")
o:write("<r2dtotree version=\"1\">\n")
o:write("<formatManager tableSize=\"2\" capacity=\"10\">;\n")
o:write("		<formatEntry entryIndex=\"0\" entryID=\"0\" entryRefCnt=\"2147483647\" tc=\"1\" fc=\"268435199\" fs=\"11\" fst=\"1\" cc=\"0\" fest=\"0\" feun=\"0\" fesub=\"0\" fesup=\"0\" fn0=\"TI-Nspire Sans\"></formatEntry>\n")
o:write("		<formatEntry entryIndex=\"1\" entryID=\"1\" entryRefCnt=\"2147483647\" tc=\"1\" fc=\"268435199\" fs=\"10\" fst=\"0\" cc=\"0\" fest=\"0\" feun=\"0\" fesub=\"0\" fesup=\"0\" fn0=\"TI-Nspire Sans\"></formatEntry>\n")
o:write("</formatManager>\n")
o:write("<node name=\"1doc\"><node name=\"1para\"><node name=\"1rtline\"><leaf name=\"1word\" np=\"1\" id0=\"0\" pp0=\"12\" ucf=\"1\">Architecture</leaf></node></node>")
for line in text:gmatch("([^\n]*)(\n?)") do
	o:write("<node name=\"1para\"><node name=\"1rtline\">")
	for word in line:gmatch("([^%s]*)(%s?)") do
		o:write("<leaf name=\"1word\" np=\"1\" id0=\"1\" pp0=\"")
		o:write(word:len()+1)
		o:write("\" ucf=\"1\">")
		o:write(word)
		o:write(" ")
		o:write("</leaf>")
	end
	o:write("</node></node>")
end
o:write("</node>\n</r2dtotree>")
r = io.open("instruction-list.xml","r")
text = r:read("a")
o = io.open("instruction-list-wrapped.xml","w")
o:write("<r2dtotree version=\"1\">\n")
o:write("<formatManager tableSize=\"2\" capacity=\"10\">;\n")
o:write("		<formatEntry entryIndex=\"0\" entryID=\"0\" entryRefCnt=\"2147483647\" tc=\"1\" fc=\"268435199\" fs=\"11\" fst=\"1\" cc=\"0\" fest=\"0\" feun=\"0\" fesub=\"0\" fesup=\"0\" fn0=\"TI-Nspire Sans\"></formatEntry>\n")
o:write("		<formatEntry entryIndex=\"1\" entryID=\"1\" entryRefCnt=\"2147483647\" tc=\"1\" fc=\"268435199\" fs=\"7\" fst=\"0\" cc=\"0\" fest=\"0\" feun=\"0\" fesub=\"0\" fesup=\"0\" fn0=\"TI-Nspire Sans\"></formatEntry>\n")
o:write("</formatManager>\n")
o:write("<node name=\"1doc\"><node name=\"1para\"><node name=\"1rtline\"><leaf name=\"1word\" np=\"1\" id0=\"0\" pp0=\"12\" ucf=\"1\">Instructions</leaf></node></node>")
for line in text:gmatch("([^\n]*)(\n?)") do
	o:write("<node name=\"1para\"><node name=\"1rtline\">")
	for word in line:gmatch("([^%s]*)(%s?)") do
		o:write("<leaf name=\"1word\" np=\"1\" id0=\"1\" pp0=\"")
		o:write(word:len()+1)
		o:write("\" ucf=\"1\">")
		o:write(word)
		o:write(" ")
		o:write("</leaf>")
	end
	o:write("</node></node>")
end
o:write("</node>\n</r2dtotree>")
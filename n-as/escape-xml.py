from xml.sax.saxutils import escape
with open("n-as.lua","r") as f:
	n_as = f.read()
with open("n-as-escaped.lua","w") as f:
	f.write(escape(n_as))
with open("instructions.lua","r") as f:
	n_as = f.read()
with open("instructions-escaped.lua","w") as f:
	f.write(escape(n_as))
with open("libs.lua","r") as f:
	n_as = f.read()
with open("libs-escaped.lua","w") as f:
	f.write(escape(n_as,{"\"": "&quot;&quot;"}))
with open("architecture-wrapped.xml","r") as f:
	n_as = f.read()
with open("architecture-wrapped-escaped.xml","w") as f:
	f.write(escape(n_as))
with open("instruction-list-wrapped.xml","r") as f:
	n_as = f.read()
with open("instruction-list-wrapped-escaped.xml","w") as f:
	f.write(escape(n_as))
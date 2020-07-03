#include <os.h>
#include <lauxlib.h>
#include <nucleus.h>
#include <lua.h>
#include <string.h>


/// for freeing resources https://www.lua.org/pil/29.html

const char* lua_file_type = "ndless_io_file";



int lua_file_object_flush(lua_State *L);	
int lua_file_object_lines(lua_State *L);
int lua_file_object_read(lua_State *L);
int lua_file_object_write(lua_State *L);


struct lua_file {
	FILE* file;
	bool closed;
	bool read; // else it is opened for writing
	bool remove_on_close;
	char* path; // the path to the file if remove_on_close is true
};

int lua_file_error(lua_State *L, const char* reason,int err)
{
	luaL_checkstack(L,3,"not enough space on the Lua stack!");
	lua_pushnil(L);
	lua_pushstring(L,reason);
	lua_pushinteger(L,err);
	return 3;
}

int lua_file_create(lua_State *L,const char* path, const char* mode)
{
	luaL_checkstack(L,2,"not enough space on the Lua stack!");
	switch (strlen(mode))
	{
		default:
		case 0:
			return lua_file_error(L,"io currently only supports these modes \"r\", \"w\", \"rb\", \"wb\"",-1);
			break;
		case 1:
			if (mode[0] != 'r' && mode[0] != 'w')
			{
				return lua_file_error(L,"io currently only supports these modes \"r\", \"w\", \"rb\", \"wb\"",-1);
			}
			break;
		case 2:
			if ((mode[0] != 'r' && mode[0] != 'w') || mode[1] != 'b')
			{
				return lua_file_error(L,"io currently only supports these modes \"r\", \"w\", \"rb\", \"wb\"",-1);
			}
			break;
	}
	struct lua_file* f = lua_newuserdata(L,sizeof(struct lua_file));
	f->file = NULL; // in case rawgeti or setmetatable fail, open the file after calling them
	f->closed = false;
	f->remove_on_close = false;
	if (mode[0] == 'r')
	{
		f->read = true;
	}
	else
	{
		f->read = false;
	}
	
	luaL_getmetatable(L,lua_file_type);
	lua_setmetatable(L,-2);
	
	
	f->file = fopen(path,mode);
	if (f->file == NULL)
	{
		lua_remove(L,-1); // remove the file from the stack, because it's invalid
		return lua_file_error(L,"could not open the file",-1);
	}
	// user has to do it manually, this sets them back to the file browser
	/*
	if (! f->read)
	{
		refresh_osscr();
	}
	*/
	return 1;
}

// only used to make stdin, stdout and stderr
void init_lua_file(lua_State *L,NUC_FILE* file,bool read)
{
	luaL_checkstack(L,2,"not enough space on the Lua stack!");
	struct lua_file* f = lua_newuserdata(L,sizeof(struct lua_file));
	
	f->file = NULL;// in case getmetatable or setmetatable fail, set the file after calling them
	f->closed = false;
	f->remove_on_close = false;
	f->read = read;
	
	luaL_getmetatable(L,lua_file_type);
	lua_setmetatable(L,-2);
	
	
	f->file = file;
}

bool is_lua_file(lua_State *L)
{
	if (luaL_checkudata(L,1,lua_file_type) != NULL)
	{
		return true;
	}
	return false;
}

int lua_close_file(lua_State *L)
{
	//printf("closing file from lua ore running destructor\n");
	if (lua_gettop(L) == 0)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		lua_getglobal(L,"io");
		lua_getfield(L,-1,"stdout");
		lua_remove(L,-2);
		return lua_close_file(L);
	}
	if (lua_gettop(L) > 1)
	{
		return lua_file_error(L,"io.close expects one argument",-1);
	}
	if (lua_gettop(L) == 1 && is_lua_file(L))
	{
		struct lua_file* f = lua_touserdata(L,1);
		if (f == NULL)
		{
			return 0;
		}
		if (f->file != stdin && f->file != stdout && f->file != stderr && f->closed == false)
		{
			//printf("closing file\n");
			f->closed = true;
			fclose(f->file);
		}
		return 0;
	}
	return lua_file_error(L,"the argument of io.close has to be a file",-1);
}
int lua_flush_file(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		lua_getglobal(L,"io");
		lua_getfield(L,-1,"stdout");
		lua_remove(L,-2);
		return lua_file_object_flush(L);
	}
	return lua_file_error(L,"io.flush expects no arguments",-1);
}
int lua_input(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		lua_getglobal(L,"io");
		lua_getfield(L,-1,"stdin");
		lua_remove(L,-2);
		return 1;
	}
	if (lua_gettop(L) == 1)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		if (is_lua_file(L))
		{
			lua_getglobal(L,"io");
			lua_insert(L,1);
			lua_setfield(L,-2,"stdin");
			lua_remove(L,-1);
			return 0;
		}
		else
		{
			return luaL_error(L,"io.input expects a file");
			return lua_file_error(L,"io.flush expects no arguments",-1);
		}
	}
	return luaL_error(L,"io.input expect one argument");
}
int lua_lines(lua_State *L)
{
	return luaL_error(L,"io.lines currently not supported");
}
int lua_open_file(lua_State *L)
{
	static const char *defmode = "r";
	if (lua_gettop(L) == 1)
	{
		const char* path = lua_tostring(L,1);
		if (path == NULL)
		{
			return lua_file_error(L,"io.open: the path has to be a string",-1);
		}
		lua_file_create(L,path,defmode);
		return 1;
	}
	if (lua_gettop(L) == 2)
	{
		const char* path = lua_tostring(L,1);
		if (path == NULL)
		{
			return lua_file_error(L,"io.open: the path has to be a string",-1);
		}
		const char* mode = lua_tostring(L,2);
		if (mode == NULL)
		{
			return lua_file_error(L,"io.open: the mode has to be a string",-1);
		}
		lua_file_create(L,path,mode);
		return 1;
	}
	return lua_file_error(L,"io.open expects a path and optionally a mode string",-1);
}
int lua_output(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		lua_getglobal(L,"io");
		lua_getfield(L,-1,"stdout");
		lua_remove(L,-2);
		return 1;
	}
	if (lua_gettop(L) == 1)
	{
		luaL_checkstack(L,2,"not enough space on the Lua stack!");
		if (is_lua_file(L))
		{
			lua_getglobal(L,"io");
			lua_insert(L,1);
			lua_setfield(L,-2,"stdout");
			lua_remove(L,-1);
			return 0;
		}
		else
		{
			return luaL_error(L,"io.output expects a file");
		}
	}
	return luaL_error(L,"io.output expect one argument");
}
int lua_io_popen(lua_State *L)
{
	return lua_file_error(L,"io.popen is currently not supported",-1);
}
int lua_read_file(lua_State *L)
{
	luaL_checkstack(L,2,"not enough space on the Lua stack!");
	lua_getglobal(L,"io");
	lua_getfield(L,-1,"stdin");
	lua_remove(L,-2);
	lua_insert(L,1);
	return lua_file_object_read(L);
}
int lua_tmpfile(lua_State *L)
{
	return 0;
	// generate a name
	char buff[150];
	while (true)
	{
		struct stat st;
		memset(buff,'\0',150);
		sprintf(buff,"/documents/%.20d.tns",rand());
		if (stat(buff,&st) != 0) // if stat fails, the file doesn't exist
		{
			break;
		}
	}
	
}
int lua_io_type(lua_State *L)
{
	if (lua_gettop(L) == 1)
	{
		luaL_checkstack(L,1,"not enough space on the Lua stack!");
		if (is_lua_file(L))
		{
			struct lua_file* f = lua_touserdata(L,1);
			if (f->closed)
			{
				lua_pushstring(L,"closed file");
				return 1;
			}
			else
			{
				lua_pushstring(L,"file");
				return 1;
			}
		}
		else
		{
			lua_pushnil(L);
			return 1;
		}
	}
	return luaL_error(L,"io.type expects one argument");
}
int lua_write_file(lua_State *L)
{
	luaL_checkstack(L,2,"not enough space on the Lua stack!");
	lua_getglobal(L,"io");
	lua_getfield(L,-1,"stdout");
	lua_remove(L,-2);
	lua_insert(L,1);
	return lua_file_object_write(L);
}

int lua_file_object_seek(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		return lua_file_error(L,"file:seek needs at least the file as an argument",-1);
	}
	if (lua_gettop(L) > 3)
	{
		return lua_file_error(L,"too many arguments to file_seek",-1);
	}
	if (is_lua_file(L))
	{
		int pos = SEEK_CUR;
		int offset = 0;
		struct lua_file *f = lua_touserdata(L,1);
		if (f->closed)
		{
			return lua_file_error(L,"file already closed",-1);
		}
		if (lua_gettop(L) >= 2)
		{
			const char *tmp = lua_tostring(L,2);
			if (tmp != NULL)
			{
				if (strcmp(tmp,"set") == 0)
				{
					pos = SEEK_SET;
				}
				if (strcmp(tmp,"cur") == 0)
				{
					pos = SEEK_CUR;
				}
				if (strcmp(tmp,"end") == 0)
				{
					pos = SEEK_END;
				}
			}
		}
		if (lua_gettop(L) == 3)
		{
			offset = lua_tonumber(L,3);
		}
		fseek(f->file,offset,pos);
	}
	return lua_file_error(L,"the first argument to file:seek has to be a file",-1);
}
int lua_file_object_setvbuf()
{
	return 0; // the buffer is in newlib, nothing  to do here
}
int lua_file_object_flush(lua_State *L)
{
	if (lua_gettop(L) != 1)
	{
		return lua_file_error(L,"file:flush expects one argument",-1);
	}
	if (lua_gettop(L) == 1 && is_lua_file(L))
	{
		luaL_checkstack(L,1,"not enough space on the Lua stack!");
		struct lua_file* f = lua_touserdata(L,1);
		if (f == NULL)
		{
			return 0;
		}
		if (f->closed == false && f->read == false)
		{
			fflush(f->file);
		}
		return 0;
	}
	return lua_file_error(L,"the argument of file:flush has to be a file",-1);
}
int lua_file_object_lines(lua_State *L)
{
	return luaL_error(L,"file:lines currently not supported");
}
int lua_file_object_read(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		return lua_file_error(L,"file:read needs a file as first argument",-1);
	}
	if (is_lua_file(L))
	{
		struct lua_file *f = lua_touserdata(L,1);
		if (f->closed)
		{
			return lua_file_error(L,"file:read: file already closed",-1);
		}
		if (! f->read)
		{
			return lua_file_error(L,"file:read: file opened for writing",-1);
		}
		
	}
	return lua_file_error(L,"file:read needs a file as first argument",-1);
}
int lua_file_object_write(lua_State *L)
{
	//uart_printf("file:write arguments: %d\n",lua_gettop(L));
	//uart_printf("udata: %p\n",luaL_checkudata(L,1,lua_file_type));
	if (lua_gettop(L) == 0)
	{
		return lua_file_error(L,"file:write needs a file as first argument, but no arguments are passed",-1);
	}
	if (is_lua_file(L))
	{
		struct lua_file *f = lua_touserdata(L,1);
		if (f->closed)
		{
			return lua_file_error(L,"file:write: file already closed",-1);
		}
		if (f->read)
		{
			return lua_file_error(L,"file:write: file opened for reading",-1);
		}
		for (int i = 2; i <= lua_gettop(L);i++) // gettop() is the last usable index
		{
			const char* str = lua_tostring(L,i);
			if (str == NULL)
			{
				return lua_file_error(L,"file:write needs arguments that are convertible to strings",-1);
			}
			fwrite(str,1,strlen(str),f->file);
		}
		return 0;
	}
	return lua_file_error(L,"file:write needs a file as first argument",-1);
}

static const luaL_reg lualib[] = {
	{"close", lua_close_file},
	{"flush", lua_flush_file},
	{"input", lua_input},
	{"lines", lua_lines},
	{"open", lua_open_file},
	{"output", lua_output},
	{"popen", lua_io_popen},
	{"read", lua_read_file},
	{"tmpfile", lua_tmpfile},
	{"type", lua_io_type},
	{"write", lua_write_file},
	{NULL, NULL}
};

int main(void) {
	lua_State *L = nl_lua_getstate();
	if (!L) return 0;
	luaL_checkstack(L,8,"not enough space on the Lua stack!");
	luaL_register(L, "io", lualib);
	printf("\n");
	// construct the metatable for all files now
	luaL_newmetatable(L,lua_file_type);
	lua_pushcfunction(L,lua_close_file);
	lua_setfield(L,-2,"__gc");
	
	lua_pushstring(L,"cannot access the metatable of files");
	lua_setfield(L,-2,"__metatable");
	
	lua_newtable(L); // now construct the __index table for all files
	
	lua_pushcfunction(L,lua_close_file);
	lua_setfield(L,-2,"close");
	
	lua_pushcfunction(L,lua_file_object_read);
	lua_setfield(L,-2,"read");
	
	lua_pushcfunction(L,lua_file_object_write);
	lua_setfield(L,-2,"write");
	
	lua_pushcfunction(L,lua_file_object_seek);
	lua_setfield(L,-2,"seek");
	
	lua_pushcfunction(L,lua_file_object_setvbuf);
	lua_setfield(L,-2,"setvbuf");
	
	lua_pushcfunction(L,lua_file_object_lines);
	lua_setfield(L,-2,"lines");
	
	lua_pushcfunction(L,lua_file_object_flush);
	lua_setfield(L,-2,"flush");
	
	
	lua_setfield(L,-2,"__index"); // set it as __index
	
	
	
	
	
	
	
	
	lua_getglobal(L,"io");
	// now make stdin, stdout and stderr visible to Lua
	
	init_lua_file(L,stdin,true);
	lua_setfield(L,-2,"stdin");
	
	init_lua_file(L,stdout,false);
	//printf("udata: %p\n",luaL_checkudata(L,-1,lua_file_type));
	lua_setfield(L,-2,"stdout");
	
	init_lua_file(L,stderr,false);
	lua_setfield(L,-2,"stderr");
	
	
	return 0;
}

#include <stdint.h>
#include <stdbool.h>

#include <os.h>
#include <lauxlib.h>
#include <nucleus.h>
#include <lua.h>


static time_t starting_time = 0;


int lua_clock(lua_State *L)
{
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	lua_pushinteger(L,(int32_t) (time(NULL)-starting_time));
	return 1;
}

int lua_date(lua_State *L)
{
	int args = lua_gettop(L);
	const char *default_format = "%a %b %d %H:%M:%S %Y";
	const char *format = default_format;
	time_t time_sec = time(NULL);
	if (args > 0)
	{
		if (lua_isstring(L,1))
		{
			format = lua_tostring(L,1);
		}
		else
		{
			return luaL_error(L,"the first argument of os.date has to be a string");
		}
	}
	if (args > 1)
	{
		if (lua_isnumber(L,2))
		{
			time_sec = lua_tonumber(L,2);
		}
		else
		{
			return luaL_error(L,"the second argument of os.date has to be a number");
		}
	}
	if (args > 2)
	{
		return luaL_error(L,"too many arguments for os.date: %d",args);
	}
	int index = 0;
	if (strlen(format) != 0)
	{
		if (format[0] == '!')
		{
			index++;
		}
	}
	struct tm *time_str = localtime(&time_sec);
	char buffer[150];
	memset(buffer,'\0',150);
	if (strlen(format+index) >= 2)
	{
		if (format[index] == '*' && format[index+1] == 't') // table representation
		{
			luaL_checkstack(L,2,"not enough space on the lua stack!");
			lua_newtable(L);
			lua_pushnumber(L,time_str->tm_year); // the value
			lua_setfield(L,-2,"year");
			
			lua_pushnumber(L,time_str->tm_mon);
			lua_setfield(L,-2,"month");
			
			lua_pushnumber(L,time_str->tm_mday);
			lua_setfield(L,-2,"day");
			
			lua_pushnumber(L,time_str->tm_hour);
			lua_setfield(L,-2,"hour");
			
			lua_pushnumber(L,time_str->tm_min);
			lua_setfield(L,-2,"min");
			
			lua_pushnumber(L,time_str->tm_sec);
			lua_setfield(L,-2,"sec");
			
			lua_pushnumber(L,time_str->tm_wday);
			lua_setfield(L,-2,"wday");
			
			lua_pushnumber(L,time_str->tm_yday);
			lua_setfield(L,-2,"yday");
			
			lua_pushnumber(L,time_str->tm_isdst);
			lua_setfield(L,-2,"isdst");
			
			return 1;
		}
	}
	strftime(buffer,150,format+index,time_str);
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	lua_pushstring(L,buffer);
	return 1;
}

int lua_difftime(lua_State *L)
{
	if (lua_gettop(L) != 2)
	{
		return luaL_error(L,"os.difftime needs 2 arguments");
	}
	double t2 = lua_tonumber(L,1);
	double t1 = lua_tonumber(L,2);
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	lua_pushnumber(L,t2-t1);
	return 1;
}

int lua_execute(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		lua_pushboolean(L,true);
		return 1;
	}
	if (lua_gettop(L) > 1)
	{
		return luaL_error(L,"too many arguments for os.execute");
	}
	const char* str = lua_tostring(L,1);
	if (str == NULL)
	{
		return luaL_error(L,"os.execute: string expected");
	}
	luaL_checkstack(L,3,"not enough space on the lua stack!");
	int ret = nl_exec(str,0,NULL);
	if (ret == 0xDEAD || ret == 0xBEEF)
	{
		lua_pushnil(L);
	}
	else
	{
		lua_pushboolean(L,true);
	}
	lua_pushstring(L,"exit");
	lua_pushinteger(L,ret);
	return 3;
}

int lua_exit(lua_State *L)
{
	return luaL_error(L,"os.exit: cannot close the lua app, the user has to close the document");
}

int lua_getenv(lua_State *L)
{
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	lua_pushnil(L);
	return 1;
}

int lua_remove_file(lua_State *L)
{
	if (lua_gettop(L) != 1)
	{
		return luaL_error(L,"os.remove needs one argument");
	}
	const char* str = lua_tostring(L,1);
	if (str == NULL)
	{
		return luaL_error(L,"os.remove needs a string");
	}
	if (remove(str) == 0)
	{
		luaL_checkstack(L,1,"not enough space on the lua stack!");
		lua_pushboolean(L,true);
		return 1;
	}
	else
	{
		luaL_checkstack(L,3,"not enough space on the lua stack!");
		lua_pushnil(L);
		lua_pushstring(L,"os.remove: could not remove the file");
		lua_pushinteger(L,-1);
		return 3;
	}
}
int lua_rename(lua_State *L)
{
	if (lua_gettop(L) != 2)
	{
		return luaL_error(L,"os.rename needs 2 argument");
	}
	const char* old = lua_tostring(L,1);
	const char* new = lua_tostring(L,2);
	if (old == NULL)
	{
		return luaL_error(L,"os.rename needs a string as first argument");
	}
	if (new == NULL)
	{
		return luaL_error(L,"os.rename needs a string as second argument");
	}
	if (rename(old,new) == 0)
	{
		luaL_checkstack(L,1,"not enough space on the lua stack!");
		lua_pushboolean(L,true);
		return 1;
	}
	else
	{
		luaL_checkstack(L,3,"not enough space on the lua stack!");
		lua_pushnil(L);
		lua_pushstring(L,"os.rename: could not rename the file");
		lua_pushinteger(L,-1);
		return 3;
	}
}

int lua_setlocale(lua_State *L)
{
	luaL_checkstack(L,1,"not enough space on the lua stack!");
	lua_pushnil(L); // the locale has to be changed by using the document settings
	return 1;
}

int lua_time(lua_State *L)
{
	if (lua_gettop(L) == 0)
	{
		luaL_checkstack(L,1,"not enough space on the lua stack!");
		lua_pushinteger(L,time(NULL));
		return 1;
	}
	if (lua_gettop(L) == 1)
	{
		if (! lua_istable(L,1))
		{
			return luaL_error(L,"the argument to os.time has to be a table");
		}
		struct tm tm_str;
		luaL_checkstack(L,1,"not enough space on the lua stack!");
		
		lua_getfield(L,1,"year");
		tm_str.tm_year = lua_tonumber(L,2);
		lua_remove(L,2);
		
		lua_getfield(L,1,"month");
		tm_str.tm_mon = lua_tonumber(L,2);
		lua_remove(L,2);
		
		lua_getfield(L,1,"hour");
		tm_str.tm_hour = lua_tonumber(L,2);
		lua_remove(L,2);
		
		lua_getfield(L,1,"min");
		tm_str.tm_min = lua_tonumber(L,2);
		lua_remove(L,2);
		
		lua_getfield(L,1,"sec");
		tm_str.tm_sec = lua_tonumber(L,2);
		lua_remove(L,2);
		
		lua_getfield(L,1,"isdst");
		tm_str.tm_isdst = lua_tonumber(L,2);
		lua_remove(L,2);
		
		
		time_t time = mktime(&tm_str);
		if (time == -1)
		{
			return luaL_error(L,"could not use mktime in os.time. Maybe you used negative values. os.time currently doesn't support these");
		}
		lua_pushinteger(L,time);
		return 1;
	}
	return luaL_error(L,"os.time needs either one or no argument");
}

int lua_tmpname(lua_State *L)
{
	while (true)
	{
		struct stat st;
		char buff[150];
		memset(buff,'\0',150);
		sprintf(buff,"/documents/%.20d.tns",rand());
		if (stat(buff,&st) != 0) // if stat fails, the file doesn't exist
		{
			luaL_checkstack(L,1,"not enough space on the lua stack!");
			lua_pushstring(L,buff);
			return 1;
		}
	}
}


static const luaL_reg lualib[] = {
	{"clock",lua_clock},
	{"date",lua_date},
	{"difftime",lua_difftime},
	{"execute",lua_execute},
	{"exit",lua_exit},
	{"getenv",lua_getenv},
	{"remove",lua_remove_file},
	{"rename",lua_rename},
	{"setlocale",lua_setlocale},
	{"time",lua_time},
	{"tmpname",lua_tmpname},
	{NULL, NULL}
};

int main(void) {
	lua_State *L = nl_lua_getstate();
	if (!L) return 0;
	luaL_register(L, "os", lualib);
	starting_time = time(NULL);
	return 0;
}

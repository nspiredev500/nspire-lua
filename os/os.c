#include <stdint.h>
#include <stdbool.h>

#include <os.h>
#include <lauxlib.h>
#include <nucleus.h>
#include <lua.h>



/// for freeing resources https://www.lua.org/pil/29.html

static int64_t starting_time = 0;

int64_t get_seconds()
{
	volatile uint32_t *rtc_val = (volatile uint32_t*) 0x90090008;
	return (int64_t) (*rtc_val);
}


int lua_clock(lua_State *L)
{
	lua_checkstack(L,1);
	lua_pushinteger(L,(int32_t) (get_seconds()-starting_time));
	return 1;
}

int lua_date(lua_State *L)
{
	int args = lua_gettop(L);
	int64_t time = get_seconds();
	const char* format = NULL;
	if (args > 0)
	{
		if (lua_isstring(L,1))
		{
			format = lua_tostring(L,1);
		}
	}
	if (args > 1)
	{
		if (lua_isnumber(L,2))
		{
			time = lua_tonumber(L,2);
		}
	}
	if (args > 2)
	{
		luaL_error(L,"too many arguments for os.date: %d",args);
	}
	if (format == NULL)
	{
		
	}
	else
	{
		
	}
	
	
	return 1;
}

int lua_difftime(lua_State *L)
{
	
	return 1;
}

int lua_execute(lua_State *L)
{
	
	return 3;
}

int lua_exit(lua_State *L)
{
	
	return 0;
}

int lua_getenv(lua_State *L)
{
	
	return 1;
}

int lua_remove(lua_State *L)
{
	
	// returns nil, an error string and error code if it fails
	
	return 0;
}

int lua_setlocale(lua_State *L)
{
	
	// returns nil, an error string and error code if it fails
	
	
	return 0;
}

int lua_time(lua_State *L)
{
	
	return 1;
}

int lua_tmpname(lua_State *L)
{
	
	return 1;
}


static const luaL_reg lualib[] = {
	{"clock",},
	{"date",},
	{"difftime",},
	{"execute",},
	{"exit",},
	{"getenv",},
	{"remove",},
	{"rename",},
	{"setlocale",},
	{"time",},
	{"tmpname",},
	{NULL, NULL}
};

int main(void) {
	lua_State *L = nl_lua_getstate();
	if (!L) return 0;
	luaL_register(L, "os", lualib);
	starting_time = get_seconds();
	return 0;
}

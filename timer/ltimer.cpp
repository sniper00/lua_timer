
#define LUA_LIB

#include <lua.hpp>
#include <stdlib.h>
#include <string.h>
#include "timer.hpp"

#define METANAME "ltimer"

static int
traceback(lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg)
		luaL_traceback(L, L, msg, 1);
	else {
		lua_pushliteral(L, "(no error message)");
	}
	return 1;
}

struct timer_box
{
	moon::timer*  timer = nullptr;
};

static int lrelease(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr!= b && nullptr!= b->timer)
	{
		delete b->timer;
		b->timer = nullptr;
	}
	return 0;
}

static int ltimer_repeated(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr == b && nullptr == b->timer)
		return luaL_error(L, "Invalid timer pointer");
	auto times = luaL_checkinteger(L, -1);
	auto interval = luaL_checkinteger(L, -2);
	auto tid = b->timer->repeat(static_cast<int32_t>(interval), static_cast<int32_t>(times));
	lua_pushinteger(L, tid);
	return 1;
}

static int ltimer_remove(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr == b && nullptr == b->timer)
		return luaL_error(L, "Invalid timer pointer");
	auto tid = luaL_checkinteger(L, -1);
	b->timer->remove(static_cast<uint32_t>(tid));
	return 0;
}

static int ltimer_update(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr == b && nullptr == b->timer)
		return luaL_error(L, "Invalid timer pointer");
	b->timer->update();
	return 0;
}

static int ltimer_set_on_timer_cb(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr == b && nullptr == b->timer)
		return luaL_error(L, "Invalid timer pointer");
	static const char* flag = "ltimer_set_on_timer_cb";
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_rawsetp(L, LUA_REGISTRYINDEX, flag);// LUA_REGISTRYINDEX table[cb]=function
	b->timer->set_on_timer([L](moon::timerid_t tid) {
		lua_pushcfunction(L, traceback);
		lua_rawgetp(L, LUA_REGISTRYINDEX, flag);//get lua function
		lua_pushinteger(L, tid);
		int r = lua_pcall(L, 1, 0, -3);
		if (r == LUA_OK) {
			return;
		}
		else
		{
			printf("timer on timer cb error:%s\n", lua_tostring(L, -1));
		}
		lua_pop(L, 1);
		return;
	});
	return 0;
}

static int ltimer_set_remove_cb(lua_State *L)
{
	timer_box* b = reinterpret_cast<timer_box*>(lua_touserdata(L, 1));
	if (nullptr == b && nullptr == b->timer)
		return luaL_error(L, "Invalid timer pointer");
	static const char* flag = "ltimer_set_remove_cb";
	luaL_checktype(L, -1, LUA_TFUNCTION);
	lua_rawsetp(L, LUA_REGISTRYINDEX, flag);// LUA_REGISTRYINDEX table[cb]=function
	b->timer->set_remove_timer([L](moon::timerid_t tid) {
		lua_pushcfunction(L, traceback);
		lua_rawgetp(L, LUA_REGISTRYINDEX, flag);//get lua function
		lua_pushinteger(L, tid);
		int r = lua_pcall(L, 1, 0, -3);
		if (r == LUA_OK) {
			return;
		}
		else
		{
			printf("timer remove cb error:%s\n", lua_tostring(L, -1));
		}
		lua_pop(L, 1);
		return;
	});
	return 0;
}

static int ltimer_create(lua_State *L)
{
	moon::timer* timer = new moon::timer;
	timer_box* b = reinterpret_cast<timer_box*>(lua_newuserdata(L, sizeof(*b)));
	b->timer = timer;
	if (luaL_newmetatable(L, METANAME))//mt
	{
		luaL_Reg l[] = {
			{ "set_on_timer",ltimer_set_on_timer_cb },
			{ "set_remove_timer",ltimer_set_remove_cb },
			{ "repeated",ltimer_repeated },
			{ "update",ltimer_update },
			{ "remove",ltimer_remove },
			{ NULL,NULL }
		};
		luaL_newlib(L, l); {}
		lua_setfield(L, -2, "__index");//mt[__index] = {}
		lua_pushcfunction(L, lrelease);
		lua_setfield(L, -2, "__gc");//mt[__gc] = lrelease
	}
	lua_setmetatable(L, -2);// set userdata metatable
	lua_pushlightuserdata(L, b);
	return 2;
}

#if __cplusplus
extern "C" {
#endif
	int LUAMOD_API luaopen_timer_c(lua_State *L)
	{
		luaL_Reg l[] = {
			{"create",ltimer_create},
			{"release",lrelease },
			{NULL,NULL}
		};
		luaL_checkversion(L);
		luaL_newlib(L, l);
		return 1;
	}
#if __cplusplus
}
#endif
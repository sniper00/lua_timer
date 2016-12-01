#include "lua_timer.h"
#include "sol.hpp"
#include "timer.h"

using namespace moon;

static void BindTimer(lua_State * L)
{
	sol::state_view lua(L);
	lua.new_usertype<moon::timer>("Timer"
		, sol::constructors<sol::types<>>()
		, "ExpiredOnce", &moon::timer::expired_once
		, "Repeat", &moon::timer::repeat
		, "Remove", &moon::timer::remove
		, "StopAllTimer", &moon::timer::stop_all_timer
		, "StartAllTimer", &moon::timer::start_all_timer
		, "Update",&moon::timer::update
		);
}

int luaopen_timer_c(lua_State * L)
{
	BindTimer(L);
	return 1;
}

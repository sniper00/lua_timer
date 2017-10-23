#include "lua_timer.h"
#include "sol.hpp"
#include "timer.hpp"

using namespace moon;

namespace moon
{
    using timer_t = moon::timer<std::function<void(moon::timerid_t)> >;
}

static void BindTimer(lua_State * L)
{
	sol::state_view lua(L);
	lua.new_usertype<moon::timer_t>("timer"
		, sol::constructors<sol::types<>>()
        , "expired_once", [](moon::timer_t* t, int duration, sol::function&& cb) {
            return t->expired_once(duration, std::forward<sol::function>(cb));
        }
        , "repeated", [](moon::timer_t* t, int duration, int32_t times, sol::function&& cb) {
            return t->repeat(duration, times, std::forward<sol::function>(cb));
        }
		, "remove", &moon::timer_t::remove
		, "stopall", &moon::timer_t::stop_all_timer
		, "startall", &moon::timer_t::start_all_timer
		, "update",&moon::timer_t::update
		);
}

int luaopen_timer_c(lua_State * L)
{
	BindTimer(L);
	return 1;
}

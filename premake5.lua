
workspace "lua_timer"
    configurations { "Debug", "Release" }
    if os.is("windows") then
    	platforms {"Win32", "x64"}
    else
        platforms {"Linux"}
        flags{"NoPCH","RelativeLinks","C++14"}
    end

    location "./"

    filter "configurations:Debug"
        defines { "DEBUG" }
        flags { "Symbols" }

    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"

    filter { "platforms:Win32" }
        system "windows"
        architecture "x86"

    filter { "platforms:x64" }
        system "windows"
        architecture "x64"


    filter { "platforms:Linux" }
        system "Linux"

project "lua53"
    objdir "obj/lua53/%{cfg.platform}_%{cfg.buildcfg}"
    location "build/lua53"
    kind "SharedLib"
    language "C"
    targetdir "bin/%{cfg.buildcfg}"
    includedirs {"./lua53"}
    files { "./**.h", "./**.c"}
    removefiles("./lua53/lua.c")
    removefiles("./lua53/luac.c")
	postbuildcommands{"{COPY} %{wks.location}/bin/%{cfg.buildcfg}/%{cfg.buildtarget.name} %{wks.location}/example/"}
    filter { "system:windows" }
    	defines {"LUA_BUILD_AS_DLL"}
    filter { "system:linux" }
        defines {"LUA_USE_LINUX"}

project "lua"
    objdir "obj/lua/%{cfg.platform}_%{cfg.buildcfg}"
    location "build/lua"
    kind "ConsoleApp"
    language "C"
    targetdir "bin/%{cfg.buildcfg}"
    includedirs {"./lua53"}
    files { "./lua53/lua.c"}
    links{"lua53"}
	postbuildcommands{"{COPY} %{wks.location}/bin/%{cfg.buildcfg}/%{cfg.buildtarget.name} %{wks.location}/example/"}
    filter { "system:linux" }
        linkoptions {"-Wl,-rpath=./"}
        links{"dl","m"}
        
project "timer"
    objdir "obj/timer/%{cfg.platform}_%{cfg.buildcfg}"
    location "build/timer"
    kind "SharedLib"
    targetdir "bin/%{cfg.buildcfg}"
    includedirs {"./timer","./lua53"}
    files { "./timer/**.hpp","./timer/**.h","./timer/**.cpp"}
    targetprefix ""
    language "C++"
    links{"lua53"}
	postbuildcommands{"{COPY} %{wks.location}/bin/%{cfg.buildcfg}/%{cfg.buildtarget.name} %{wks.location}/example/"}
  	filter { "system:windows" }
        defines {"LUA_BUILD_AS_DLL"}
   
       
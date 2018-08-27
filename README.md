# lua_timer
一个C++实现的计时器(wheel), 编译位动态库 提供给lua使用

# Bulid
默认需要链接lua 5.3版本的动态库，需要把lua源码放在lua文件夹中。
保证你的 lua动态库 名字为 lua53.so (lua53.dll), 如果不是,
请更改premake.lua, 重新生成工程文件:
```
    --windows
    premake.exe vs2015
    --linux
    premake --os=linux gmake
```

**The project use of C++11/14 features**

I tested compliers are:
- GCC 5.4 
- Visual Studio 2015 Community Update 3

Linux Platform: 
- make config=debug_linux
- make config=release_linux

you will get timer dynamic library at bin path.

# Use

**call timer.update() in your main loop**

```lua
package.cpath = "./?.dll;./?.so"
 
local timer = require "timer"

--example 一秒后超时的计时器
timer.repeated(
    1000,
    1,
    function()
        print("ExpiredOnce timer expired")
    end
)

local ntimes = 0

--example 一个超时10次的计时器 第二个参数是执行次数
timer.repeated(
    1000,
    10,
    function()
        ntimes = ntimes + 1
        print("Repeat 10 times timer expired", ntimes)
    end
)

--example 一个永远执行的计时器 -1 代表不限次数
timer.repeated(
    1000,
    -1,
    function()
        print("Repeat timer expired")
    end
)

--example 这个计时器执行一次后就会被移除
local timerID = 0
timerID = timer.repeated(
    1000,
    -1,
    function()
        timer.remove(timerID)
        print("remove timer",timerID)
    end
)

while true do
    timer.update()
end

```
** timer with coroutine **
```lua
package.cpath = "./?.dll;./?.so"
local os = require ('os')
local timer = require ('timer')

local function co3()
    print("coroutine3 start",os.time())
    timer.co_wait(5000)
    print("coroutine3 5 second later",os.time())
    print("coroutine3 end")
end

timer.async(function()
    print("coroutine1 start",os.time())
    timer.co_wait(2000)
    print("coroutine1 2 second later",os.time())
    timer.async(co3)
    print("coroutine1 end")
end)

timer.async(function()
    print("coroutine2 start",os.time())
    timer.co_wait(1000)
    print("coroutine2 1 second later",os.time())
    timer.co_wait(1000)
    print("coroutine2 1 second later ",os.time())
    timer.co_wait(1000)
    print("coroutine2 1 second later ",os.time())
    timer.co_wait(1000)
    print("coroutine2 1 second later ",os.time() )
    print("coroutine2 end")
end)

print("main thread noblock")

while true do
    timer.update()
end

```

# lua_timer
一个C++实现的计时器(wheel), 编译位动态库 提供给lua使用

# Bulid
默认需要链接lua 5.3版本的动态库，需要把lua源码放在lua文件夹中。
保证你的 lua动态库 名字为 lua53.so (lua53.dll), 如果不是,
你就要自己写makefile, 注意 g++ 添加 std14 flag

**The project use of C++11/14 features**

I tested compliers are:
- GCC 5.4 
- Visual Studio 2015 Community Update 3

Linux Platform: 
- make config=debug_linux
- make config=release_linux

you will get timer dynamic library at bin path.

# Use

**call timer:Update() in your main loop**

```lua
package.cpath = "./?.dll;./?.so"

require "timer.c"
-- 一般一个lua state 只需要一个全局的 timer对象
tmr = timer.new() --创建timer对象

--example 一秒后超时的计时器
tmr:expired_once(
    1000,
    function()
        print("ExpiredOnce timer expired")
    end
)

local ntimes = 0

--example 一个超时10次的计时器 第二个参数是执行次数
tmr:repeated(
    1000,
    10,
    function()
        ntimes = ntimes + 1
        print("Repeat 10 times timer expired", ntimes)
    end
)

--example 一个永远执行的计时器 -1 代表不限次数
tmr:repeated(
    1000,
    -1,
    function()
        print("Repeat timer expired")
    end
)

--example 这个计时器执行一次后就会被移除
local timerID = 0
timerID =
    tmr:repeated(
    1000,
    -1,
    function()
        tmr:remove(timerID)
        print("remove timer")
    end
)

while true do
    tmr:update()
end
```
** timer with coroutine **
```lua
package.cpath = "./?.dll;./?.so"

require 'timer.c'
require 'coroutine'
require 'os'
-- 一般一个lua state 只需要一个全局的 timer对象
tmr = timer.new() --创建timer对象

local function WaitSecond(sec)
    return {Event='timer',dura = sec}
end

local function StartCoroutine(f)
    local co = coroutine.create(f)

    local schedule
    schedule = function(corou)
        local b,t = coroutine.resume(corou)
        if b then
            if t and t.Event and t.Event == 'timer' then
                tmr:expired_once(t.dura*1000,function()
                    schedule(corou)
                end)
            end
        end
    end

    schedule(co)
end

local function co3()
    print("coroutine3 start",os.time())
    coroutine.yield(WaitSecond(5))
    print("coroutine3 5 second later",os.time())
    print("coroutine3 end")
end

StartCoroutine(function()
    print("coroutine1 start",os.time())
    coroutine.yield(WaitSecond(2))
    print("coroutine1 2 second later",os.time())
    StartCoroutine(co3)
    print("coroutine1 end")
end)

StartCoroutine(function()
    print("coroutine2 start",os.time())
    coroutine.yield(WaitSecond(1))
    print("coroutine2 1 second later",os.time())
    coroutine.yield(WaitSecond(1))
    print("coroutine2 1 second later ",os.time())
    coroutine.yield(WaitSecond(1))
    print("coroutine2 1 second later ",os.time())
    coroutine.yield(WaitSecond(1))
    print("coroutine2 1 second later ",os.time() )

    print("coroutine2 end")
end)

print("main thread noblock")

while true do
    tmr:update()
end
```

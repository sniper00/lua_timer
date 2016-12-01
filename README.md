
# lua_timer
a cpp  implement lua timer

# Bulid

put  you lua source files in lua53 path。
保证你的 lua动态库 名字为 lua53.so (lua53.dll), 如果不是，
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

```lua
require 'timer.c'
-- 一般一个lua state 只需要一个全局的 timer对象
timer = Timer.new()

-- **call timer:Update in your main loop**

--example 一秒后超时的计时器
    timer:ExpireOnce(1000, function()
        print("timer expired")
    end)

--example 一个超时10次的计时器 第二个参数是执行次数
    timer:Repeat(1000,10,function()
        print("timer expired")
    end)

--example 一个永远执行的计时器 -1 代表不限次数
    timer:Repeat(1000,-1,function()
        print("timer expired")
    end)

--example 这个计时器执行一次后就会被移除
    local timerID = 0
    timerID = timer:Repeat(1000,-1,function()
        print("timer expired")
        timer:Remove(timerID)
    end)

-- timer:StopAllTimer()暂停所有计时器
-- timer:StartAllTimer()暂停所有计时器

```

 
 

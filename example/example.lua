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

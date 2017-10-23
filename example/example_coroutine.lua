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



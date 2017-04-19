package.cpath = './?.dll;'

require 'timer.c'
require 'coroutine'
-- 一般一个lua state 只需要一个全局的 timer对象
timer = Timer.new() --创建timer对象

local function WaitSecond(sec)
    return {Event='timer',dura = sec}
end

local function StartCoroutine(f)
    local co = coroutine.create(f)
    local b,t = coroutine.resume(co)
    if b then
        if t.Event == 'timer' then
            timer:ExpiredOnce(t.dura*1000,function()
                coroutine.resume(co)
            end)
        end
    end
end

local function co3()
    print("coroutine3 start")
    coroutine.yield(WaitSecond(5))
    print("coroutine3 5 second later")
end

StartCoroutine(function()
    print("coroutine1 start")
    coroutine.yield(WaitSecond(2))
    print("coroutine1 2 second later")
    StartCoroutine(co3)
end)

StartCoroutine(function()
    print("coroutine2 start")
    coroutine.yield(WaitSecond(1))
    print("coroutine2 1 second later")
end)

print("main thread noblock")

while true do
    timer:Update()
end



local timer = require ('timer')

local function co3()
    print("coroutine3 start",os.clock())
    timer.sleep(5.5)
    print("coroutine3 5.5 second later",os.clock())
    print("coroutine3 end")
end

--coroutine style timer
timer.async(function()
    print("coroutine1 start",os.time())
    timer.sleep(2)
    print("coroutine1 2 second later",os.time())
    timer.async(co3)
    print("coroutine1 end")
end)

timer.async(function()
    print("coroutine2 start",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time())
    timer.sleep(1)
    print("coroutine2 1 second later ",os.time() )
    print("coroutine2 end")
end)

--callback style timer
local stime = os.time()
timer.timeout(1.5,function()
    print("timer expired", os.time() - stime)
end)

--remove a timer
local ctx = timer.timeout(5,function()
    error("this timer shoud not expired")
end)
timer.remove(ctx)

print("main thread noblock")
--replace this while loop code, use your framework's update
while true do
    timer.update()
end


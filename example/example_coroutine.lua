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



local coroutine = require ('coroutine')
local os = require ('os')
local core= require("timer.c")

local co_create = coroutine.create
local co_running = coroutine.running
local _co_resume = coroutine.resume
local co_yield = coroutine.yield
local table_remove = table.remove

local co_pool = setmetatable({}, {__mode = "kv"})

local waitallco = {}

local M = {}

local function check_wait_all( ... )
    local co = co_running()
    local waitco = waitallco[co]
    if waitco then
        if 0 ~= waitco.ctx.count then
            waitco.ctx.results[waitco.idx] = {...}
            waitco.ctx.count= waitco.ctx.count-1
            if 0==waitco.ctx.count then
                co_resume(waitco.ctx.cur,waitco.ctx.results)
            end
        end
    end
    return co
end

local function co_resume(co, ...)
    local ok, err = _co_resume(co, ...)
    if not ok then
        error(err)
    end
end

local function routine(func)
    while true do
        local co = check_wait_all(func())
        co_pool[#co_pool + 1] = co
        func = co_yield()
    end
end

function M.async(func)
    local co = table_remove(co_pool)
    if not co then
        co = co_create(routine)
    end
    co_resume(co, func)
    return co
end

function M.wait_all( ... )
    local currentco = co_running()
    local cos = {...}
    local ctx = {count = #cos,results={},cur=currentco}
    for k,co in pairs(cos) do
        --assert(not waitallco[co])
        ctx.results[k]=""
        waitallco[co]={ctx=ctx,idx=k}
    end
    return co_yield()
end

local timer_cb = {}

local p = core.create()

p:set_on_timer(
    function(timerid)
        local cb = timer_cb[timerid]
        if cb then
            cb(timerid)
        end
    end
)

p:set_remove_timer(
    function(timerid)
        timer_cb[timerid] = nil
    end
)

function M.repeated(mills, times, cb)
    local timerid = p:repeated(mills, times)
    timer_cb[timerid] = cb
    return timerid
end

function M.co_wait(mills)
    local co = co_running()
    M.repeated(
        mills,
        1,
        function(tid)
            co_resume(co, tid)
        end
    )
    return co_yield()
end


function M.update(mills)
    p:update()
end

function M.remove(tid)
    p:remove(tid)
end

return M




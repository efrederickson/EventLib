-- EventLib - An event library in pure lua (uses standard coroutine library)
-- 
-- ROBLOX has an event library in its RbxUtility library, but it isn't pure Lua. 
-- It originally used a BoolValue but now uses BindableEvent. I wanted to write
-- it in pure Lua, so here it is. It also contains some new features.
-- 
-- Version: 1.0
-- Copyright (C) 2012 LoDC
-- 
-- API:
-- 
-- EventLib
--   new([name])
--     aliases: CreateEvent
--     returns: the event, with a metatable __index for the EventLib table
--   Connect(event, func)
--     aliases: connect
--     returns: a Connection
--   Disconnect(event, [func])
--     aliases: disconnect
--     returns: the index of [func]
--     notes: if [func] is nil, it removes all connections
--   DisconnectAll(event)
--     notes: calls Disconnect()
--   Fire(event, ... <args>)
--     aliases: Simulate, fire
--     notes: resumes all :wait() first
--   Wait(event)
--     aliases: wait
--     returns: the Fire() arguments
--     notes: blocks the thread until Fire() is called
--   ConnectionCount(event)
--     returns: the number of current connections
--   Spawn(func)
--     aliases: spawn
--     returns: the result of func
--     notes: runs func in a separate coroutine/thread
--   
-- Event
--   [All EventLib functions]
--   EventName
--     Property, defaults to "<Unknown Event>"
-- 
-- Connection
--   Disconnect
--     aliases: disconnect
--     returns: the result of [Event].Disconnect
-- 
-- Basic usage (there are some tests on the bottom):
--  local EventLib = require'EventLib' 
-- For ROBLOX use: repeat wait() until _G.EventLib local EventLib = _G.EventLib
--  
--  local event = EventLib:new()
--  local con = event:Connect(function(...) print(...) end)
--  event:Fire("test") --> 'test' is print'ed
--  con:disconnect()
--  event:Fire("test") --> nothing happens: no connections
-- 
-- Supported versions/implementations of Lua:
-- Lua 5.1, 5.2
-- SharpLua 2
-- MetaLua
-- RbxLua (automatically registers if it detects ROBLOX)

--[[
Issues:
None

Changelog:

v1.0
- Initial version

]]

local _M = { }
_M._VERSION = "1.0"
_M._M = _M
_M._AUTHOR = "Elijah Frederickson"
_M._COPYRIGHT = "Copyright (C) 2012 LoDC"

local function spawn(f)
    return coroutine.resume(coroutine.create(function()
        f()
    end))
end
_M.Spawn = spawn
_M.spawn = spawn

function _M:new(name)
    local s = { }
    s.handlers = { }
    s._waiter = false
    s._waiters = { }
    s.args = nil
    s.EventName = name or "<Unknown Event>"
    return setmetatable(s, { __index = self })
end
_M.CreateEvent = _M.new

function _M:Connect(handler)
    table.insert(self.handlers, handler)
    local t = { }
    t.Disconnect = function()
        return self:Disconnect(handler)
    end
    t.disconnect = t.Disconnect
    return t
end
_M.connect = _M.Connect

function _M:Disconnect(handler)
    if not handler then
        self.handlers = { }
    else
        for k, v in pairs(self.handlers) do
            if v == handler then
                self.handlers[k] = nil
                return k
            end
        end
    end
end
_M.disconnect = _M.Disconnect

function _M:DisconnectAll()
    self:Disconnect()
end

function _M:Fire(...)
    self.args = { ... }
    if self._waiter then
        self._waiter = false
        for k, v in pairs(self._waiters) do
            coroutine.resume(v)
        end
    end
    for k, v in pairs(self.handlers) do
        spawn(function() v(unpack(self.args)) end)
    end
    self.args = nil
end
_M.Simulate = _M.Fire
_M.fire = _M.Fire

function _M:Wait()
    self._waiter = true
    table.insert(self._waiters, coroutine.create(function()
        coroutine.yield()
        return unpack(self.args)
    end))
end
_M.wait = _M.Wait

function _M:ConnectionCount()
    return #self.handlers
end

-- Tests
if false then
    local e = _M:new("test")
    local f = function(...) print("| Fired!", ...) end
    local e2 = e:connect(f)
    e:fire("arg1", 5, { })
    spawn(function() e:wait(5) print"|- done waiting!" end)
    e:fire(nil, "x")
    print("Disconnected events index:", e:disconnect(f))
    print("Couldn't disconnect an already disconnected handler?", e2:disconnect()==nil)
    print("Connections:", e:ConnectionCount())
    assert(e:ConnectionCount() == 0 and e:ConnectionCount() == #e.handlers)
    e:connect(f)
    e:disconnect()
    e:Simulate()
    f("plain function call")
    assert(e:ConnectionCount() == 0)
end

if shared and Instance then -- ROBLOX support
    shared.EventLib = _M 
    _G.EventLib = _M
end

return _M

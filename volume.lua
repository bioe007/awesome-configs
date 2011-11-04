--! @file   volume.lua
--
-- @brief
--
-- @author  Perry Hargrave
-- @date    2011-10-31
--

local pairs = pairs
local setmetatable = setmetatable
local string = string
local table = table

local aw_util = require('awful.util')
local notify = require('notifications')

module('volume')

cmd = '/usr/bin/amixer'
card = 0

UNKNOWN = -1

local quiet = '-q'
local current_level = UNKNOWN
local mute = UNKNOWN

function get()
    local stats = aw_util.pread(cmd .. ' get Master')
    current_level = stats:match('%d+%%'):gsub('%%', '')
    return current_level
end

local function exec(s)
    aw_util.spawn_with_shell(s)
end

function change(value, card, channel)
    local value = value
    if value == nil then
        return mute()
    end

    if value < 0 then
        s_val = string.gsub(value, '(-)(%d)', '%2-')
    else
        s_val = value .. '+'
    end

    s = table.concat({
                      cmd,
                      quiet,
                      '-c',
                      (card or '0'),
                      'sset ',
                      (channel or 'Master'),
                      s_val},
                      " ")
    exec(s)
end

function lower(i)
    local increment = i or -1
    change(increment) -- .. '-')
end

function raise(i)
    local increment = i or 1
    change(increment)
end

function mute()
    exec(cmd .. ' -c ' .. card .. ' sset Master,0 toggle')
end

setmetatable(_M,
             {
                 __call = function(t, ...)
                     return change(...)
                 end,
             })

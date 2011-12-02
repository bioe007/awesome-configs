--! @file   volume.lua
--
-- @brief Just for controlling volume.
--
-- @author  Perry Hargrave
-- @date    2011-10-31
--
-- Requires sexy module.

local pairs        = pairs
local setmetatable = setmetatable
local string       = string
local table        = table
local tonumber     = tonumber

local aw_util = require('awful.util')
local sexy    = require('sexy')

module('volume')

cmd = '/usr/bin/amixer'
card = 0

local quiet = '-q'

local function exec(s)
    return aw_util.pread(s)
end

local function parse_stats(stats)
    local vmuted = (string.find(stats, '%[on%]') == nil)
    local vlevel = stats:match('%d+%%'):gsub("%%", "")
    return tonumber(vlevel), vmuted
end

function get()
    local stats = aw_util.pread(cmd .. ' get Master')
    return parse_stats(stats)
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
                      '-c',
                      (card or '0'),
                      'sset ',
                      (channel or 'Master'),
                      s_val},
                      " ")
    stats = exec(s)
    sexy.show.volume(parse_stats(stats))
end

function lower(i)
    change(i or -1)
end

function raise(i)
    change(i or 1)
end

function mute()
    stats = exec(cmd .. ' -c ' .. card .. ' sset Master,0 toggle')
    sexy.show.volume(parse_stats(stats))
end

setmetatable(_M,
             {
                 __call = function(t, ...)
                     return change(...)
                 end,
             })

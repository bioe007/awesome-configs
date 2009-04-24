----------------------------------------------------------------------------
-- @author Damien Leone &lt;damien.leone@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Damien Leone, Julien Danjou
-- @release v3.2-233-gdaf7192
----------------------------------------------------------------------------

-- Grab environment
local io = io
local os = os
local print = print
local setmetatable = setmetatable
local util = require("awful.util")
local package = package
local capi =
{
    screen = screen,
    awesome = awesome,
    image = image
}

--- Theme library
module("beautiful")

-- Local data
local theme = {}

--- Get a value directly.
-- @param key The key.
-- @return The value.
function __index(self, key)
    return theme[key]
end

--- Init function, should be runned at the beginning of configuration file.
-- @param path The theme file path.
function init(path)

    if path then
        theme = dofile(path)

        if theme["wallpaper_cmd"] ~= nil then
            -- this method sucks if you use nitrogen --restore, btw :(
            for s = 1, capi.screen.count() do
                util.spawn(theme["wallpaper_cmd"], false, s)
            end
        end
        if theme["font"] ~= nil then capi.awesome.font = theme["font"] end
        if theme["fg_normal"] then capi.awesome.fg = theme["fg_normal"] end
        if theme["bg_normal"] then capi.awesome.bg = theme["bg_normal"] end
    end

end

--- Get the current theme.
-- @return The current theme table.
function get()
    return _M
end

setmetatable(_M, _M)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80

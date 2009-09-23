--{{{ volume.lua
--
-- a small script to manage volume and a widget for the awesome windomanager
--
-- bioe007 perrydothargraveatgmaildotcom
--
--}}}

local io = io
local awful = require("awful")
local string = string
local beautiful = require("beautiful")
local timer = timer

-- local variables
local config = {}

module("volume")

--{{{ vol the workhorse fx
function vol(mode, percent)
    if mode == "update" then
        local fd = io.popen("amixer -c " .. config.cardid .. " -- sget " .. config.channel)
        local status = fd:read("*a")
        if fd ~= nil then
            fd:close()
        end
        local volume = string.match(status, "(%d?%d?%d)%%")

        status = string.match(status, "%[(o[^%]]*)%]")

        config.widget:set_value(volume/100)
        if string.find(status, "on", 1, true) then
            -- volume = volume .. "%"
            config.widget:set_gradient_colors({ beautiful.fg_focus, beautiful.fg_focus })
            -- config.widget:bar_properties_set("vol", {["bg"] = beautiful.vol_bg,
            -- ["border_color"] = beautiful.bg_focus, })
        else
            -- volume = volume .. "M"
            config.widget:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal })
            -- config.widget:bar_properties_set("vol", {["bg"] = beautiful.bg_normal,
            -- ["border_color"] = beautiful.bg_normal, })
        end
        -- config.widget.text = volume
        config.widget:set_value(volume/100)
    elseif mode == "up" then
        awful.util.spawn("amixer -q -c " .. config.cardid .. " sset " .. config.channel .." "..(percent or 5).."%+",false)
        vol("update")
    elseif mode == "down" then
        awful.util.spawn("amixer -q -c " .. config.cardid .. " sset " .. config.channel .." "..(percent or 5).."%-",false)
        vol("update")
    else
        awful.util.spawn("amixer -c " .. config.cardid .. " sset " .. config.channel .. " toggle",false)
        vol("update")
    end
end
--}}}

--{{{ init  initializes and returns the widget
--
function init(args) --- cardid, channel, colors, layout)
    local args = args or {}


    -- initialize widget then set its properties
    config.widget = awful.widget.progressbar({ ["layout"] = args.layout or 
                                    awful.widget.layout.horizontal.rightleft })

    config.widget:set_vertical(true)
    config.widget:set_width(args.width or 13)
    config.widget:set_height(args.height or 18)
    config.widget:set_border_color(args.border_color or beautiful.bg_focus)

    config.widget:set_background_color( args.background_color or 
                                        beautiful.vol_bg or "#000000")

    config.widget:set_color(    args.foreground_color or 
                                beautiful.fg_focus or "#ffffff")

    config.widget:set_gradient_colors(
            {   args.gradient_start or beautiful.fg_focus,
                args.gradient_stop or beautiful.fg_focus })


    -- set config's sound properties
    config.cardid  = args.cardid or 0
    config.channel = args.channel or "Master"

    -- run the update fx once then register a hook to update this
    vol("update")
    voltimer = timer { timeout = 10 }
    voltimer:add_signal("timeout", function () vol("update") end )
    voltimer:start()
    return config.widget
end
--}}}


-- vim: filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:

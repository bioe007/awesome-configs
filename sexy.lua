--! @file   sexy.lua
--
-- @brief Shows some fancy notifications.
--
-- @author  Perry Hargrave
-- @date    2011-06-15
--

-- Show fancy notifications for backlight and volume hotkeys. I originally found
-- this somewhere 'on the web' but can't remember.

local math = math
local string = string

local awful = awful
local beautiful = beautiful
local image = image
local naughty = naughty

module('sexy')

-- Put all show functions in here
show = {}

icon = {}


-- A list of all 'reports'
local reports = {}

local function base_notify(text, icon, id, position, screen)
    return naughty.notify({icon = icon,
                           position = position or "top_right",
                           replaces_id = id,
                           text = text,
                           screen = screen,
                           font = "Sans Bold 10"})
end

function fancy_notify(percent, icon_function, notification)
        local img = image.argb32(200, 50, nil)
        img:draw_rectangle(0, 0,
                           img.width, img.height,
                           true,
                           beautiful.bg_normal)
        img:insert(image(icon_function(percent)), 0, 1)
        img:draw_rectangle(60, 20, 130, 10, true, beautiful.bg_focus)
        img:draw_rectangle(62, 22,
                           126 * percent / 100, 6,
                           true,
                           beautiful.fg_focus)

        local id = nil
        if notification then id = notification.id end

        local msg = "\n" .. string.format("%4.1d%%", math.ceil(percent))
        return naughty.notify({icon = img,
                               replaces_id = id,
                               text = msg,
                               font = "Terminus Bold 14"})
end

-- Layout notification
function show.layout(t)
    local t = t or awful.tag.selected()
    if reports.layout then
        id = reports.layout.id
    else
        id = nil
    end
    lay_name = awful.layout.getname(awful.layout.get(t.screen))
    icon_name = beautiful.iconpath .. "/layouts/" .. lay_name .. ".png"
    reports.layout = base_notify(lay_name,
                                 icon_name,
                                 id,
                                 "top_left",
                                 t.screen)
end

function icon.get(s)
    return beautiful.iconpath .. s .. '.png'
end

function show.brightness(bright)
    reports.brightness = fancy_notify(brightness,
                                      function() icon.get('brightness') end,
                                      reports.brightness)
    return reports.brightness
end

function show.volume(vol, mute)
    local vg_icon = function()
        local icon_str = nil
        if vol > 70 then icon_str = "high"
        elseif vol > 30 then icon_str = "medium"
        elseif vol > 0 then icon_str = "low"
        elseif vol == 0 then icon_str = "off"
        end

        if mute then icon_str = "muted" end

        return icon.get("/volume/" .. icon_str)
    end

    reports.volume = fancy_notify(vol,
                                  vg_icon,
                                  reports.volume)
    return reports.volume
end

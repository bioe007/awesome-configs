-- useful markup functions for awesome
-- found somewhere (wiki maybe?) modularized and current:
-- by bioe007 perrydothargraveatgmaildotcom

local beautiful = require("beautiful")
local err = io.stderr
local autil = require("awful.util")

-- Markup helper functions
module("markup")

-- sometimes we get nil text or an undefined color from a widgets behavior
-- its very aggravating to think a crappy mp3 tag can ruin your day so i
-- try and catch these things here
local function werror(...)
    args = { n = select('#', ...), ... }

    err:write(table.concat(args, ' '))

    return autil.escape(table.concat(args, ' '))
end

function italic(text)
    if text == nil then
        return werror("markup: received nil text")
    else
        return '<i>'..text..'</i>'
    end
end

function bold(text)
    if text == nil then
        return werror("markup: received nil text")
    else
        return '<b>'..text..'</b>'
    end
end

function bg(color, text)
    if color == nil or text == nil then
        return werror("markup: received nil text or color", text, color)
    else
        return '<bg color="'..color..'" />'..text
    end
end

function fg(color, text)
    if color == nil or text == nil then
        return werror("markup: received nil text or color", text, color)
    else
        return '<span color="'..color..'">'..text..'</span>'
    end
end

function font(font, text)
    if font == nil or text == nil then
        return werror("markup: received nil text or color", text, font)
    else
        return '<span font_desc="'..font..'">'..text..'</span>'
    end
end

function title_focus(t)
    if t == nil or beautiful.bg_focus == nil or beautiful.fg_focus == nil then
        return werror("markup: received nil text or color", t)
    else
        return bg(beautiful.bg_focus, fg(beautiful.fg_focus, title(t)))
    end
end

function title_urgent(t)
    if t == nil or beautiful.bg_urgent == nil or beautiful.fg_urgent == nil then
        return werror("markup: received nil text", t)
    else
        return bg(beautiful.bg_urgent, fg(beautiful.fg_urgent, title(t)))
    end
end

function heading(text)
    if text == nil or beautiful.fg_focus == nil then
        return werror("markup: received nil text", text)
    else
        return fg(beautiful.fg_focus, bold(text))
    end
end

-- vim:set ft=lua fdm=indent tw=80 ts=4 sw=4 et sta ai si: --

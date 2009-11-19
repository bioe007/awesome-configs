-- useful markup functions for awesome
-- found somewhere (wiki maybe?) modularized and current:
-- by bioe007 perrydothargraveatgmaildotcom
local beautiful = require("beautiful")

-- Markup helper functions
module("markup")

function italic(text) return '<i>'..text..'</i>' end

function bold(text) return '<b>'..text..'</b>' end

function bg(color, text)
    if text ~= nil then
        return '<bg color="'..color..'" />'..text
    else
        return "niltexthere"
    end
end

function fg(color, text)
    if text ~= nil then
        return '<span color="'..color..'">'..text..'</span>'
    else
        return "niltexthere"
    end
end

function font(font, text)
    if text ~= nil then
        return '<span font_desc="'..font..'">'..text..'</span>'
    else
        return "niltexthere"
    end
end

function title_focus(t)
    return bg(beautiful.bg_focus, fg(beautiful.fg_focus, title(t)))
end

function title_urgent(t)
    return bg(beautiful.bg_urgent, fg(beautiful.fg_urgent, title(t)))
end

function heading(text)
    return fg(beautiful.fg_focus, bold(text))
end

-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

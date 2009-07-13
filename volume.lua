local io = io
local awful = require("awful")
local string = string
local beautiful = require("beautiful")
local print = print

local config = {}

module("volume")

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

-- returns the widget now
function init(cardid, channel, colors)

  config.widget = awful.widget.progressbar({ align = "right" })
  config.widget:set_width(13)
  config.widget:set_height(18)
  config.widget:set_vertical(true)
  -- config.widget:set_border_width(1)
  config.widget:set_border_color(beautiful.bg_focus)
  config.widget:set_gradient_colors({ beautiful.fg_focus, beautiful.fg_focus })
  config.widget:set_background_color(beautiful.vol_bg or "#000000")
  config.widget:set_color(beautiful.fg_focus or "#ffffff")

  config.cardid  = cardid or 0
  config.channel = channel or "Master"

  vol("update")
  awful.hooks.timer.register(10, function () vol("update") end, true)

  return config.widget
end
-- vim: filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent:

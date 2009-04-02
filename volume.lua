local io = io
local awful = require("awful")
local string = string
local beautiful = require("beautiful")

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

    if string.find(status, "on", 1, true) then
      -- volume = volume .. "%"
      config.widget:bar_properties_set("vol", {["bg"] = beautiful.vol_bg,
                                               ["border_color"] = beautiful.bg_focus, })
    else
      -- volume = volume .. "M"
      config.widget:bar_properties_set("vol", {["bg"] = beautiful.bg_normal,
                                               ["border_color"] = beautiful.bg_normal, })
    end
    -- config.widget.text = volume
    config.widget:bar_data_add("vol", volume)
  elseif mode == "up" then
    awful.util.spawn("amixer -q -c " .. config.cardid .. " sset " .. config.channel .." "..(percent or 5).."%+")
    vol("update")
  elseif mode == "down" then
    awful.util.spawn("amixer -q -c " .. config.cardid .. " sset " .. config.channel .." "..(percent or 5).."%-")
    vol("update")
  else
    awful.util.spawn("amixer -c " .. config.cardid .. " sset " .. config.channel .. " toggle")
    vol("update")
  end
end

function init(w, cardid, channel, colors)

  if not w then return end
  config.widget = w 
  config.cardid  = cardid or 0
  config.channel = channel or "Master"
  config.widget.width = 13
  config.widget.height = 0.93
  config.widget.border_padding = 1
  config.widget.ticks_count = 6
  config.widget.ticks_gap = 1

  config.widget.vertical = true
 
  config.widget:bar_properties_set("vol", 
  colors or { ["bg"] = beautiful.vol_bg,
                   ["fg"] = beautiful.fg_focus,
                   ["fg_center"] = beautiful.fg_focus, --"#ffffff", --beautiful.widg_cpu_mid,
                   ["fg_end"] = beautiful.fg_focus, -- "#ffffff", -- beautiful.widg_cpu_end,
                   ["fg_off"] = beautiful.bg_normal,
                   ["border_color"] = beautiful.bg_focus,
                 })

  vol("update")
  awful.hooks.timer.register(10, function () vol("update") end)

end
-- vim: filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent:

-- nice battery widget for awesome. 
-- user can config path to battery using 
--     battery.settings.ipath = <path to your info file>
--     battery.settings.spath = <path to your state file>
--
-- hal checking stolen from Kooky's battery widget
--
local io = io
local string = string
local math = math
local beautiful = require("beautiful")
local naughty = require("naughty")
local markup = require("markup")
local tonumber = tonumber

module("battery")
local battwarn 
local bwidget = {}
local device

settings = {}

--{{{ popup when battery level gets low
function showWarning(s)

  naughty.notify({ 
    text = markup.font("DejaVu Sans 8",
           markup.bold(
           markup.fg(beautiful.fg_batt_oshi or "#ff2233", "Warning, low battery! ".. s ))),
    timeout = 0, hover_timeout = 0.5,
    bg = beautiful.bg_focus,
    width = beautiful.battery_w or 160,
  })

end
--}}}

--{{{ gets percentage of charge in battery
function charge()
	 local level = 100
	 local hal = io.popen("hal-get-property --udi "..device.." --key battery.charge_level.percentage")
	 if hal ~= nil then
	    level = hal:read()
	    hal:close()
	 end
	 
	 return level
end
--}}}

--{{{ evaluates the ac adapter state
function state()
	 local plug = "charged"

	 local hal = io.popen("hal-get-property --udi "..device.." --key battery.rechargeable.is_discharging")
	 if hal ~= nil then
		 if hal:read():match("true") then
			 plug = "discharging"
		 else
			 hal = io.popen("hal-get-property --udi "..device.." --key battery.rechargeable.is_charging")
			 if hal:read():match("true") then
				 plug = "charging"
       end
		 end
		 hal:close()
	 end
	 
	 return plug
end
---}}}

--{{{ populates bwidget.text with current state symbol and percentage
function info()

  -- calculate remaining %
  local battery = tonumber(charge())

  -- colorize based on remaining battery charge
  if battery < 10 then
    battery = markup.fg(beautiful.fg_batt_oshi or "#ff0000", battery)

    -- check that we arent continuosly issue the battery warning
    if battwarn == false then
      showWarning(battery)
      battwarn = true
    end
  elseif battery < 25 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_crit or "#f8700a", battery)
  elseif battery < 50 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_low or "#e6f21d", battery)
  elseif battery < 75 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_mid or "#00cb00", battery)
  else
    battery = markup.fg( beautiful.fg_sb_hi or "#cfcfff", battery)
  end

  -- decide which and where to put the charging state indicator
	local adapter = state()
  if adapter:match("charged") then
    bwidget.text = "⚡"..battery.."↯"
  elseif adapter:match("discharging") then
    bwidget.text = "⚡"..battery.."▼"
  else
    bwidget.text = "⚡"..battery.."▲"
  end
end
---}}}

--{{{ 
function init(w, width)
  bwidget = w
  bwidget.width = width or 48
	local hal = io.popen("hal-find-by-capability --capability battery")
	if hal ~= nil then
		device = hal:read()
		hal:close()
	end
  info()
end
--}}}

-- vim: filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent:

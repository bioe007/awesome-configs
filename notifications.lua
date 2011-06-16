--! @file   notifications.lua
--
-- @brief
--
-- @author  Perry Hargrave
-- @date    2011-06-15
--

-- Show fancy notifications for backlight and volume hotkeys

function fancy_notify(percent, icon_function, notification)
	local img = image.argb32(200, 50, nil)
	img:draw_rectangle(0, 0, img.width, img.height, true, beautiful.bg_normal)
	img:insert(image(icon_function(percent)), 0, 1)
	img:draw_rectangle(60, 20, 130, 10, true, beautiful.bg_focus)
	img:draw_rectangle(62, 22, 126 * percent / 100, 6, true, beautiful.fg_focus)
	
	local id = nil
	if notification then id = notification.id end
	return naughty.notify({ icon = img, replaces_id = id,
							text = "\n" .. math.ceil(percent) .. "%",
							font = "Sans Bold 10" })
end
	

-- Brightness notifications
function brightness_down()
	brightness_adjust(-10)
end

function brightness_up()
	brightness_adjust(10)
end

local bright_notification = nil
function brightness_adjust(inc)
	-- Uncomment if your backlight keys don't work automatically
	--os.execute("xbacklight -inc " .. inc .. " > /dev/null 2>&1")
	local brightness = tonumber(awful.util.pread("xbacklight -get"))
	bright_notification =
		fancy_notify(brightness, brightness_get_icon, bright_notification)
end

function brightness_get_icon(brightness)
	return awful.util.getdir("config") .. "/icons/brightness.png"
end

-- Volume notifications

function volume_down()
	volume_adjust(-5)
end

function volume_up()
	volume_adjust(5)
end

function volume_mute()
	volume_adjust(0)
end

local vol_notification = nil
function volume_adjust(inc)
	if inc < 0 then inc = math.abs(inc) .. "%-"
	elseif inc > 0 then inc = inc .. "%+"
	else inc = "toggle" end
	os.execute("amixer set Master " .. inc .. " > /dev/null 2>&1")

	local volume = tonumber(
		awful.util.pread("amixer get Master | grep -om1 '[[:digit:]]*%' | tr -d %")
	)
	local is_muted = string.find(awful.util.pread("amixer get Master"),
								 '%[on%]') == nil
	if is_muted then volume = 0 end
	vol_notification = fancy_notify(volume, volume_get_icon, vol_notification)
end

function volume_get_icon(volume)
	local is_muted = string.find(awful.util.pread("amixer get Master"),
								 '%[on%]') == nil
	local icon_str = nil
	if volume > 70 then icon_str = "high.png"
	elseif volume > 30 then icon_str = "medium.png"
	elseif volume > 0 then icon_str = "low.png"
	elseif volume == 0 then icon_str = "off.png" end
	if is_muted then icon_str = "muted.png" end

        print(beautiful.iconpath .. "/volume/" .. icon_str)
	return beautiful.iconpath .. "/volume/" .. icon_str
	-- return awful.util.getdir("config") .. "//icons/volume-" .. icon_str
end


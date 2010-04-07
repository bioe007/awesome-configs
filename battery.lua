-- nice battery widget for awesome.
--
-- hal checking stolen from Kooky's battery widget
--
local io        = io
local string    = string
local math      = math
local select    = select
local type    = type
local tonumber  = tonumber
local pairs     = pairs
local ipairs     = ipairs
local beautiful = require("beautiful")
local naughty   = require("naughty")
local markup    = require("markup")
local timer     = timer
local widget = widget

module("battery")
local battwarn
local bwidget = {}
local device

config = {
    -- {{{
    bwidget = nil,
    width = 48,
    width_small = 10,
    width_warning = 200,
    timeout = 50,
    colors = {
        warn = "#ff0000",
        crit = "#f8700a",
        low  = "#e6f21d",
        mid  = "#00cb00",
        norm = "#cfcfff"
    },
    limits = {
        warn = 10,
        crit = 25,
        low  = 50,
        mid  = 75,
        norm = 100,
    },
}
-- }}}

--{{{ popup when battery level gets low
local function showWarning(s)

    naughty.notify({
        text = markup.font("DejaVu Sans 8",
            markup.bold(
                markup.fg(beautiful.fg_batt_oshi or "#ff2233",
                                "Warning, low battery! ".. s ))),
        timeout = 0,
        hover_timeout = 0.5,
        bg = beautiful.bg_focus,
        width = config.width_warning or 260,
    })

end
--}}}

--{{{ gets percentage of charge in battery
local function charge()
    local level = 100
    local hal = io.popen("hal-get-property --udi "..device..
                                " --key battery.charge_level.percentage")
    if hal ~= nil then
        level = hal:read()
        hal:close()
    end

    return level
end
--}}}

--{{{ evaluates the ac adapter state
local function state()
    local plug = "charged"

    local hal = io.popen("hal-get-property --udi "..device..
                                " --key battery.rechargeable.is_discharging")
    if hal ~= nil then
        if hal:read():match("true") then
            plug = "discharging"
        else
            hal = io.popen("hal-get-property --udi "..device..
                                    " --key battery.rechargeable.is_charging")
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
local function info()

    -- calculate remaining %
    local battery = tonumber(charge())

    for k, v in pairs(config.limits) do
        --{{{2 colorize and warn based on charge percent
        if battery < v then
            battery = markup.fg(config.colors[k], battery)
            if k == 'warn' then
                showWarning(battery)
                battWarn = true
            end
            break
        end
    end
    --2}}}

    -- decide which and where to put the charging state indicator
    local adapter = state()
    if adapter:match("charged") then
        bwidget.text = "↯"
        bwidget.width = config.width_small
    elseif adapter:match("discharging") then
        bwidget.width = config.width
        bwidget.text = "⚡"..battery.."▼"
    else
        bwidget.width = config.width
        bwidget.text = "⚡"..battery.."▲"
    end
end
---}}}

--{{{ initialize this widget
function init(...)

    bwidget = widget({ type = "textbox", align = "right" })

    -- parse vargs
    local args = {n = select( '#', ... ), ... }
    for k,v in pairs(args) do
        if type(v) == "table" then
            for k2,v2 in pairs(args[k]) do
                if config[k2] ~= nil then
                    config[k2] = v2
                end
            end
            args[k] = nil
        end
    end

    bwidget.width = config.width or 48

    battimer = timer { timeout = 50 }
    battimer:add_signal("timeout", info)
    battimer:start()

    local hal = io.popen("hal-find-by-capability --capability battery")
    if hal ~= nil then
        device = hal:read()
        hal:close()
    end

    info()
    return bwidget
end
--}}}

-- vim:set ft=lua fdm=marker ts=4 sw=4 et ai si: --

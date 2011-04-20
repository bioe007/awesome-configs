----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Wifi: provides wireless information for a requested interface
module("vicious.wifi")


-- {{{ Wireless widget type
local function worker(format, iface)
    -- Get data from iwconfig (where available)
    local f = io.popen("iwconfig " .. iface)
    local iw = f:read("*all")
    f:close()

    -- Default values
    local winfo = {
        ["{ssid}"] = "N/A",
        ["{mode}"] = "N/A",
        ["{chan}"] = "N/A",
        ["{rate}"] = "N/A",
        ["{link}"] = "N/A",
        ["{sign}"] = "N/A"
    }

    -- Check if iwconfig wasn't found, can't be executed or the
    -- interface is not a wireless one
    if iw == nil or string.find(iw, "No such device") then
        return winfo
    else
        -- The output differs from system to system, some stats can
        -- be separated by =, and not all drivers report all stats
        winfo["{ssid}"] =  -- SSID can have almost anything in it
          string.match(iw, 'ESSID[=:]"([%w%p]+[%s]*[%w%p]*]*)"') or winfo["{ssid}"]
        winfo["{mode}"] =  -- Modes are simple, but also match the "-" in Ad-Hoc
          string.match(iw, "Mode[=:]([%w%-]*)") or winfo["{mode}"]
        winfo["{chan}"] =  -- Channels are plain digits
          string.match(iw, "Channel[=:]([%d]+)") or winfo["{chan}"]
        winfo["{rate}"] =  -- Bitrate can start with a space and we want to display Mb/s
          string.match(iw, "Bit Rate[=:]([%s]?[%d%.]*[%s][%/%a]+)") or winfo["{rate}"]
--      winfo["{link}"] =  -- Link quality can contain a slash: 32/100
--        string.match(iw, "Link Quality[=:]([%d]+[%/%d]*)") or winfo["{link}"]
        winfo["{link}"] =  --  * match only the first number, great data for a progressbar
          string.match(iw, "Link Quality[=:]([%d]+)") or winfo["{link}"]
        winfo["{sign}"] =  -- Signal level can be a negative value, also display decibel notation
          string.match(iw, "Signal level[=:]([%-%d]+[%s][%a]*)") or winfo["{sign}"]
    end

    return winfo
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })

---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local math = { ceil = math.ceil }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local io = {
    open = io.open,
    popen = io.popen
}
local string = {
    find = string.find,
    match = string.match
}
-- }}}


-- Wifi: provides wireless information for a requested interface
module("vicious.widgets.wifi")


-- {{{ Wireless widget type
local function worker(format, warg)
    if not warg then return end

    -- Default values
    local winfo = {
        ["{ssid}"] = "N/A",
        ["{mode}"] = "N/A",
        ["{chan}"] = 0,
        ["{rate}"] = 0,
        ["{link}"] = 0,
        ["{linp}"] = 0,
        ["{sign}"] = 0
    }

    -- Get data from iwconfig where available
    local iwconfig = "/sbin/iwconfig"
    local f = io.open(iwconfig, "rb")
    if not f then
        iwconfig = "/usr/sbin/iwconfig"
    else
        f:close()
    end
    local f = io.popen(iwconfig .." ".. warg .. " 2>&1")
    local iw = f:read("*all")
    f:close()

    -- iwconfig wasn't found, isn't executable, or non-wireless interface
    if iw == nil or string.find(iw, "No such device") then
        return winfo
    end

    -- Output differs from system to system, some stats can be
    -- separated by =, and not all drivers report all stats
    winfo["{ssid}"] =  -- SSID can have almost anything in it
      helpers.escape(string.match(iw, 'ESSID[=:]"(.-)"') or winfo["{ssid}"])
    winfo["{mode}"] =  -- Modes are simple, but also match the "-" in Ad-Hoc
      string.match(iw, "Mode[=:]([%w%-]*)") or winfo["{mode}"]
    winfo["{chan}"] =  -- Channels are plain digits
      tonumber(string.match(iw, "Channel[=:]([%d]+)") or winfo["{chan}"])
    winfo["{rate}"] =  -- Bitrate can start with a space, we don't want to display Mb/s
      tonumber(string.match(iw, "Bit Rate[=:]([%s]?[%d%.]*)") or winfo["{rate}"])
    winfo["{link}"] =  -- Link quality can contain a slash (32/70), match only the first number
      tonumber(string.match(iw, "Link Quality[=:]([%d]+)") or winfo["{link}"])
    winfo["{sign}"] =  -- Signal level can be a negative value, don't display decibel notation
      tonumber(string.match(iw, "Signal level[=:]([%-]?[%d]+)") or winfo["{sign}"])

    -- Link quality percentage if quality was available
    if winfo["{link}"] ~= 0 then winfo["{linp}"] = math.ceil(winfo["{link}"] / 0.7) end

    return winfo
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })

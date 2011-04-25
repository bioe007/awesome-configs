local io        = io
local string    = string
local pairs     = pairs
local beautiful = require("beautiful")
local timer     = timer
local widget    = widget
local markup    = require("markup")

module("fs")

local fs = {}
fs.config = {}
fs.config.parts = {}

-- part - table partitions and labels
local function add(part)
    if not part then return false end

    for k, v in pairs(part) do
        fs.config.parts[k] = v
    end
end

local function fmt(key)
    s1 = markup.fg(beautiful.fg_normal, fs.config.parts[key].label .. ":")
    s2 = markup.fg(beautiful.fg_sb_hi, fs.config.parts[key].use)
    return s1 .. s2
end

local function use(key, line)
    m = "%d+%%.*$"
    p = "%%%s.*$"
    fs.config.parts[key].use = string.format('%3d',
                                             string.gsub(line:match(m), p, ""))
    return fs.config.parts[key].use
end

-- stats - computes disk usage and assigns to config.stats
-- return str : formatted string to display disk usage
local function stats()
    local fd = io.popen('df -h')
    local tmp = ""

    for line in fd:lines() do
        key = line:match("^/%w+/%w+")
        if key then
            key = string.gsub(key, "^/%w+/", "")
            if fs.config.parts[key] then
                use(key, line)
                tmp = tmp .. fmt(key) .. " "
            end
        end
    end
    fd:close()
    fs.widget.text = tmp:gsub("%s+$", "")
end

-- w - the widget
-- args - table partitions, labels, config settings
function init(args)
    if not args then return end

    add(args.parts)
    fs.config.interval = args.interval or 59
    fs.widget = widget({type = "textbox", align = "right"})
    stats()
    fstimer = timer {timeout = fs.config.interval}
    fstimer:add_signal("timeout", stats)
    fstimer:start()
    return fs.widget
end

local io = io
local awful = require("awful")
local pairs = pairs
local string = string
local markup = require("markup")
local beautiful = require("beautiful")

module("fs")

local fs = {}
fs.config = {}
fs.config.parts = {}

-- {{{ add 
-- @param args - table partitions and labels
local function add(part)

  if not part then return false end

  for k,v in pairs(part) do
    fs.config.parts[k] = v
  end

end
-- }}}

-- {{{ stats : computes disk usage and assigns to config.stats
-- @return str : formatted string to display disk usage
local function stats()
  local fd = io.popen('df -h')
  local tmp = ""
  for line in fd:lines() do
    key = line:match("^/%w+/%w+")
    if key then
      key = string.gsub(key,"^/%w+/","")
      if fs.config.parts[key] then
        fs.config.parts[key].use = string.format('%3d',string.gsub(line:match("%d+%%.*$"),"%%%s.*$",""))
        tmp = tmp..markup.fg(beautiful.fg_normal,fs.config.parts[key].label..":")..markup.fg(beautiful.fg_sb_hi,fs.config.parts[key].use).." "
      end
    end
  end
  fs.widget.text = tmp
  fd:close()
end
-- }}}

-- {{{ init
-- @param w - the widget
-- @param args - table partitions, labels, config settings
function init(w,args)

  if not (w and args) then return end

  add(args.parts)

  fs.config.interval = args.interval or 59
  fs.widget = w
  stats()
  awful.hooks.timer.register(fs.config.interval,stats)

end
-- }}} 

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80

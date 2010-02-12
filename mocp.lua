-- mocp.lua: a mocp widget for awesome
--
-- can be configured:
--   require('mocp.lua')
--   w = mocp.init(args)
--
-- where args is a table of configuration parameters
-- see below the 'config' table for possible values
--
-- perrydothargraveatgmaildotcom 
-- bioe007
--
--
local io        = io
local string    = string
local pairs     = pairs
local awful     = require("awful")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local markup    = require("markup")
local timer     = timer
local widget    = widget

module("mocp")

local COMMANDS = {
    --{{{ player commands
    ["PLAY"]  = 'mocp --play',
    ["PAUSE"] = 'mocp --toggle-pause',
    ["FWD"]   = 'mocp --next',
    ["REV"]   = 'mocp --previous' ,
    ["STOP"]  = 'mocp --stop'
}
-- }}}

local mocbox = nil
local trackinfo = {
    artist    = "",
    songtitle = "",
    album     = "",
    state     = ""
}

local iScroll = 1

local config = {
    -- {{{ configuration variables are set by passing {args} to init()
    buttons = awful.util.table.join(
        awful.button({}, 1, function() play("FWD")    end),
        awful.button({}, 2, function() play("PAUSE")  end),
        awful.button({}, 4, function() play("FWD")    end),
        awful.button({}, 3, function() play("REV")    end),
        awful.button({}, 5, function() play("REV")    end)
    ),
    colors = { focus = beautiful.fg_focus,
                normal = beautiful.fg_normal,
                sb_hi = (beautiful.fg_sb_hi or beautiful.fg_focus)
    },
    interval = { cur = 0.75,
                 run = 0.75,
                 paused = 2
    },
    iScroller = 1,
    max_chars = 15,
    tooltip = nil,
    popup = { 
        timeout = 3,
        border_width = 2,
        width = 300,
        icon_size = 48,
        margin = 10
    },
    width = 122,
    width_stop = 20
}
--}}}


local function state()
    -- {{{  updates trackinfo.state [ PLAY|PAUSE|STOP|OFF ]
    -- and makes widget text/size changes as needed

    local fd = {}
    local tmp = nil
    local state ="" 

    fd = io.popen('pgrep -fx \'mocp\'')

    tmp = fd:read()
    if tmp == nil then 
        fd = io.popen('pgrep -fx \'mocp --server\'')
        tmp = fd:read()
    end

    if tmp ~= nil then 
        fd:close()

        fd = io.popen('mocp -i')
        trackinfo.state = string.gsub(fd:read(),"State:%s*","")
        fd:close()

        if trackinfo.state == "STOP" then
            return false
        else
            config.widget.width = config.width
            return true
        end
    else
        trackinfo.state = "OFF"
        config.widget.text = "" 
        config.widget.width = 0
    end

    fd:close()
end
---}}}


local function setTitle()
    -- {{{ local setTitle
    -- call to force update of trackinfo variables

    local fd = {}

    if not (trackinfo.state == "OFF" or trackinfo.state == "STOP") then 
        fd = io.popen('mocp -i')

        -- read to end of mocp -i
        for line in fd:lines() do
            key = string.match(line,"^%w+")
            if trackinfo[key:lower()] ~= nil then
                trackinfo[key:lower()] = awful.util.escape(
                string.gsub(string.gsub(line,key..":%s*",""),"%b()",""))
            end
        end
        fd:close()
    end

end
---}}}


local function title(delim)
    -- {{{ local title(delim)

    local eol = delim or " "
    local np = {}

    if trackinfo.artist == "" and state() then setTitle() end
    np.song = string.gsub( string.gsub(trackinfo.songtitle,"^%d*",""),"%(.*","") .. eol

    -- return for widget text
    return trackinfo.artist.." : "..np.song

end
--}}}


local function notdestroy()
    -- {{{ destroy notification
    if mocbox ~= nil then
        naughty.destroy(mocbox)
        mocbox = nil
    end
end
--}}}


local function getTime()
    -- {{{ gets ct and tt of track for popup
    -- return string containig formatted times
    local fd = {}
    local ttable = {}
    fd = io.popen('mocp -i')

    for line in fd:lines() do
        key = string.match(line,"^%w+")
        if key == "TotalTime" then
            tstring = " [ "..markup.fg(config.colors.focus,
            awful.util.escape(string.gsub(string.gsub(line,key..":%s*",""),"%b()",""))).." ]"
        elseif key == "CurrentTime" then
            tstring = markup.fg(config.colors.normal,"Time:   ")..
            markup.fg(config.colors.focus,
            awful.util.escape(string.gsub(string.gsub(line,key..":%s*",""),"%b()","")))..tstring
        end
    end

    fd:close()

    return tstring
end
--}}}


local function scroller(tb)
    -- {{{ scrolls text
    local np = {}

    -- if mocp is not running, then simply return here
    if trackinfo.state == "OFF" then
        iScroll = 1
        state()
        return
    else
        -- this sets the symbolic prefix based on if moc is playing/stopped/paused
        if trackinfo.state == "PAUSE" then
            prefix = "|| "
            config.interval.cur = config.interval.paused
        elseif trackinfo.state == "STOP" then
            iScroll = 1
            config.interval.cur = config.interval.paused
            config.widget.width = config.width_stop
            config.widget.text = "⬣"
            return
        else
            prefix = "▶ "
            config.interval.cur = config.interval.run
        end

        -- extract a substring, putting it after the 
        np.strng = title()
        np.rtn = string.sub(np.strng, iScroll, config.max_chars + iScroll -1) 

        -- if our index and config.max_chars count are bigger than the string,
        -- wrap around to the beginning and add enough to make it look circular
        if config.max_chars + iScroll > (np.strng):len() then
            np.rtn = np.rtn..string.sub(np.strng, 1,
                            (config.max_chars + iScroll -1) - np.strng:len())
        end

        np.rtn = awful.util.escape(np.rtn)
        config.widget.text = markup.fg( config.colors.normal, prefix)..
                                        markup.fg(config.colors.sb_hi, np.rtn)

        if iScroll <= np.strng:len() then
            iScroll = iScroll +1
        else
            iScroll = 1
        end
    end
end
-- }}}


local function popup()
    --{{{ displays a notification of the current track
    setTitle()
    notdestroy()

    local np = {}
    np.state = nil
    np.strng = ""

    if not state() then
        return
    else
        np.strng = "Artist: "..markup.fg(config.colors.focus, trackinfo.artist)..
                    "\n"..
                    "Song:   "..markup.fg(config.colors.focus, trackinfo.songtitle)..
                    "\n"..
                    "Album:  "..markup.fg(config.colors.focus,
                        string.gsub(trackinfo.album, ".*Sound", "Soundtrack"))..
                    "\n"..
                    markup.fg(config.colors.focus, getTime())
    end

    mocbox = naughty.notify({ 
        title = markup.italic(markup.bold("Now Playing:")),
        text = np.strng,
        hover_timeout = ( config.hovertime or 3 ),
        timeout = 3,
        border_width = 2,
        width = 300,
        icon = config.iconpath or nil,
        icon_size = 48,
        margin = 10,
        run = function() play(); popup() end
    })
end
---}}}


function play(plyrCmd) 
    -- {{{ easier way to check|run mocp

    -- break on unknown commands
    if not COMMANDS[plyrCmd] then return end

    -- start server if not running
    if trackinfo.state == "OFF" and not ( COMMANDS[plyrCmd] == COMMANDS["STOP"] ) then
        awful.util.spawn('\"mocp --server\"',false)

        -- if starting, then turn most commands to play
        if COMMANDS[plyrCmd] == COMMANDS["FWD"] or 
            COMMANDS[plyrCmd] == COMMANDS["REV"] or
            COMMANDS[plyrCmd] == COMMANDS["PAUSE"] then

            plyrCmd = COMMANDS["PLAY"] 
        end
    end

    awful.util.spawn(COMMANDS[plyrCmd],false)
    state()
    popup()

end
--}}}


function update (k, v)
    -- {{{ called by external script to trigger widget text update
    if #k == 0 or #v == 0 then return end
    if trackinfo[k] ~= nil then
        trackinfo[k] = v
    end
    state()
end
--}}}


function init(args)
    -- {{{1 init() 

    -- assign configuration params
    args = args or {}
    for k, v in pairs(args) do
        if k == "iconpath" then
            config.iconpath = args.iconpath 
        elseif config[k] ~= nil then
            config[k] = v
        end
    end

    config.widget = widget({type="textbox", align = args.align or "right"})

    -- assign buttons
    config.widget:buttons( config.buttons )

    -- the basic timer which scrolls text
    moctimer = timer { timeout = config.interval.cur }
    moctimer:add_signal("timeout", scroller)
    moctimer:start()

    -- on mouseenter, we delay before showing the popup info
    mocpoptimer = timer { timeout = 2 }
    mocpoptimer:add_signal("timeout", popup)

    -- what to do when mouse over
    config.widget:add_signal("mouse::enter", function() mocpoptimer:start() end)
    config.widget:add_signal("mouse::leave", function() mocpoptimer:stop() end)

    -- check current state (to populate widget)
    state()
    return config.widget
end
--1}}}


-- vim: ft=lua fdm=marker tw=80 ts=4 sw=4 et sta ai si:

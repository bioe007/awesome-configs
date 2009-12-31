-- a mocp widget for awesome
--
-- perrydothargraveatgmaildotcom 
-- bioe007
--
--
local io        = io
local string    = string
local awful     = require("awful")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local markup    = require("markup")
local button    = button
local timer     = timer
local widget    = widget


module("mocp")

--{{{ variables
local COMMANDS = {
    ["PLAY"]  = 'mocp --play',
    ["PAUSE"] = 'mocp --toggle-pause',
    ["FWD"]   = 'mocp --next',
    ["REV"]   = 'mocp --previous' ,
    ["STOP"]  = 'mocp --stop'
}

local mocbox = nil
local trackinfo = {
    artist    = "",
    songtitle = "",
    album     = "",
    state     = ""
}

local iScroll = 1
-- public config
config = {
    iScroller = 1,
    MAXCH     = 15,
    interval  = 0.75,
    tooltip = nil,
    popup = { 
        timeout = 3,
        border_width = 2,
        width = 300,
        icon_size = 48,
        margin = 10
    }
}
--}}}

-- {{{ local state()
-- updates trackinfo.state [ PLAY|PAUSE|STOP|OFF ]
-- and makes widget text/size changes as needed
local function state()

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
            config.widget.width = 122
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

-- {{{ local setTitle
-- call to force update of trackinfo variables
local function setTitle()

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

-- {{{ local title(delim)
local function title(delim)

    local eol = delim or " "
    local np = {}

    if trackinfo.artist == "" and state() then setTitle() end
    np.song = string.gsub( string.gsub(trackinfo.songtitle,"^%d*",""),"%(.*","") .. eol

    -- return for widget text
    return trackinfo.artist.." : "..np.song

end
--}}}

-- {{{ local function notdestroy()
local function notdestroy()
    if mocbox ~= nil then
        naughty.destroy(mocbox)
        mocbox = nil
    end
end
--}}}

-- {{{ local getTime() gets ct and tt of track for popup
-- return string containig formatted times
local function getTime()
    local fd = {}
    local ttable = {}
    fd = io.popen('mocp -i')

    for line in fd:lines() do
        key = string.match(line,"^%w+")
        if key == "TotalTime" then
            tstring = " [ "..markup.fg(beautiful.fg_normal,
            awful.util.escape(string.gsub(string.gsub(line,key..":%s*",""),"%b()",""))).." ]"
        elseif key == "CurrentTime" then
            tstring = markup.fg(beautiful.fg_focus,"Time:   ")..
            markup.fg(beautiful.fg_normal,
            awful.util.escape(string.gsub(string.gsub(line,key..":%s*",""),"%b()","")))..tstring
        end
    end

    fd:close()

    return tstring
end
--}}}

-- {{{ local scroller 
-- mocp widget, scrolls text
local function scroller(tb)
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
            config.interval = 2
        elseif trackinfo.state == "STOP" then
            iScroll = 1
            config.widget.width = 20
            config.widget.text = "⬣"
            return
        else
            prefix = "▶ "
            config.interval = 0.75
        end

        -- extract a substring, putting it after the 
        np.strng = title()
        np.rtn = string.sub(np.strng,iScroll,config.MAXCH+iScroll-1) 

        -- if our index and config.MAXCH count are bigger than the string, wrap around to the beginning and
        -- add enough to make it look circular
        if config.MAXCH+iScroll > (np.strng):len() then
            np.rtn = np.rtn .. string.sub(np.strng,1,(config.MAXCH+iScroll-1)-np.strng:len())
        end

        np.rtn = awful.util.escape(np.rtn)
        config.widget.text =    markup.fg( beautiful.fg_normal,prefix) ..
                                markup.fg((beautiful.fg_sb_hi or beautiful.fg_focus),np.rtn) 

        if iScroll <= np.strng:len() then
            iScroll = iScroll +1
        else
            iScroll = 1
        end
    end
end
-- }}}

-- {{{ local popup
-- displays a naughty notificaiton of the current track
local function popup()
    setTitle()
    notdestroy()

    local np = {}
    np.state = nil
    np.strng = ""
    if not state() then
        return
    else
        np.strng = "Artist: "..markup.fg(beautiful.fg_normal,trackinfo.artist).."\n"..
        "Song:   "..markup.fg(beautiful.fg_normal,trackinfo.songtitle).."\n"..
        "Album:  "..markup.fg(beautiful.fg_normal,string.gsub(trackinfo.album,".*Soundt","Soundtrack")).."\n"
        np.strng = np.strng..markup.fg(beautiful.fg_normal,getTime())
    end

    -- destroy the tooltip
    moctip(false)

    -- np.strng = markup.fg( beautiful.fg_focus, markup.font("monospace", np.strng.."  "))  
    mocbox = naughty.notify({ 
        title = markup.italic(markup.bold("Now Playing:")),
        text = np.strng,
        hover_timeout = ( config.hovertime or 3 ),
        timeout = 3,
        border_width = 2,
        width = 300,
        icon = config.icon or nil,
        icon_size = 48,
        margin = 10,
        run = function() play(); popup() end
    })
end
---}}}

-- {{{ mocplay 
-- easier way to check|run mocp
function play(plyrCmd) 

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

-- {{{ moctip
local function moctip(toggle)
    if toggle and config.tooltip == nil then
        config.tooltip = awful.tooltip({
            objects = {config.widget},
            timer_function = function()
                -- if mocbox ~= nil then 
                -- config.tooltip:remove_from_object(config.widget)
                -- config.tooltip.visible =false
                -- end
                return "\r\t"..markup.heading(trackinfo.artist)..": "..markup.italic(trackinfo.songtitle).."\t\r"
            end})
    else
        config.tooltip:remove_from_object(config.widget)
        config.tooltip=nil
    end
end
--}}}

-- {{{ setwidget
local function setwidget()

    config.widget = widget({type="textbox",align = "right"})

    config.widget.width = 120

    --{{{ assign buttons
    config.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function() play("FWD")    end),
        awful.button({}, 2, function() play("PAUSE")  end),
        awful.button({}, 4, function() play("FWD")    end),
        awful.button({}, 3, function() play("REV")    end),
        awful.button({}, 5, function() play("REV")    end)
    ))
    --}}}

    moctimer = timer { timeout = config.interval }
    moctimer:add_signal("timeout", scroller)
    moctimer:start()

    mocpoptimer = timer { timeout = 2 }
    mocpoptimer:add_signal("timeout", popup)

    -- what to do when mouse over
    config.widget:add_signal("mouse::enter", function() mocpoptimer:start() end)
    config.widget:add_signal("mouse::leave", function() 
            -- re-add the tooltip
            moctip(true)
            mocpoptimer:stop() 
        end)

end
--}}}

-- {{{ function update ( k, v)
-- called by any kind of external script to trigger widget text update
function update ( k, v )
    if #k == 0 or #v == 0 then return end
    if trackinfo[k] ~= nil then
        trackinfo[k] = v
    end
    state()
end
--}}}

function init(icon)
    config.icon = icon
    setwidget()
    state()
    moctip(true)
    return config.widget
end


-- vim: filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:

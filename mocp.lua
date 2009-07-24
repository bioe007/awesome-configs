local io        = io
local string    = string
local awful     = require("awful")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local markup    = require("markup")
local button    = button

local print = print -- debug

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

-- public settings
settings = {
  iScroller = 1,
  MAXCH     = 15,
  interval  = 0.75,
}
--}}}

---{{{ local state()
-- updates trackinfo.state [ PLAY|PAUSE|STOP|OFF ]
-- and makes widget text/size changes as needed
local function state()

  local fd = {}
  local state ="" 

  fd = io.popen('pgrep -fx \'mocp --server\'')

  if fd:read() ~= nil then 
    fd:close()

    fd = io.popen('mocp -i')
    trackinfo.state = string.gsub(fd:read(),"State:%s*","")
    fd:close()

    if trackinfo.state == "STOP" then
      return false
    else
      settings.widget.width = 112
      return true
    end
  else
    trackinfo.state = "OFF"
    settings.widget.text = "" 
    settings.widget.width = 0
  end

  fd:close()
end
---}}}

---{{{ local setTitle
-- call to force update of trackinfo variables
local function setTitle()

  local fd = {}

  if not (trackinfo.state == "OFF" or trackinfo.state == "STOP") then --state() then
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
  else

    print("not state")
  end

end
---}}}

---{{{ local title(delim)
local function title(delim)

  local eol = delim or " "
  local np = {}

  if trackinfo.artist == "" and state() then setTitle() end
  np.song =string.gsub( string.gsub(trackinfo.songtitle,"^%d*",""),"%(.*","") .. eol

  -- return for widget text
  return trackinfo.artist.." : "..np.song

end
---}}}

---{{{ local function notdestroy()
local function notdestroy()
  if mocbox ~= nil then
    naughty.destroy(mocbox)
    mocbox = nil
  end
end
---}}}

---{{{ local getTime() gets ct and tt of track for popup
--@return string containig formatted times
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
---}}}

-- {{{ local scroller 
-- mocp widget, scrolls text
local function scroller(tb)
  local np = {}

  -- if mocp is not running, then simply return here
  if trackinfo.state == "OFF" then
    settings.iScroller = 1
    state()
    return
  else
    -- this sets the symbolic prefix based on where moc is playing | (stopped or paused)
    if trackinfo.state == "PAUSE" then
      prefix = "|| "
      settings.interval = 2
    elseif trackinfo.state == "STOP" then
      settings.iScroller = 1
      settings.widget.width = 20
      settings.widget.text = "⬣"
      return
    else
      prefix = "▶ "
      settings.interval = 0.75
    end

    -- extract a substring, putting it after the 
    np.strng = title()
    np.rtn = string.sub(np.strng,settings.iScroller,settings.MAXCH+settings.iScroller-1) 

    -- if our index and settings.MAXCH count are bigger than the string, wrap around to the beginning and
    -- add enough to make it look circular
    if settings.MAXCH+settings.iScroller > (np.strng):len() then
      np.rtn = np.rtn .. string.sub(np.strng,1,(settings.MAXCH+settings.iScroller-1)-np.strng:len())
    end

    np.rtn = awful.util.escape(np.rtn)
    settings.widget.text = markup.fg(beautiful.fg_normal,prefix) .. markup.fg( (beautiful.fg_sb_hi or beautiful.fg_focus),np.rtn) 

    if settings.iScroller <= np.strng:len() then
      settings.iScroller = settings.iScroller +1
    else
      settings.iScroller = 1
    end
  end
end
-- }}}

---{{{ local popup
-- displays a naughty notificaiton of the current track
local function popup()
  -- awful.hooks.timer.unregister(popup)
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
               "Album:  "..markup.fg(beautiful.fg_normal,trackinfo.album).."\n"
    np.strng = np.strng..markup.fg(beautiful.fg_normal,getTime())
  end
  np.strng = markup.fg( beautiful.fg_focus, markup.font("monospace", np.strng.."  "))  
  mocbox = naughty.notify({ 
    title = markup.font("monospace","Now Playing:"),
    text = np.strng, hover_timeout = ( settings.hovertime or 3 ), timeout = 3,
    border_width = 1,
    width = 200,
    -- icon = "/usr/share/icons/gnome/24x24/actions/edia-playback-start.png", icon_size = 24,
    run = function() play(); popup() end
  })
end
---}}}


---{{{ mocplay() 
-- easier way to check|run mocp
function play(plyrCmd) 

  -- break on unknown commands
  if not COMMANDS[plyrCmd] then return end

  -- start server if not running
  if trackinfo.state == "OFF" and not ( COMMANDS[plyrCmd] == COMMANDS["STOP"] ) then
    awful.util.spawn('urxvt -e sh -c \"mocp --server\"',false)
    state()

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
---}}}

function setwidget(w)

  settings.widget = w

  -- assign buttons
  settings.widget:buttons ({
    button({}, 1, function() play("FWD")    end),
    button({}, 2, function() play("PAUSE")  end),
    button({}, 4, function() play("FWD")    end),
    button({}, 3, function() play("REV")    end),
    button({}, 5, function() play("REV")    end)
  })

  -- what to do when mouse over
  settings.widget.mouse_enter = function() awful.hooks.timer.register(1,popup) end
  settings.widget.mouse_leave = function() awful.hooks.timer.unregister(popup) end

  awful.hooks.timer.register (settings.interval,scroller)
  state()
end

---{{{ function update ( k, v)
-- called by any kind of external script to trigger widget text update
function update ( k, v )
  if #k == 0 or #v == 0 then return end
  if trackinfo[k] ~= nil then
    trackinfo[k] = v
  end
  state()
end
---}}}

-- vim: filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent:


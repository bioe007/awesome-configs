local io = io
local string = string
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local markup = require("markup")

module("mocp")

-- public settings
settings = {}
settings.iScroller = 1
settings.MAXCH = 15
settings.interval = 0.75

local mocbox = nil
local trackinfo = {}
trackinfo.artist = ""
trackinfo.songtitle = ""
trackinfo.album = ""
trackinfo.state = ""

---{{{ local state()
-- updates trackinfo.state [ PLAY|PAUSE|STOP|OFF ]
-- and makes widget text/size changes as needed
local function state()

  local fd = {}
  local state ="" 

  fd = io.popen('pgrep -fx mocp')

  if fd ~= nil then 
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

  if state() then
    fd = io.popen('mocp -i')

    -- read to end of mocp -i
    for line in fd:lines() do
      key = string.match(line,"^%w+")
      if trackinfo[key:lower()] ~= nil then
        trackinfo[key:lower()] = awful.util.escape(string.gsub(string.gsub(line,key..":%s*",""),"%b()",""))
      end
    end
  end
  fd:close()

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

---{{{ popup
-- displays a naughty notificaiton of the current track
function popup()
  -- awful.hooks.timer.unregister(popup)
  setTitle()
  notdestroy()

  local np = {}
  np.state = nil
  np.strng = ""
  if not state() then
    return
  else
    np.strng =  "Artist: "..markup.fg(beautiful.fg_normal,trackinfo.artist).."\n"..
                "Song:   "..markup.fg(beautiful.fg_normal,trackinfo.songtitle).."\n"..
                "Album:  "..markup.fg(beautiful.fg_normal,trackinfo.album).."\n"
    np.strng = np.strng..markup.fg(beautiful.fg_normal,getTime())
  end
  np.strng = markup.fg( beautiful.fg_focus, markup.font("monospace", np.strng.."  "))  
  mocbox = naughty.notify({ 
    title = markup.font("monospace","Now Playing:"),
    text = np.strng, hover_timeout = ( settings.hovertime or 3 ), timeout = 3,
    -- icon = "/usr/share/icons/gnome/24x24/actions/edia-playback-start.png", icon_size = 24,
    run = function() play(); popup() end
  })
end
---}}}

---{{{ mocplay() 
-- easier way to check|run mocp
function play() 
  if trackinfo.state == "STOP" then
    awful.util.spawn('mocp --play') 
  elseif trackinfo.state == "PLAY" then
    awful.util.spawn('mocp --next')
  else 
    if trackinfo.state == "PLAY" then
      trackinfo.state = "PAUSE"
    else
      trackinfo.state = "PLAY"
    end

    awful.util.spawn('mocp --toggle-pause')
  end
end
---}}}

function setwidget(w)
  settings.widget = w
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

-- {{{ mocp widget, scrolls text
function scroller(tb)
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
    settings.widget.text = markup.fg(beautiful.fg_normal,prefix) .. markup.fg(beautiful.fg_sb_hi,np.rtn) 

    if settings.iScroller <= np.strng:len() then
      settings.iScroller = settings.iScroller +1
    else
      settings.iScroller = 1
    end
  end
end
-- }}}

-- vim: filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent:


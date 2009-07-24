-- rc.lua for awesome-git'ish window manager
---------------------------
-- bioe007, perrydothargraveatgmaildotcom
--
print("Entered rc.lua: " .. os.time())
require("awful")
require("beautiful")
require("wicked")
require("naughty")
-- custom modules
require("shifty")
require("markup")
require("mocp")
require("calendar")
require("battery")
require("markup")
require("fs")
require("volume")
print("Modules loaded: " .. os.time())

-- {{{ Variable definitions
settings = {
  ["modkey"] = "Mod4",
  ["theme_path"] = "/home/perry/.config/awesome/themes/blue/theme.lua",
  ["icon_path"] = beautiful.iconpath,

  --{{{ apps
  ["apps"] = {
    ["terminal"]  = "urxvt",
    ["browser"]   = "firefox",
    ["mail"]      = "thunderbird",
    ["filemgr"]   = "pcmanfm",
    ["music"]     = "mocp --server",
    ["editor"]    = os.getenv("EDITOR") or "vim",
  },
  --}}}

  --{{{ settings.layouts
  ["layouts"] = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
  },
  --}}}

  -- {{{ opacity
  ["opacity"] = { 
    ["default"] = { focus = 1.0, unfocus = 0.8 },
    ["Easytag"] = { focus = 1.0, unfocus = 0.9 },
    ["Gschem"] = { focus = 1.0, unfocus = 1.0 },
    ["Gimp"] = { focus = 1.0, unfocus = 1.0 },
  },
  -- }}}
}

--{{{ SHIFTY configuration
--{{{ configured tags
shifty.config.tags = {
  ["w2"]     =  { layout = awful.layout.suit.tile.bottom , mwfact = 0.62,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 2 }, 

  ["w1"]     =  { layout = awful.layout.suit.tile        , mwfact = 0.62,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 1, slave = true  }, 

  ["ds"]     =  { layout = awful.layout.suit.max        , mwfact = 0.70,
                exclusive = false, solitary = false, position = 2, init = false,
                persist = false, nopopup = false , slave = false }, 

  ["dz"]     =  { layout = awful.layout.suit.tile       , mwfact = 0.70,
                exclusive = false, solitary = false, position = 3, init = false,
                nopopup = true, leave_kills = true }, 

  ["web"]    =  { layout = awful.layout.suit.tile.bottom, mwfact = 0.65,
                exclusive = true, solitary = true, position = 4,  init = false,
                spawn   = settings.apps.browser }, 

  ["mail"]   =  { layout = awful.layout.suit.tile        , mwfact = 0.55,
                exclusive = false, solitary = false, position = 5, init = false,
                spawn   = settings.apps.mail, slave       = true  }, 

  ["vbx"]    =  { layout = awful.layout.suit.tile.bottom , mwfact = 0.75,
                exclusive = true, solitary = true, position = 6,init = false }, 

  ["media"]  =  { layout = awful.layout.suit.floating    , exclusive = false , 
                solitary  = false, position = 8     }, 

  ["office"] =  { layout = awful.layout.suit.tile        , position  = 9 }
}
--}}}

--{{{ application matching rules
shifty.config.apps = {
  { match   = { "Navigator","Vimperator","Gran Paradiso" }, 
    tag     = "web"                                         },

  { match   = { "Shredder.*" },
    tag     = "mail"                                        },

  { match   = { "pcmanfm" },
    slave   = true                                          },

  { match   = { "OpenOffice.*" },
    tag     = "office"                                      },

  { match   = { "pcb","gschem" },
    tag     = "dz",
    slave   = false                                         },

  { match   = { "PCB_Log","Status","Page Manager" }, 
    tag     = "dz", 
    slave   = true                                          },

  { match   = { "acroread","Apvlv","Evince" }, 
    tag     = "ds"                                          },

  { match   = { "VBox.*","VirtualBox.*" },
    tag     = "vbx"                                         },

  { match   = { "Mplayer.*","Mirage","gimp","gtkpod","Ufraw","easytag"},
    tag     = "media",
    nopopup = true                                          },

  { match   = { "MPlayer", "Gnuplot", "galculator" }, 
    float   = true                                          },

  { match   = { "urxvt","vim" },
    honorsizehints = false, 
    slave   = true                                          },

  { match = { "" }, 
    buttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ settings.modkey }, 1, awful.mouse.client.move),
        awful.button({ settings.modkey }, 3, awful.mouse.client.resize))
                                                            }
}
--}}}

shifty.config.defaults={ layout  = awful.layout.suit.tile.bottom, ncol = 1, floatBars=true }
    --[[run     = function(tag)
                naughty.notify({
                  text = markup.fg(beautiful.fg_normal, markup.font("monospace",
                    markup.fg( beautiful.fg_sb_hi,
                      "Shifty Created: "..(awful.tag.getproperty(tag,"position")
                                or shifty.tag2index(mouse.screen,tag)).." : "..
                                (tag.name or "foo"))))
                              }) end, ]]--

-- }}}
-- Actually load theme
beautiful.init(settings.theme_path)
shifty.modkey = settings.modkey
-- }}}

-- {{{ tag run or raise... needed?
function tagSearch(name)
  for s = 1, screen.count() do
    t = shifty.name2tag(name,s)
    if t ~= nil then
      awful.tag.viewonly(t)
      -- view_only(t)
      awful.screen.focus(awful.util.cycle(screen.count(),s+mouse.screen))
      return true
    end
  end
  return false
end
-- }}}

--[[ history_max = 10
history = {}
-- create history table for each screen
for s = 1,screen.count() do
    history[s] = {top=1,ptr=1,tags={}}
end

-- restores history
function his_restore(direction)
    local scr = mouse.screen
    local hisIdx = awful.util.cycle(math.min(history[scr].top+direction,history_max),history[scr].ptr+direction)

    if hisIdx > history[scr].top then return end

    -- deselect all currently viewed tags
    awful.tag.viewnone(scr)
    -- reselect everything at hisIdx in the history[s] tag table
    for k,t in pairs(history[scr].tags[hisIdx]) do
        t.selected = true
    end

    -- set history pointer to current location
    history[scr].ptr = hisIdx
end 

-- updates history table
function his_update(scr)
    local seltags = {}
    local hisIdx = awful.util.cycle(
                math.min( history[scr].top+1, history_max), hisptr+1 )

    -- find all selected tags and push into seltags table
    for k,t in pairs(screen[scr]:tags()) do
        if t.selected then 
            seltags[k] = t
        end
    end
    if hisIdx > history[scr].ptr then
        history[scr].top = awful.util.cycle(history_max, history[scr].top+1)
    end
    -- assign seltags to location in history table
    history[scr].tags[hisIdx] = seltags
    history[scr].ptr=hisIdx
end

-- toggles .selected field of tag
function view_toggle(t)
    if t then
        his_update(t.screen)
        if t.screen then
            t.selected = not t.selected
        end
    else
        print("rcerror:  view_toggle :no tag sent in")
        return
    end
end

function view_only(t)
    if t then
        his_update(t.screen)
        awful.tag.viewnone()
        t.selected = true
    else
        print("rcerror: view_only : no tag sent ")
        return
    end
end --]]--

--[[ function history_pop(direction,merge)
    local t_index = awful.util.cycle(history_top,hisptr+direction)
    local t = {}
    if direction and (t_index <= history_top) then
        t[1] = history[t_index]
        if t ~= nil then 
            return t
        else
            return awful.tag.selectedlist()
        end
    end
end --]]--

--{{{ widgets
-- Create a systray
mysystray = widget({ type = "systray" })

--{{{ spacers
widget_spacer_l = widget({type="textbox", align = "left" })
widget_spacer_l.text = " "
widget_spacer_r  = widget({type="textbox", align = "right" })
widget_spacer_r.width = 5
widget_spacer_r.text = " "
--}}}

-- MOCP Widget
mocpwidget = widget({type="textbox",align = "right"})
mocp.setwidget(mocpwidget)

-- {{{ -- DATE widget
datewidget = widget({type="textbox", align = 'right' })

datewidget.mouse_enter = function() calendar.add_calendar() end
datewidget.mouse_leave = function() calendar.remove_calendar() end
datewidget:buttons({
  button({ }, 4, function() calendar.add_calendar(-1) end),
  button({ }, 5, function() calendar.add_calendar(1) end)
})
wicked.register(datewidget, wicked.widgets.date, markup.fg(beautiful.fg_sb_hi, '%k:%M'))
-- }}}

-- {{{ -- CPU widget
cpuwidget = widget({type="textbox", align = 'right' })
cpuwidget.width = 40
wicked.register(cpuwidget, wicked.widgets.cpu, 
                'cpu:' .. markup.fg(beautiful.fg_sb_hi, '$1'))
-- }}}

-- {{{ -- MEMORY widgets
memwidget = widget({type="textbox", align = 'right' })
memwidget.width = 45

wicked.register(memwidget, wicked.widgets.mem, 
                'mem:' ..  markup.fg(beautiful.fg_sb_hi,'$1'))
-- }}}

-- {{{ -- FSWIDGET
fswidget = widget({ type = "textbox", align = "right" })
fs.init( fswidget,
        { interval = 59,
          parts = {   ['sda7'] = {label = "/"},
                      ['sda5'] = {label = "d"} } }) 
-- }}}

-- {{{ -- BATTERY

batterywidget = widget({ type = "textbox", align = "right" })
battery.init(batterywidget)
awful.hooks.timer.register(50, battery.info,true)

-- }}}

-- {{{ -- VOLUME
pb_volume = volume.init()
--[[pb_volume:buttons(awful.util.table.join(
    awful.button({ }, 1, function () volume.vol("up","5") end),
    awful.button({ }, 4, function () volume.vol("up","1") end),
    awful.button({ }, 3, function () volume.vol("down","5") end),
    awful.button({ }, 5, function () volume.vol("down","1") end),
    awful.button({ }, 2, function () volume.vol() end)
))--]]--
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({                 }, 1, awful.tag.viewonly       ),
  awful.button({ settings.modkey }, 1, awful.client.movetotag   ),
  awful.button({                 }, 3, 
    function (tag) tag.selected = not tag.selected end          ),
  awful.button({ settings.modkey }, 3, awful.client.toggletag   ),
  awful.button({                 }, 4, awful.tag.viewnext       ),
  awful.button({                 }, 5, awful.tag.viewprev       ))

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
    client.focus = c
    c:raise()
  end),

  awful.button({ }, 3, function ()
    if instance then instance:hide(); instance = nil
    else instance = awful.menu.clients({ width=250 }) end
  end),

  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),

  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))

widget_table1 = {
    widget_spacer_r, datewidget, widget_spacer_r, 
    s == 1 and mysystray or nil    , widget_spacer_r           , 
    s == 1 and pb_volume or nil    , widget_spacer_r           , 
    s == 1 and mocpwidget or nil   , widget_spacer_r           , 
    s == 1 and cpuwidget or nil    , s == 1 and widget_spacer_r, 
    s == 1 and memwidget or nil    , s == 1 and widget_spacer_r, 
    s == 1 and batterywidget or nil, s == 1 and widget_spacer_r, 
    s == 1 and fswidget or nil     , s == 1 and widget_spacer_r, 

    ["layout"] = awful.widget.layout.horizontal.rightleft
}

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  -- mypromptbox[s] = awful.widget.prompt({ align = "left" })
  mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.leftright })

  -- imagebox widget which will contains an icon indicating which layout
  -- mylayoutbox[s] = awful.widget.layoutbox(s, { align = "left" })
  mylayoutbox[s] = awful.widget.layoutbox(s)

  mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({}, 2, function () awful.layout.inc(settings.layouts, 1 ) end),
        awful.button({}, 3, function () awful.layout.inc(settings.layouts, -1) end),
        awful.button({}, 4, function () awful.layout.inc(settings.layouts, 1 ) end),
        awful.button({}, 5, function () awful.layout.inc(settings.layouts, -1) end))
        )

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
  end, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })
  -- Add widgets to the wibox - order matters
  mywibox[s].widgets = { 
      { 
          widget_spacer_l, mylayoutbox[s], widget_spacer_l,
          mytaglist[s],
          mypromptbox[s], widget_spacer_l,
          ["layout"] = awful.widget.layout.horizontal.leftright
      },
      {
          widget_spacer_r, datewidget, widget_spacer_r, 
          s == 1 and mysystray or nil    , s == 1 and widget_spacer_r, 
          s == 1 and pb_volume or nil    , s == 1 and widget_spacer_r, 
          s == 1 and mocpwidget or nil   , s == 1 and widget_spacer_r, 
          s == 1 and cpuwidget or nil    , s == 1 and widget_spacer_r, 
          s == 1 and memwidget or nil    , s == 1 and widget_spacer_r, 
          s == 1 and batterywidget or nil, s == 1 and widget_spacer_r, 
          s == 1 and fswidget or nil     , s == 1 and widget_spacer_r, 

          ["layout"] = awful.widget.layout.horizontal.rightleft
      },

      -- s == 1 and widget_table1,
      {
          mytasklist[s], widget_spacer_r,
          ["layout"]= awful.widget.layout.horizontal.flex
      },
      ["layout"]= awful.widget.layout.horizontal.leftright
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- awful.key({ settings.modkey}, "z", his_restore(-1)),
    -- awful.key({ settings.modkey, "Shift" }, "z", his_restore(1)),
    --[[  awful.key({ settings.modkey }, "z", function() 
    local t = history_pop(1,false)
    if t then 
    print("in kb, t is") --,t:len())
    print("tags known")
    for k,v in pairs(screen[mouse.screen]:tags()) do
    print(k,v)
    end
    print("history tags")
    for k,v in pairs(history) do
    print(k,v[1])
    end
    print("popped tag")
    for k,v in pairs(t[1]) do
    print(k,v)
    end
    print("shiftys index=", shifty.tag2index(mouse.screen,t[1]))
    awful.tag.viewidx(shifty.tag2index(mouse.screen,t[1]),mouse.screen)
    -- awful.tag.viewmore(t,mouse.screen) 
    else
    print("in kb, t is not")
    end

    end),--]]--
    -- awful.key({ settings.modkey, "Shift" }, "z", awful.tag.view(history_pop(1,false))),  -- move to next tag
    awful.key({ settings.modkey }, "space", awful.tag.viewnext),  -- move to next tag
    awful.key({ settings.modkey, "Shift" }, "space", awful.tag.viewprev), -- move to previous tag

    awful.key({ settings.modkey,           }, "j",
    function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey,           }, "k",
    function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),

    -- shiftycentric
    awful.key({ settings.modkey            }, "Escape",  awful.tag.history.restore), -- move to prev tag by history
    awful.key({ settings.modkey, "Shift"   }, "n",       shifty.send_prev),          -- move client to prev tag
    awful.key({ settings.modkey            }, "n",       shifty.send_next),          -- move client to next tag
    awful.key({ settings.modkey, "Control" }, "n",       function ()                 -- move a tag to next screen
        local ts = awful.tag.selected()
        awful.tag.history.restore(ts.screen)
        shifty.set(ts,{ screen = awful.util.cycle(screen.count(), ts.screen +1)})
        awful.tag.viewonly(ts)
        mouse.screen = ts.screen
    end),
    awful.key({ settings.modkey, "Shift"   }, "r",       shifty.rename),             -- rename a tag
    awful.key({ settings.modkey            }, "d",       shifty.del),                -- delete a tag
    awful.key({ settings.modkey            }, "a",       shifty.add),                -- creat a new tag
    awful.key({ settings.modkey, "Shift"   }, "a",       function() shifty.add({ nopopup = true }) end), -- nopopup new tag

    -- Layout manipulation
    awful.key({ settings.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ settings.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ settings.modkey }, "s", function () awful.screen.focus(1) end),
    awful.key({ settings.modkey, "Shift" }, "s", awful.client.movetoscreen),   -- switch client to other screen
    awful.key({ settings.modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ settings.modkey,           }, "Tab",
    function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end),

    -- {{{ - APPLICATIONS
    awful.key({ settings.modkey }, "Return", function () awful.util.spawn(settings.apps.terminal,false) end),

    -- run or raise type behavior but with benefits of shifty
    awful.key({ settings.modkey},"w", function () if not tagSearch("web") then awful.util.spawn(settings.apps.browser) end end),
    awful.key({ settings.modkey },"m", function () if not tagSearch("mail") then awful.util.spawn(settings.apps.mail) end end),
    awful.key({ settings.modkey, "Mod1", "Shift" },"v", function () if not tagSearch("vbx") then awful.util.spawn('VBoxSDL -vm xp2') end end),
    awful.key({ settings.modkey },"g", function () if not tagSearch("dz") then awful.util.spawn('gschem') end end),
    awful.key({ settings.modkey },"p", function () if not tagSearch("dz") then awful.util.spawn('pcb') end end),

    awful.key({ settings.modkey, "Mod1" },"f", function () awful.util.spawn(settings.apps.filemgr) end),
    awful.key({ settings.modkey, "Mod1" },"c", function () awful.util.spawn("galculator",false) end),
    awful.key({ settings.modkey, "Mod1", "Shift" } ,"g", function () awful.util.spawn('gimp') end),
    awful.key({ settings.modkey, "Mod1" },"o", function () awful.util.spawn('/home/perry/.bin/octave-start.sh',false) end),
    awful.key({ settings.modkey, "Mod1" },"v", function () awful.util.spawn('/home/perry/.bin/vim-start.sh',false) end),
    awful.key({ settings.modkey, "Mod1" },"i", function () awful.util.spawn('gtkpod',false) end),
    -- }}}

    -- {{{ - MEDIA
    -- music player
    awful.key({ settings.modkey, "Mod1" }, "p", function() mocp.play("PLAY") end),
    awful.key({},"XF86AudioPlay",               function() mocp.play("PLAY") end),
    awful.key({ settings.modkey },"Down",       function() mocp.play("FWD") end ),
    awful.key({ settings.modkey },"Up",         function() mocp.play("REV") end),
    awful.key({},"XF86AudioPrev",               function() mocp.play("REV") end),
    awful.key({},"XF86AudioNext",               function() mocp.play("FWD") end ),
    awful.key({},"XF86AudioStop",               function() mocp.play("STOP") end),

    awful.key({},"XF86AudioRaiseVolume", function() volume.vol("up","5") end),
    awful.key({},"XF86AudioLowerVolume", function() volume.vol("down","5") end),
    awful.key({ settings.modkey },"XF86AudioRaiseVolume",function() volume.vol("up","2")end),
    awful.key({ settings.modkey },"XF86AudioLowerVolume", function() volume.vol("down","2")end),
    awful.key({},"XF86AudioMute", function() volume.vol() end),
    -- }}} 
    
    awful.key({ settings.modkey, "Control" }, "r", awesome.restart),
    awful.key({ settings.modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ settings.modkey,           }, "l",     function () awful.tag.incmwfact( 0.03)    end),
    awful.key({ settings.modkey,           }, "h",     function () awful.tag.incmwfact(-0.03)    end),
    awful.key({ settings.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ settings.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ settings.modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ settings.modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ settings.modkey, "Mod1"    }, "l", function () awful.layout.inc(settings.layouts,  1) end),
    awful.key({ settings.modkey, "Mod1", "Shift"   }, "l", function () awful.layout.inc(settings.layouts, -1) end),

    -- Prompt
    awful.key({ settings.modkey },            "F1",     function () mypromptbox[mouse.screen]:run() end),

    --[[ awful.key({ settings.modkey }, "x",
    function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
    end) ]]--

    -- {{{ - POWER
    awful.key({ settings.modkey, "Mod1" },"h", function () awful.util.spawn('sudo pm-hibernate',false) end),
    awful.key({ settings.modkey, "Mod1" },"s", function () 
        awful.util.spawn('slock',false)
        os.execute('sudo pm-suspend')
    end),
    awful.key({ settings.modkey, "Mod1" },"r", function () awful.util.spawn('sudo reboot',false) end)
    -- }}} 
    
    )

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ settings.modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ settings.modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ settings.modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ settings.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ settings.modkey,           }, "o",      awful.client.movetoscreen                        ),
    -- awful.key({ settings.modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ settings.modkey }, "t", awful.client.togglemarked),
    awful.key({ settings.modkey, "Control"}, "m",
    function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
    )

shifty.config.clientkeys = clientkeys

-- Compute the maximum number of digit we need, limited to 9
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ settings.modkey }, i,
    function () awful.tag.viewonly(shifty.getpos(i)) end),
    -- function () view_only(shifty.getpos(i)) end),
    -- local screen = mouse.screen
    -- if tags[screen][i] then
    -- awful.tag.viewonly(tags[screen][i])
    -- end
    -- end),
    awful.key({ settings.modkey, "Control" }, i,
    function ()t = shifty.getpos(i); t.selected = not t.selected end),
    -- function () t = shifty.getpos(i); view_toggle(t) end),
    -- local screen = mouse.screen
    -- if tags[screen][i] then
    -- tags[screen][i].selected = not tags[screen][i].selected
    -- end
    -- end),
    awful.key({ settings.modkey, "Shift" }, i,
    function ()
        if client.focus then 
            local c = client.focus
            slave = not ( client.focus == awful.client.getmaster(mouse.screen))
            t = shifty.getpos(i)
            awful.client.movetotag(t)
            awful.tag.viewonly(t)
            -- view_only(t)
            if slave then awful.client.setslave(c) end
        end 
        -- if client.focus and tags[client.focus.screen][i] then
        -- awful.client.movetotag(tags[client.focus.screen][i])
        -- end
    end)
    )
end
--[[  awful.key({ settings.modkey, "Control", "Shift" }, i,
function ()
if client.focus and tags[client.focus.screen][i] then
awful.client.toggletag(tags[client.focus.screen][i])
end
end),
awful.key({ settings.modkey, "Shift" }, "F" .. i,
function ()
local screen = mouse.screen
if tags[screen][i] then
for k, c in pairs(awful.client.getmarked()) do
awful.client.movetotag(tags[screen][i], c)
end
end
end))
end ]]--

-- Set keys
root.keys(globalkeys)
-- }}}

shifty.taglist = mytaglist
shifty.init()

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
  if not awful.client.ismarked(c) then
    c.border_color = beautiful.border_focus
  end
  if settings.opacity[c.class] then 
    c.opacity = settings.opacity[c.class].focus
  else
    c.opacity = settings.opacity["default"].focus or 0.7
  end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
  if not awful.client.ismarked(c) then
    c.border_color = beautiful.border_normal
  end
  if settings.opacity[c.class] then 
    c.opacity = settings.opacity[c.class].unfocus
  else
    c.opacity = settings.opacity["default"].unfocus or 0.7
  end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
  c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
  c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
  -- Sloppy focus, but disabled for magnifier layout
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

--{{{
  -- Hook function to execute when a new client appears.
  --[[ awful.hooks.manage.register(function (c, startup)
  -- If we are not managing this application at startup,
  -- move it to the screen where the mouse is.
  -- We only do it for filtered windows (i.e. no dock, etc).
  if not startup and awful.client.focus.filter(c) then
  c.screen = mouse.screen
  end

  if use_titlebar then
  -- Add a titlebar
  awful.titlebar.add(c, { settings.modkey = settings.modkey })
  end
  -- Add mouse bindings
  c:buttons(awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ settings.modkey }, 1, awful.mouse.client.move),
  awful.button({ settings.modkey }, 3, awful.mouse.client.resize)
  ))
  -- New client may not receive focus
  -- if they're not focusable, so set border anyway.
  c.border_width = beautiful.border_width
  c.border_color = beautiful.border_normal

  -- Check if the application should be floating.
  local cls = c.class
  local inst = c.instance
  if floatapps[cls] ~= nil then
  awful.client.floating.set(c, floatapps[cls])
  elseif floatapps[inst] ~= nil then
  awful.client.floating.set(c, floatapps[inst])
  end

  -- Check application->screen/tag mappings.
  local target
  if apptags[cls] then
  target = apptags[cls]
  elseif apptags[inst] then
  target = apptags[inst]
  end
  if target then
  c.screen = target.screen
  awful.client.movetotag(tags[target.screen][target.tag], c)
  end

  -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
  client.focus = c

  -- Set key bindings
  c:keys(clientkeys)

  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- awful.client.setslave(c)

  -- Honor size hints: if you want to drop the gaps between windows, set this to false.
  -- c.size_hints_honor = false
  end)
  --]]--
  --}}}

-- Hook function to execute when switching tag selection.
awful.hooks.tags.register(function (screen, tag, view)
    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus or not client.focus:isvisible() then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)
--}}}

-- Hook called every minute
  
--[[awful.hooks.tags.register(function ( screen, tag, view )

    print("entered history hook (ptr,top)", hisptr,history_top)
    local prevIdx = awful.util.cycle(history_top,math.max((hisptr-1), 1))
    local nextIdx = awful.util.cycle(math.min(history_top+1,history_max),hisptr+1)
    local seltags = awful.tag.selectedlist()

    -- prevIdx = 1
    -- nextIdx = 2
    if not seltags then return end

          for k,v in pairs(seltags) do
              print(k,v)
          end
    if history[hisptr] == seltags then 
        return
    elseif history[prevIdx] == seltags then
        hisptr = prevIdx
    else --history[nextIdx] == seltags then
        hisptr = nextIdx
        history_top = hisptr
    end
    -- a new set of tags is pushed into the history
    history[hisptr]=seltags
end)

function history_push(t,merge)
    -- if merge then
        -- awful.tag.viewonly(t)
    -- else
        -- t.selected = ~t.selected
    -- end
        
  history[hisptr] = { t }
  hisptr=hisptr+1
end --]]--

-- vim:set filetype=lua textwidth=80 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

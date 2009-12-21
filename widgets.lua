-- widgets for my awesome
--
widgets = {}

widgets.systray = widget({ type = "systray" }) 

-- {{{ -- SPACERS
widgets.lspace       = widget({ type = "textbox", align = "left" }) 
widgets.lspace.text  = " "
widgets.lspace.width = 5
widgets.rspace       = widget({type = "textbox", align = "right" }) 
widgets.rspace.text  = " "
widgets.rspace.width = 5
--}}}

-- {{{ -- DATE 
widgets.date = widget({type="textbox", align = 'right' })
widgets.date:add_signal("mouse::enter",function() calendar.add(0) end)
widgets.date:add_signal("mouse::leave",calendar.remove) 
widgets.date:buttons(awful.util.table.join(
  awful.button({}, 1, function() print("calendar add"); calendar.add(-1) end),
  awful.button({}, 4, function() print("calendar add"); calendar.add(-1) end),
  awful.button({}, 5, function() calendar.add(1) end)
))
vicious.register(
    widgets.date,
    vicious.widgets.date,
    markup.fg(beautiful.fg_sb_hi, '%k:%M'),
    59)
-- }}}

-- {{{ -- CPU
widgets.cpu = widget({type = "textbox", align = 'right' })
widgets.cpu.width = 40
vicious.register(
    widgets.cpu,
    vicious.widgets.cpu,
    'cpu:' .. markup.fg(beautiful.fg_sb_hi, '$2')
    )
-- }}}

-- {{{ MEMORY
widgets.memory = widget({type = "textbox", align = 'right' })
widgets.memory.width = 45
vicious.register(
    widgets.memory,
    vicious.widgets.mem,
    'mem:' ..  markup.fg(beautiful.fg_sb_hi,'$1')
    )
-- }}}

--{{{ MOCP, FS and BATTERY
widgets.mocp = mocp.init(settings.theme_path.."/music/sonata.png")
widgets.mocp.width = 100 

widgets.diskspace = fs.init({interval = 59,
                                parts = { ['sda7'] = {label = "/"},
                                          ['sda5'] = {label = "d"} } }) 
widgets.battery = battery.init()

-- VOLUME :: FIXME :: my buttons are broke
widgets.volume = volume.init()
--}}}

-- {{{ -- TAGLIST
widgets.taglist = {}
widgets.taglist.buttons = awful.util.table.join(
        awful.button({                } , 1, awful.tag.viewonly    ) , 
        awful.button({ settings.modkey} , 1, awful.client.movetotag) , 
        awful.button({                } , 3, awful.tag.viewtoggle  ) , 
        awful.button({ settings.modkey} , 3, awful.client.toggletag) , 
        awful.button({                } , 4, awful.tag.viewnext    ) , 
        awful.button({                } , 5, awful.tag.viewprev    ) 
    )
--}}}

function myclientsmenu(menu,c)

    -- {{{ list of other clients
    local cls = client.get()
    local cls_t = {}
    for k, clnt in pairs(cls) do
        cls_t[#cls_t + 1] = { awful.util.escape(clnt.name) or "",
                              function ()
                                  if not clnt:isvisible() then
                                      awful.tag.viewmore(clnt:tags(), clnt.screen)
                                  end
                                  client.focus = clnt
                              end,
                              clnt.icon }
    end
    -- }}}
    
    -- {{{ list of tags can send to
    -- local tgs = screen[mouse.screen]:tags()
    tgs_m = {}
    for s = 1, screen.count() do
        skey='Screen '..s
        print("setting tags_t for s="..s)

        local tgs_t = {}
        for i, t in ipairs(screen[s]:tags()) do
            print("adding "..t.name.." to key list "..skey)
            tgs_t[i] = { awful.util.escape(t.name) or "",
                                function ()
                                    c:tags({t})
                                    c.screen = t.screen
                                end
                            }
        end

        tgs_m[s] = {skey,tgs_t}
    end

    -- }}}
    
    if not menu then
        menu = {}
    end

    menu.items = { 
        { "Close", function() c:kill() end },
        { "Stick", function (c) c.sticky=not c.sticky end},
        { "Move to tag \t>>", tgs_m },
        { "Clients \t>>", cls_t }
    }
    local m = awful.menu.new(menu)
    m:show()
    return m
end

-- {{{ -- TASKLIST
widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
      c.minimized = not c.minimized
      if c:isvisible() then
          client.focus = c
          c:raise()
      else
          awful.client.focus.history.previous()
        end
  end),

  awful.button({ }, 3, function (c)
        if instance then instance:hide(); instance = nil
        else instance = myclientsmenu({width = 250},c) end -- awful.menu.clients({ width=250 }) end
  end),

  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),

  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))

--}}}

widgets.promptbox = {}
widgets.layoutbox = {}
widgets.wibox = {}

-- {{{ -- STATUSBAR 
widget_table1 = {
    widgets.rspace   , 
    widgets.cpu      , widgets.rspace, 
    widgets.memory   , widgets.rspace, 
    widgets.battery  , widgets.rspace, 
    widgets.diskspace, widgets.rspace, 
    widgets.mocp     , widgets.rspace, 
    widgets.volume   , widgets.rspace, 
    widgets.systray  , widgets.rspace, 
    widgets.date     , widgets.rspace, 
    layout = awful.widget.layout.horizontal.rightleft
}

for s = 1, screen.count() do

    widgets.promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    widgets.layoutbox[s] = awful.widget.layoutbox(s)

    widgets.layoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function () awful.layout.inc(settings.layouts, 1 ) end),
            awful.button({}, 3, function () awful.layout.inc(settings.layouts, -1) end),
            awful.button({}, 4, function () awful.layout.inc(settings.layouts, 1 ) end),
            awful.button({}, 5, function () awful.layout.inc(settings.layouts, -1) end))
        )

    -- Create a taglist widget
    widgets.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, widgets.taglist.buttons)

    -- Create a tasklist widget
    widgets.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, widgets.tasklist.buttons)

    -- add widgets to the 'statusbar' wibox
    widgets.wibox[s] = awful.wibox({ position = "top", screen = s })
    widgets.wibox[s].widgets = { 

        -- {{{ always have a taglist, promptbox and layoutbox
        { 
            layout = awful.widget.layout.horizontal.leftright,
            widgets.lspace      , widgets.layoutbox[s], 
            widgets.lspace      , widgets.taglist[s]  , 
            widgets.promptbox[s], widgets.lspace      , 
        },
        -- }}}
        
        (s==1 and widget_table1) or 
        { 
            widgets.rspace, widgets.date, widgets.rspace,
            layout = awful.widget.layout.horizontal.rightleft
        },

        widgets.tasklist[s], widgets.rspace,
        layout = awful.widget.layout.horizontal.leftright,
        height = widgets.wibox[s].height
    }
end

-- }}}


return widgets

-- vim:set filetype=lua textwidth=120 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

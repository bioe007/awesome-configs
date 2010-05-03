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
  awful.button({}, 1, function() calendar.add(-1) end),
  awful.button({}, 4, function() calendar.add(-1) end),
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
widgets.cpu.width = 43
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

function tag_restore_defaults(t)
    local t_defaults = shifty.config.tags[t.name] or shifty.config.defaults

    for k,v in pairs(t_defaults) do
        awful.tag.setproperty(t, k, v)
    end
end

function menu_taglist(menu, t)
    -- {{{1
    if not menu then
        menu = {}
    end
    num_screens = screen.count()
    next_screen = nil
    prev_screen = nil

    menu.items = {}
    menu.items = { 
        { (t.selected and "Hide") or "Merge", function()
            t.selected = not t.selected end },
        { "Rename", function() shifty.rename(t) end },
        { "Restore", function() tag_restore_defaults(t) end },
        { "Delete", function() shifty.del(t) end },
    }

    if num_screens > 1 then
        -- {{{2 decide to show 'move next' only or also prev screen 
        next_screen = awful.util.cycle(num_screens, t.screen + 1)
        table.insert(menu.items, 2, { "Move to screen " .. next_screen, 
                function() tag_to_screen(t, next_screen) end })

        if num_screens > 2 then
            prev_screen = awful.util.cycle(num_screens, t.screen + 1)
            table.insert(menu.items, 3, { "Move to screen " .. prev_screen,
                    function() tag_to_screen(t, prev_screen) end })
        end
    end
    -- 2}}}

    local m = awful.menu.new(menu)
    m:show()
    return m
end
-- 1}}}


-- {{{ -- TAGLIST
widgets.taglist = {}
widgets.taglist.buttons = awful.util.table.join(
        awful.button({                } , 1, awful.tag.viewonly    ) , 
        awful.button({ settings.modkey} , 1, awful.client.movetotag) , 
        awful.button({                } , 2, awful.tag.viewtoggle  ) , 
        awful.button({ settings.modkey} , 3, awful.client.toggletag) , 
        awful.button({ } , 3, function(t)
            if instance then instance:hide(); instance = nil
            else instance = menu_taglist({width = 125}, t) end
        end),
        awful.button({                } , 4, awful.tag.viewnext    ) , 
        awful.button({                } , 5, awful.tag.viewprev    ) 
    )
--}}}


-- {{{1 some helper functions
function toggle_maximized(c) 
    -- {{{2
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
    c:raise()
end
-- 2}}}

function client_is_maximized(c)
    -- {{{2
    if c.maximized_horizontal and c.maximized_vertical then
        return true
    else
        return false
    end
end
-- 2}}}

function float_or_restore(c)
    -- {{{2
    if awful.client.floating.get(c) then
        awful.client.floating.set(c)
    end

end
-- 2}}}

function focus_min_or_restore(c)
    -- {{{2
    if c == client.focus then
        c.minimized = not c.minimized
        if c:isvisible() then
            client.focus = c
            c:raise()
        else
            awful.client.focus.history.previous()
        end
    else
        client.focus = c
        c:raise()
    end
end
-- 2}}}

-- 1}}}


-- {{{1 menu_clients(menu, c)
function menu_clients(menu, c)
    -- {{{2

    -- {{{3 list of other clients
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
    -- 3}}}
    
    -- {{{3 list of tags can send to
    tgs_m = {}
    for s = 1, screen.count() do
        skey='Screen '..s

        local tgs_t = {}
        for i, t in ipairs(screen[s]:tags()) do
            tgs_t[i] = { awful.util.escape(t.name) or "",
                                function ()
                                    c:tags({t})
                                    c.screen = t.screen
                                end
                            }
        end
        table.insert(tgs_t, #tgs_t + 1, { "New tag", function()
            new_tag_name = (c.instance and c.instance:gsub("%s.+$", "")) or nil
            t = shifty.add( { name = new_tag_name, screen = s })
            awful.client.movetotag(t, c)
            awful.tag.viewonly(t)
            client.focus = c
            c:raise()

        end })

        tgs_m[s] = {skey,tgs_t}
    end

    -- 3}}}
    
    if not menu then
        menu = {}
    end


    menu.items = { 
        { "Close", function() c:kill() end },
        { (client_is_maximized(c) and "Un-Maximize") or "Maximize", function()
            toggle_maximized(c) 
        end },
        { (c.minimized and "Restore") or "Minimize", function()
            c.minimized = not c.minimized
        end },
        { (c.sticky and "Un-Stick") or "Stick", function()
            c.sticky = not c.sticky
        end },
        { ((awful.client.floating.get(c) and "Tile") or "Float"), function()
            awful.client.floating.toggle(c)
        end },
        { "Move to tag >>", tgs_m },
        { "Clients     >>", cls_t }
    }
    local m = awful.menu.new(menu)
    m:show()
    return m
end
-- 2}}} 1}}}


-- {{{ -- TASKLIST
widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, focus_min_or_restore ),

  awful.button({ }, 3, function (c)
        if instance then instance:hide(); instance = nil
        else instance = menu_clients({width = 125},c) end
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
    widgets.date     , widgets.rspace, 
    widgets.cpu      , widgets.rspace, 
    widgets.memory   , widgets.rspace, 
    widgets.battery  , widgets.rspace, 
    widgets.diskspace, widgets.rspace, 
    widgets.mocp     , widgets.rspace, 
    widgets.volume   , widgets.rspace, 
    widgets.systray  , widgets.rspace, 
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
    widgets.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, widgets.taglist.buttons)

    -- Create a tasklist widget
--    widgets.tasklist[s] = awful.widget.tasklist(s, function(c)
--        local text, bg, status_image = awful.widget.tasklist.filter.currenttags(c,s)
--        return text, bg, status_image
--    end,
--    widgets.tasklist.buttons)

    -- Create a tasklist widget
    widgets.tasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, widgets.tasklist.buttons)
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

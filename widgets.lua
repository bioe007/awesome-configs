-- widgets for my awesome
--

-- Create a text scrolling function
-- w: A widget to set the .text on
-- template: A template string to substitute into
-- pattern: The substitution pattern
-- max_chars: Maximum number of characters to use
function scroller_create(w, template, pattern, max_chars)
    local max_chars = max_chars or 15
    local i_scroll = 1
    local full_text = ""
    local s = template or "scroller no template"
    local p = pattern or ""

    local function scroller(tmr)
        chop = full_text .. full_text .. full_text
        snip = string.sub(chop, i_scroll, max_chars + i_scroll - 1)
        echars = full_text:len() - (max_chars + i_scroll)
        if echars < 0 then
            snip = snip .. string.sub(chop, 1, max_chars - snip:len())
        end

        w.text = awful.util.escape(snip)
        if i_scroll <= full_text:len() then
            i_scroll = i_scroll + 1
        else
            i_scroll = 1
        end

        return snip
    end

    local function updater(w, args)
        full_text = awful.util.unescape(string.gsub(s, p, args)) .. " - "
        return scroller(nil)
    end

    return scroller, updater
end

widgets = {}

widgets.systray = widget({type = "systray"})

-- Spacers
widgets.lspace = widget({type = "textbox", align = "left"})
widgets.lspace.text = " "
widgets.lspace.width = 8
widgets.rspace = widget({type = "textbox", align = "right"})
widgets.rspace.text = " "
widgets.rspace.width = 8

widgets.date = widget({type="textbox", align = 'right'})
widgets.date:add_signal("mouse::enter", function() calendar.add(0) end)
widgets.date:add_signal("mouse::leave", calendar.remove)
widgets.date:buttons(awful.util.table.join(
    awful.button({}, 1, function() calendar.add(-1) end),
    awful.button({}, 4, function() calendar.add(-1) end),
    awful.button({}, 5, function() calendar.add(1) end)))

vicious.register(widgets.date,
                 vicious.widgets.date,
                 markup.fg(beautiful.fg_sb_hi, '%k:%M'),
                 59)

widgets.cpu = widget({type = "textbox", align = 'right'})
widgets.cpu.width = 60
vicious.register(widgets.cpu,
                 vicious.widgets.cpu,
                 function (w, args)
                     return 'cpu:' ..
                            markup.fg(beautiful.fg_sb_hi,
                                      string.format("%2.0d", args[2]))
                     end)

widgets.memory = widget({type = "textbox", align = 'right'})
widgets.memory.width = 60
vicious.register(widgets.memory,
                 vicious.widgets.mem,
                 function (w, args)
                     return 'mem:' ..
                            markup.fg(beautiful.fg_sb_hi,
                                      string.format("%3.0d", args[1]))
                     end)

widgets.diskspace = fs.init({interval = 59,
                             parts = {
                                 ['sda7'] = {label = "/"},
                                 ['sda5'] = {label = "d"}
                             }})

widgets.battery = widget({type = "textbox", align = 'right'})
vicious.register(widgets.battery,
                 vicious.widgets.bat,
                 markup.fg(beautiful.fg_sb_hi, '$2$1'),
                 61,
                 'BAT0')

widgets.mpd = widget({type = "textbox", align = 'right'})
mpd_scroller, mpd_update = scroller_create(widgets.mpd,
                                           settings.mpd.format,
                                           settings.mpd.pattern,
                                           settings.mpd.length)
vicious.register(widgets.mpd,
                 vicious.widgets.mpd,
                 mpd_update,
                 17,
                 passwords.mpd)
vicious.force({widgets.mpdwidget})
mpdtimer = timer{timeout = 0.75}
mpdtimer:add_signal("timeout", mpd_scroller)
mpdtimer:start()

widgets.net = widget({type = "textbox", align = 'right'})
vicious.register(widgets.net,
                 vicious.widgets.net,
                 function(w, a)
                     local net_in = a['{eth0 down_kb}'] + a['{wlan0 down_kb}']
                     local net_out = a['{eth0 up_kb}'] + a['{wlan0 up_kb}']
                     net_in = string.format("%2.0f", net_in)
                     net_out = string.format("%2.0f", net_out)
                     return 'net:' .. markup.fg(beautiful.fg_sb_hi, net_in) ..
                            '/' .. markup.fg(beautiful.fg_sb_hi, net_out)
                 end,
                 1)

mpd_scroller, mpd_update = scroller_create(widgets.mpd,
                                           settings.mpd.format,
                                           settings.mpd.pattern,
                                           settings.mpd.length)
vicious.register(widgets.mpd,
                 vicious.widgets.mpd,
                 mpd_update,
                 17,
                 passwords.mpd)
widgets.volume = volume.init()

function tag_restore_defaults(t)
    local t_defaults = shifty.config.tags[t.name] or shifty.config.defaults

    for k, v in pairs(t_defaults) do
        awful.tag.setproperty(t, k, v)
    end
end

function menu_taglist(menu, t)
    if not menu then
        menu = {}
    end
    num_screens = screen.count()
    next_screen = nil
    prev_screen = nil

    menu.items = {}
    menu.items = {
        {(t.selected and "Hide") or "Merge", function()
            t.selected = not t.selected end},
        {"Rename", function() shifty.rename(t) end},
        {"Restore", function() tag_restore_defaults(t) end},
        {"Delete", function() shifty.del(t) end},
    }

    if num_screens > 1 then
        -- decide to show 'move next' only or also prev screen
        next_screen = awful.util.cycle(num_screens, t.screen + 1)
        table.insert(menu.items, 2, {"Move to screen " .. next_screen,
                function() tag_to_screen(t, next_screen) end})

        if num_screens > 2 then
            prev_screen = awful.util.cycle(num_screens, t.screen + 1)
            table.insert(menu.items, 3, {"Move to screen " .. prev_screen,
                    function() tag_to_screen(t, prev_screen) end})
        end
    end

    local m = awful.menu.new(menu)
    m:show()
    return m
end

widgets.taglist = {}
widgets.taglist.buttons = awful.util.table.join(
        awful.button({}, 1, awful.tag.viewonly),
        awful.button({settings.modkey}, 1, awful.client.movetotag),
        awful.button({}, 2, awful.tag.viewtoggle),
        awful.button({settings.modkey}, 3, awful.client.toggletag),
        awful.button({}, 3, function(t)
            if instance then instance:hide(); instance = nil
            else instance = menu_taglist({width = 165}, t) end
        end),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    )

function toggle_maximized(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
end

function client_is_maximized(c)
    if c.maximized_horizontal and c.maximized_vertical then
        return true
    else
        return false
    end
end

function float_or_restore(c)
    if awful.client.floating.get(c) then
        awful.client.floating.set(c)
    end
end

function focus_min_or_restore(c)
    if c == client.focus then
        c.minimized = true
    else
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
    end
end

function menu_clients(menu, c)
    -- list of other clients
    local cls = client.get()
    local cls_t = {}
    for k, clnt in pairs(cls) do
        cls_t[#cls_t + 1] = {
            awful.util.escape(clnt.name) or "",
            function()
                if not clnt:isvisible() then
                    awful.tag.viewmore(clnt:tags(), clnt.screen)
                end
                client.focus = clnt
            end,
            clnt.icon}
    end

    -- list of tags can send to
    tgs_m = {}
    for s = 1, screen.count() do
        skey = 'Screen '..s

        local tgs_t = {}
        for i, t in ipairs(screen[s]:tags()) do
            tgs_t[i] = {awful.util.escape(t.name) or "",
                                function()
                                    c:tags({t})
                                    c.screen = t.screen
                                end
                            }
        end
        table.insert(tgs_t, #tgs_t + 1, {"New tag", function()
            new_tag_name = (c.instance and c.instance:gsub("%s.+$", "")) or nil
            t = shifty.add({name = new_tag_name, screen = s})
            awful.client.movetotag(t, c)
            awful.tag.viewonly(t)
            client.focus = c
            c:raise()

        end})

        tgs_m[s] = {skey, tgs_t}
    end

    if not menu then
        menu = {}
    end


    menu.items = {
        {"Close", function() c:kill() end},
        {(client_is_maximized(c) and "Un-Maximize") or "Maximize", function()
            toggle_maximized(c)
        end},
        {(c.minimized and "Restore") or "Minimize", function()
            c.minimized = not c.minimized
        end},
        {(c.sticky and "Un-Stick") or "Stick", function()
            c.sticky = not c.sticky
        end},
        {(c.ontop and "Offtop") or "Ontop", function()
            c.ontop = not c.ontop
            if c.ontop then c:raise() end
        end},
        {((awful.client.floating.get(c) and "Tile") or "Float"), function()
            float_toggle(c)
        end},
        {"Move to tag >>", tgs_m},
        {"Clients     >>", cls_t}
    }
    local m = awful.menu.new(menu)
    m:show()
    return m
end

-- Tasklist
widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
    awful.button({}, 1, focus_min_or_restore),
    awful.button({}, 3, function(c)
        if instance then instance:hide(); instance = nil
        else instance = menu_clients({width = 165}, c) end
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

widgets.promptbox = {}
widgets.layoutbox = {}
widgets.wibox = {}

widget_table1 = {
    widgets.rspace,
    widgets.date, widgets.rspace,
    widgets.systray, widgets.rspace,
    widgets.volume, widgets.rspace,
    widgets.mpd, widgets.rspace,
    widgets.cpu, widgets.rspace,
    widgets.memory, widgets.rspace,
    widgets.battery, widgets.rspace,
    widgets.net, widgets.rspace,
    widgets.diskspace, widgets.rspace,
    layout = awful.widget.layout.horizontal.rightleft}

for s = 1, screen.count() do
    widgets.promptbox[s] = awful.widget.prompt(
                    {layout = awful.widget.layout.horizontal.leftright})
    widgets.layoutbox[s] = awful.widget.layoutbox(s)
    widgets.layoutbox[s]:buttons(awful.util.table.join(
        awful.button({},
                     1,
                     function() awful.layout.inc(settings.layouts, 1) end),
        awful.button({},
                     3,
                     function() awful.layout.inc(settings.layouts, -1) end),
        awful.button({},
                     4,
                     function() awful.layout.inc(settings.layouts, 1) end),
        awful.button({},
                     5,
                     function() awful.layout.inc(settings.layouts, -1) end))
        )

    widgets.taglist[s] = awful.widget.taglist(s,
                                              awful.widget.taglist.label.all,
                                              widgets.taglist.buttons)

    widgets.tasklist[s] = awful.widget.tasklist(
        function(c)
            return awful.widget.tasklist.label.currenttags(c, s)
        end,
        widgets.tasklist.buttons)

    widgets.wibox[s] = awful.wibox({position = "top", screen = s})
    widgets.wibox[s].widgets = {
        {
            layout = awful.widget.layout.horizontal.leftright,
            widgets.lspace, widgets.layoutbox[s],
            widgets.lspace, widgets.taglist[s],
            widgets.promptbox[s], widgets.lspace,
        },
        (s==1 and widget_table1) or
        {
            widgets.rspace, widgets.date, widgets.rspace,
            layout = awful.widget.layout.horizontal.leftright
        },
        widgets.tasklist[s], widgets.rspace,
        layout = awful.widget.layout.horizontal.leftright,
        height = widgets.wibox[s].height
    }
end

return widgets

-- {{{global keys
globalkeys = awful.util.table.join(
    awful.key({settings.modkey}, "space", awful.tag.viewnext),
    awful.key({settings.modkey, "Control"}, "space", workspace_next),
    awful.key({settings.modkey, "Shift"}, "space", awful.tag.viewprev),
    awful.key({settings.modkey, "Control", "Shift"}, "space", workspace_prev),
    awful.key({settings.modkey}, "j",
        function() awful.client.focus.byidx(1) end),
    awful.key({settings.modkey}, "k",
        function() awful.client.focus.byidx(-1) end),
    awful.key({settings.modkey}, "e", revelation.revelation),

    -- {{{ shiftycentric
    awful.key({settings.modkey}, "Escape", awful.tag.history.restore),
    awful.key({settings.modkey, "Shift"}, "n", shifty.send_prev),
    -- move client to next tag
    awful.key({settings.modkey}, "n", shifty.send_next),
    -- move a tag to next screen
    awful.key({settings.modkey, "Control"}, "n", tag_to_screen),
    awful.key({settings.modkey, "Shift"}, "r", shifty.rename), -- rename a tag
    awful.key({settings.modkey}, "d", shifty.del),             -- delete a tag
    awful.key({settings.modkey, "Shift"}, "a", shifty.add),    -- new tag
    --}}}

    -- {{{ Layout manipulation
    awful.key({settings.modkey, "Shift"}, "j",
        function() awful.client.swap.byidx(1) end),
    awful.key({settings.modkey, "Shift"}, "k",
        function() awful.client.swap.byidx(-1) end),
    awful.key({settings.modkey}, "s",
        function() awful.screen.focus_relative(1) end),
    -- switch client to other screen
    awful.key({settings.modkey, "Shift"}, "s", awful.client.movetoscreen),
    awful.key({settings.modkey,}, "u", awful.client.urgent.jumpto),
    awful.key({settings.modkey,}, "Tab", function()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
            end),
    --}}}

    -- {{{ Applications
    awful.key({settings.modkey}, "Return",
        function() awful.util.spawn(settings.apps.terminal, false) end),

    -- run or raise type behavior but with benefits of shifty
    awful.key({settings.modkey}, "w", function() if not tagSearch("web") then
        awful.util.spawn(settings.apps.browser) end end),
    awful.key({settings.modkey}, "m", function() if not tagSearch("mail") then
        awful.util.spawn(settings.apps.mail) end end),
    awful.key({settings.modkey, "Mod1", "Shift"}, "v", function()
        if not tagSearch("vbx") then
            awful.util.spawn('VBoxSDL -vm xp2')
        end
    end),
    awful.key({settings.modkey}, "g", function()
        if not tagSearch("dz") then awful.util.spawn('gschem') end end),
    awful.key({settings.modkey}, "p", function()
        if not tagSearch("dz") then awful.util.spawn('pcb') end end),

    awful.key({settings.modkey, "Mod1"}, "f",
        function() awful.util.spawn(settings.apps.filemgr) end),
    awful.key({settings.modkey, "Mod1"}, "c",
        function() awful.util.spawn("galculator", false) end),
    awful.key({settings.modkey, "Mod1", "Shift"}, "g",
        function() awful.util.spawn('gimp') end),
    awful.key({settings.modkey, "Mod1"}, "v",
        function() awful.util.spawn(settings.editor, false) end),
    awful.key({settings.modkey, "Mod1"}, "i",
        function() awful.util.spawn('gtkpod', false) end),
    --}}}

    -- {{{ Media
    -- music player
    awful.key({settings.modkey, "Mod1"}, "p", function() player("pp") end),
    awful.key({}, "XF86AudioPlay", function() player("pp") end),
    awful.key({settings.modkey}, "Down", function() player("next") end ),
    awful.key({}, "XF86AudioNext", function() player("next") end ),
    awful.key({settings.modkey}, "Up", function() player("prev") end),
    awful.key({}, "XF86AudioPrev", function() player("prev") end),
    awful.key({}, "XF86AudioStop", function() player("stop") end),

    awful.key({}, "XF86AudioRaiseVolume", function() volume.vol("up", "5") end),
    awful.key({}, "XF86AudioLowerVolume",
        function() volume.vol("down", "5") end),
    awful.key({settings.modkey}, "XF86AudioRaiseVolume",
        function() volume.vol("up", "2")end),
    awful.key({settings.modkey}, "XF86AudioLowerVolume",
        function() volume.vol("down", "2")end),
    awful.key({}, "XF86AudioMute", function() volume.vol() end),
    --}}}

    -- {{{WM
    awful.key({settings.modkey, "Control"}, "r", awesome.restart),
    awful.key({settings.modkey, "Shift"}, "q", awesome.quit),

    awful.key({settings.modkey,}, "l",
        function() awful.tag.incmwfact(0.03) end),
    awful.key({settings.modkey,}, "h",
        function() awful.tag.incmwfact(-0.03) end),
    awful.key({settings.modkey,}, "q",
        function(c) awful.client.incwfact(0.03, c) end),
    awful.key({settings.modkey,}, "a",
        function(c) awful.client.incwfact(-0.03, c) end),
    awful.key({settings.modkey, "Shift"}, "h",
        function() awful.tag.incnmaster(1) end),
    awful.key({settings.modkey, "Shift"}, "l",
        function() awful.tag.incnmaster(-1) end),
    awful.key({settings.modkey, "Control"}, "h",
        function() awful.tag.incncol(1) end),
    awful.key({settings.modkey, "Control"}, "l",
        function() awful.tag.incncol(-1) end),
    awful.key({settings.modkey, "Mod1"}, "l",
        function() awful.layout.inc(settings.layouts, 1) end),
    awful.key({settings.modkey, "Mod1", "Shift"}, "l",
        function() awful.layout.inc(settings.layouts, -1) end),

    -- Prompt
    awful.key({settings.modkey}, "F1",
        function() widgets.promptbox[mouse.screen]:run() end),
    --}}}

    -- {{{- POWER
    awful.key({settings.modkey, "Mod1"}, "h",
        function() awful.util.spawn('sudo pm-hibernate', false) end),
    awful.key({settings.modkey, "Mod1"}, "s", function()
        awful.util.spawn('slock', false)
        os.execute('sudo pm-suspend')
    end),
    awful.key({settings.modkey, "Mod1"}, "r",
        function() awful.util.spawn('sudo reboot', false) end),
    --}}}

    awful.key({settings.modkey}, "F4",
        function() awful.util.spawn('/home/perry/.bin/stupid --soyo') end),
    awful.key({settings.modkey}, "F5",
        function() awful.util.spawn('/home/perry/.bin/stupid --sync') end),
    awful.key({settings.modkey}, "F6",
        function() awful.util.spawn('/home/perry/.bin/stupid --off') end)
    )
    --}}}

-- Compute the maximum number of digit we need, limited to 9
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({settings.modkey}, i, function()
        awful.tag.viewonly(shifty.getpos(i)) end),
    awful.key({settings.modkey, "Control"}, i, function()
        this_screen = awful.tag.selected().screen
        t = shifty.getpos(i, this_screen)
        t.selected = not t.selected
    end),
    awful.key({settings.modkey, "Shift"}, i, function()
        if client.focus then
            local c = client.focus
            slave = not (client.focus == awful.client.getmaster(mouse.screen))
            t = shifty.getpos(i)
            awful.client.movetotag(t, c)
            awful.tag.viewonly(t)
            if slave then awful.client.setslave(c) end
        end
    end)
    )
end

return globalkeys
-- vim:set fdm=marker: --

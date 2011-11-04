--! @file   keys.lua
--
-- @brief
--
-- @author  Perry Hargrave
-- @date    2011-10-31
--

-- Key bindings
globalkeys = awful.util.table.join(
    awful.key({modkey, "Shift"}, "space", awful.tag.viewprev),
    awful.key({modkey,}, "space", awful.tag.viewnext),
    awful.key({modkey,}, "Escape", awful.tag.history.restore),

    awful.key({modkey,}, "j",
        function()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({modkey,}, "k",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({modkey, "Shift"}, "j",
              function() awful.client.swap.byidx(1) end),
    awful.key({modkey, "Shift"}, "k",
              function() awful.client.swap.byidx(-1) end),
    awful.key({modkey}, "s",
              function()
                  awful.screen.focus_relative(1)
                  local mc = mouse.coords()
                  mouse.coords({x=mc.x + 40, y=mc.y + 40}, true)
              end),
    awful.key({modkey,}, "u", awful.client.urgent.jumpto),
    awful.key({modkey,}, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Applications
    awful.key({modkey,}, "Return", terminal),
    awful.key({modkey, "Mod1"}, "e", editor),
    awful.key({modkey, "Mod1"}, "f", filemgr),

    -- Media controls
    awful.key({modkey}, "XF86AudioLowerVolume", function() volume(-5) end),
    awful.key({}, "XF86AudioLowerVolume", volume.lower),
    awful.key({modkey}, "XF86AudioRaiseVolume", function() volume(5) end),
    awful.key({}, "XF86AudioRaiseVolume", volume.raise),
    awful.key({}, "XF86AudioMute", volume.mute),
    awful.key({}, "XF86AudioPlay", function() music("pp") end),
    awful.key({}, "XF86AudioStop", function() music("pause") end),
    awful.key({}, "XF86AudioNext", function() music("next") end),
    awful.key({}, "XF86AudioPrev", function() music("prev") end),

    awful.key({modkey, "Control"}, "r", awesome.restart),
    awful.key({modkey, "Shift"}, "q", awesome.quit),

    awful.key({modkey,}, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({modkey,}, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({modkey, "Shift"}, "h",
              function() awful.tag.incnmaster(1) end),
    awful.key({modkey, "Shift"}, "l",
              function() awful.tag.incnmaster(-1) end),
    awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1) end),
    awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1) end),
    awful.key({modkey, "Mod1"}, "l",
              function() awful.layout.inc(shifty.config.layouts, 1) end),
    awful.key({modkey, "Shift", "Mod1"}, "l",
              function() awful.layout.inc(shifty.config.layouts, -1) end),

    awful.key({modkey, "Shift"}, "n", shifty.send_prev),
    awful.key({modkey}, "n", shifty.send_next),
    awful.key({modkey, "Shift"}, "r", shifty.rename),
    awful.key({modkey}, "d", shifty.del),
    awful.key({modkey, "Shift"}, "a", shifty.add),

    -- Revelation
    awful.key({modkey}, "e", revelation), -- all clients
    awful.key({modkey, "Shift"},          -- only terminals
              "e",
              function() revelation({class="URxvt"}) end
              ),

    -- Prompt
    awful.key({modkey},
              "F1",
              function()
                  panel.prompt:get(mouse.screen):run()
              end),
    awful.key({modkey}, "x",
              function()
                  pb = panel.prompt:get(mouse.screen)
                  awful.prompt.run({
                                    prompt="Lua code: "},
                                    panel.prompt:get(mouse.screen).widget,
                                    awful.util.eval,
                                    nil,
                                    awful.util.getdir("cache").."/history_eval"
                                    )
              end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({modkey}, i, function()
            awful.tag.viewonly(shifty.getpos(i))
        end),

        awful.key({modkey, "Control"}, i, function()
            this_screen = awful.tag.selected().screen
            t = shifty.getpos(i, this_screen)
            t.selected = not t.selected
        end),

        awful.key({modkey, "Shift"}, i, function()
            if client.focus then
                local c = client.focus
                slave = not (client.focus ==
                                awful.client.getmaster(mouse.screen))
                t = shifty.getpos(i)
                awful.client.movetotag(t,c)
                awful.tag.viewonly(t)
                if slave then awful.client.setslave(c) end
            end
        end)
    )
end
root.keys(globalkeys)

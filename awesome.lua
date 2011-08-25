require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")

-- custom modules
require("revelation")


dir = {}
dir.config = awful.util.getdir('config')
dir.cache = awful.util.getdir('cache')
dir.theme = dir.config .. "/themes/zenburn"

terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

beautiful.init(dir.theme .. "/theme.lua")

layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
}

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({1, 2, 3, 4, 5}, s, layouts[1])
end

-- Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))

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
              function() awful.screen.focus_relative(1) end),
    awful.key({modkey,}, "u", awful.client.urgent.jumpto),
    awful.key({modkey,}, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({modkey,}, "Return", function() awful.util.spawn(terminal) end),
    awful.key({modkey}, "f",
        function() awful.util.spawn('nautilus', true) end),
    awful.key({modkey, "Control"}, "r", awesome.restart),
    awful.key({modkey, "Shift"}, "q",
              function() awful.util.spawn('gnome-session-quit', false) end),

    awful.key({modkey,}, "l", function() awful.tag.incmwfact(0.05) end),
    awful.key({modkey,}, "h", function() awful.tag.incmwfact(-0.05) end),
    awful.key({modkey, "Shift"}, "h",
              function() awful.tag.incnmaster(1) end),
    awful.key({modkey, "Shift"}, "l",
              function() awful.tag.incnmaster(-1) end),
    -- awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1) end),
    -- awful.key({modkey, "Control"}, "l",
    --           function() awful.tag.incncol(-1) end),
    awful.key({modkey, "Mod1"}, "l",
              function() awful.layout.inc(layouts, 1) end),
    awful.key({modkey, "Shift", "Mod1"}, "l",
              function() awful.layout.inc(layouts, -1) end),

    awful.key({modkey, "Control"}, "n", awful.client.restore),

    -- Prompt
    awful.key({modkey}, "e", revelation),
    awful.key({modkey}, "x",
              function()
                  awful.prompt.run({prompt = "Run Lua code: "},
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({modkey, "Shift"}, "c", function(c) c:kill() end),
    awful.key({modkey, "Control"}, "space", awful.client.floating.toggle),
    awful.key({modkey, "Control"}, "Return",
              function(c) c:swap(awful.client.getmaster()) end),
    awful.key({modkey, "Shift"}, "s", awful.client.movetoscreen),
    awful.key({modkey, "Shift"}, "r", function(c) c:redraw() end),
    awful.key({modkey,}, "t", function(c) c.ontop = not c.ontop end),
    awful.key({modkey,}, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({modkey,}, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({modkey}, "#" .. i + 9,
                  function()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({modkey, "Control"}, "#" .. i + 9,
                  function()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({modkey, "Shift"}, "#" .. i + 9,
                  function()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({modkey, "Control", "Shift"}, "#" .. i + 9,
                  function()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({modkey}, 1, awful.mouse.client.move),
    awful.button({modkey}, 3, awful.mouse.client.resize))

root.keys(globalkeys)

awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            buttons = clientbuttons,
            floating = true,
            focus = true,
            keys = clientkeys,
            honor_size_hints = true,
        }
    },
    {
        rule = {
            class = 'Google-chrome'
        },
        properties = {
            floating = false,
            tag = tags[screen.count()][3],
        }
    },
    {
        rule = {
            class = 'Gvim'
        },
        properties = {
            floating = false,
        }
    },
    {
        rule = {
            class = 'Firefox'
        },
        properties = {
            floating = false,
            tag = tags[1][2],
        }
    },
    {
        rule = {
            class = 'Sonata'
        },
        properties = {
            sticky = true,
        }
    },
    {
        rule = {
            class = 'URxvt'
        },
        properties = {
            floating = false,
        }
    },
    {
        rule = {
            type = 'dialog',
        },
        properties = {
            floating = true,
        }
    },
}

function titlebar_toggle(c)
    if awful.client.floating.get(c) then
        awful.titlebar.add(c, {modkey = modkey })
    else
        awful.titlebar.remove(c)
    end
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end

-- Signal function to execute when a new client appears.
client.add_signal("manage", function(c, startup)
    if not startup then
        awful.client.setslave(c)

        if not c.size_hints.user_position and
            not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    titlebar_toggle(c)
    c:add_signal("property::floating", titlebar_toggle)
end)

client.add_signal("focus",
                  function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus",
                  function(c) c.border_color = beautiful.border_normal end)

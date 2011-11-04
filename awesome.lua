require("awful")
require("awful.autofocus")
require("beautiful")
require("naughty")

-- custom modules
require("revelation")
require("shifty")
require("panel")
require("volume")
tb = require('toolbox')

dir = {}
dir.config = awful.util.getdir('config')
dir.cache = awful.util.getdir('cache')
dir.theme = tb.path.join(dir.config, "/themes/zenburn")

beautiful.init(dir.theme .. "/theme.lua")

browser  = tb.client.create_launcher("firefox", true)
editor   = tb.client.create_launcher("gvim", true)
filemgr  = tb.client.create_launcher("thunar", true)
mail     = ""
music    = tb.client.create_launcher("sonata", false)
terminal = tb.client.create_launcher("urxvt")
modkey   = "Mod4"

mwfact80 = ((screen.count() - 1) > 0 and 0.4) or 0.52

shifty.config.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
}

-- Shifty configuration
shifty.config.tags = {
    vim = {
        exclusive   = (screen.count() == 1),
        init        = true,
        mwfact      = mwfact80,
        position    = 1,
        screen      = 1,
        run         = editor,
    },
    mail = {
        init     = true,
        position = 2,
        screen   = 2,
        spawn    = mail,
    },
    office = {
        layout   = awful.layout.suit.floating,
        position = 3,
    },
    web = {
        layout      = awful.layout.suit.tile.bottom,
        max_clients = 1,
        exclusive   = true,
        position    = 4,
    },
    vbx = {
        exclusive   = true,
        layout      = awful.layout.suit.tile.bottom,
        max_clients = 1,
        mwfact      = 0.75,
        position    = 6,
    },
    ds = {
        layout   = awful.layout.suit.max,
        position = 7,
        slave    = false,
    },
    media = {
        layout   = awful.layout.suit.floating,
        position = 8
    },
}

shifty.config.apps = {
    {
        match          = {""},
        float          = true,
        honorsizehints = true,
        buttons        = awful.util.table.join(
            awful.button({}, 1, function(c) client.focus = c; c:raise() end),
            awful.button({modkey}, 1, awful.mouse.client.move),
            awful.button({modkey}, 3, awful.mouse.client.resize)),
        slave          = true,
    },
    {
        match = {"libreoffice.*"},
        tag   = "office",
    },
    {
        match = {"vim", "gvim"},
        tag   = "vim",
        float = false,
    },
    {
        match = {"Navigator", "Firefox"},
        tag   = "web",
        float = false,
    },
    {
        match = {"Google%-chrome"},
        tag   = "mail",
        float = false,
    },
    {
        match = {"Evince"},
        tag   = "ds",
        float = false,
    },
    {
        match = {"VBox.*"},
        tag   = "vbx",
        float = false,
    },
    {
        match          = {"urxvt"},
        honorsizehints = false,
        float          = false,
    },
    {
        match = {"dialog", "%-applet", "MPlayer", "Sonata"},
        intrusive = true,
        float = true,
    },
}

shifty.config.defaults = {
    layout  = awful.layout.suit.tile,
    ncol    = 1,
    nmaster = 1,
}

shifty.config.sloppy = false
shifty.config.float_bars = true
shifty.modkey = modkey

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

shifty.config.clientkeys = awful.util.table.join(
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

for s = 1, screen.count() do
    panel({
            s = s,
            position='bottom',
            modkey=modkey,
            layouts=shifty.config.layouts
        })
end

shifty.taglist = panel.taglist
shifty.init()

client.add_signal("focus",
                  function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus",
                  function(c) c.border_color = beautiful.border_normal end)

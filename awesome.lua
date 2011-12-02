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
-- dir.theme = "/usr/share/awesome/themes/zenburn"

beautiful.init(dir.theme .. "/theme.lua")
beautiful.iconpath = dir.theme

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
        exclusive   = true,
        max_clients = 1,
        position    = 4,
    },
    vbx = {
        exclusive   = true,
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
        match = {"dialog", "%-applet", "MPlayer", "Sonata", "Thunar"},
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

for s = 1, screen.count() do
    panel({
            s = s,
            position='top',
            modkey=modkey,
            layouts=shifty.config.layouts
        })
end

dofile(tb.path.join(dir.config, 'keys.lua'))

shifty.taglist = panel.taglist
shifty.init()

client.add_signal("focus",
                  function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus",
                  function(c) c.border_color = beautiful.border_normal end)

-- awesome rc variables
settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey"
beautiful.init(settings.theme_path.."/theme.lua")

settings = {
    modkey = "Mod4",
    theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey",
    mwfact80 = ((screen.count() - 1) > 0 and 0.4) or 0.52,
    icon_path = beautiful.iconpath,

    apps = {
        terminal = "urxvt",
        browser  = "firefox",
        mail     = "",
        filemgr  = "thunar",
        editor   = "gvim"
        },

    layouts = {
        awful.layout.suit.tile.left,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.floating
        },

    opacity = {
        default = {focus = 1.0, unfocus = 0.8},
        Easytag = {focus = 1.0, unfocus = 0.9},
        Gschem  = {focus = 1.0, unfocus = 1.0},
        Gimp    = {focus = 1.0, unfocus = 1.0},
        MPlayer = {focus = 1.0, unfocus = 1.0},
        Ipython = {focus = 1.0, unfocus = 1.0},
        },

    mpd = {
        format  = "${Artist}: ${Title}",
        pattern = "$({*%w+}*)",
        length  = 15
        }
    }

-- shifty configured tags
shifty.config.tags = {
    vim = {layout = awful.layout.suit.tile, mwfact = settings.mwfact80,
           exclusive = not (screen.count() > 1), solitary = false, position = 1,
           init = true, screen = 1, slave = true, spawn = settings.apps.editor},

    ds = {layout = awful.layout.suit.max, mwfact = 0.70,
          exclusive = false, solitary = false, position = 2, init = false,
          persist = false, nopopup = false, slave = false},

    dz = {layout = awful.layout.suit.tile, mwfact = 0.70,
          exclusive = false, solitary = false, position = 3, init = false,
          nopopup = true, leave_kills = true},

    web = {layout = awful.layout.suit.tile.bottom, mwfact = 0.65,
           exclusive = true, solitary = true, position = 4,  init = false,
           spawn = settings.apps.browser},

    mail = {layout = awful.layout.suit.tile, mwfact = 0.61,
            exclusive = false, solitary = false, position = 1, init = false,
            spawn = settings.apps.mail, slave = true, screen = 2},

    vbx = {layout = awful.layout.suit.tile.bottom, mwfact = 0.75,
           exclusive = true, solitary = true, position = 6, init = false,
           spawn = 'VBoxSDL -vm xp2'},

    media = {layout = awful.layout.suit.floating, exclusive = false,
             solitary = false, position = 8},

    gimp = {layout = awful.layout.suit.tile, exclusive = false,
            solitary = false, position = 8, ncol = 3, mwfact = 0.75,
            nmaster = 1, spawn = 'gimp-2.6', slave = true},
    }

-- shifty application matching rules
shifty.config.apps = {
    {match = {"vim", "gvim"}, tag = "vim", honorsizehints = true,},
    {match = {"Navigator", "Vimperator", "Gran Paradiso"}, tag = "web"},
    {match = {"Google%-chrome"}, tag = "mail"},
    {match = {"pcb", "gschem", "eagle"}, tag = "dz", slave = false},
    {match = {"PCB_Log", "Status", "Page Manager"}, tag = "dz", slave = true},
    {match = {"acroread", "Apvlv", "Evince"}, tag = "ds"},
    {match = {"VBox.*", "VirtualBox.*"}, tag = "vbx"},
    {match = {"Mirage", "gtkpod", "Ufraw", "easytag"},
     tag = "media", nopopup = true},
    {match = {"gimp%-image%-window", "Ufraw"}, tag = "gimp"},
    {match = {"gimp%-dock", "gimp%-toolbox"},
     tag = "gimp", slave = true, dockable = true, honorsizehints = true},
    {match = {"dialog", "Gnuplot", "galculator", "sonata", "Wicd%-client.py",
              "R Graphics", "Figure", "Thunar", "Pcmanfm", "MPlayer"},
     float = true, honorsizehints = true, opacity = 1.0},
    {match = {"urxvt"}, honorsizehints = false, slave = true},
    {match = {""},
        buttons = awful.util.table.join(
            awful.button({}, 1, function (c) client.focus = c; c:raise() end),
            awful.button({settings.modkey}, 1, function(c)
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
                end),
            awful.button({settings.modkey}, 3, awful.mouse.client.resize),
            awful.button({settings.modkey}, 8, awful.mouse.client.resize))}
    }

shifty.config.defaults = {
    layout = awful.layout.suit.tile.bottom,
    ncol = 1,
    nmaster = 1,
    }

shifty.config.sloppy = false
shifty.config.float_bars = true

shifty.modkey = settings.modkey

-- the shifty stuff is setting things in the module,
-- so no need to export that here
return settings

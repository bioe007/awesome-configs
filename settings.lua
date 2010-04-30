-- awesome rc variables
settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey"

settings = {
    --{{{
    modkey     = "Mod4",
    theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey",
    icon_path  = beautiful.iconpath,
    mwfact80   = ((screen.count() - 1) > 0 and 0.4) or 0.52,

    apps = {
        --{{{
        terminal  = "urxvt",
        browser   = "firefox",
        mail      = "/home/perry/.bin/mutt-start.sh",
        filemgr   = "thunar",
        music     = "mocp --server",
        editor    = "/home/perry/.bin/vim-start.sh"
    },
    --}}}

    layouts = {
        --{{{
        awful.layout.suit.tile.left,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.floating
    },
    --}}}

    opacity = {
        -- {{{
        default = {focus = 1.0, unfocus = 0.90},
        Easytag = {focus = 1.0, unfocus = 0.95},
        mutt = {focus = 1.0, unfocus = 0.95},
        Gschem  = {focus = 1.0, unfocus = 1.0},
        Gimp    = {focus = 1.0, unfocus = 1.0},
        MPlayer = {focus = 1.0, unfocus = 1.0},
        Ipython = {focus = 1.0, unfocus = 1.0},
    },
    --}}}
}
--}}}

shifty.config.tags = {
--{{{

  vim     =  {layout = awful.layout.suit.tile, exclusive = false,
                position = 1, init = true, screen = 1, slave = true,
                mwfact = settings.mwfact80,
                spawn = settings.apps.editor},

  ds     =  {layout = awful.layout.suit.max, mwfact = 0.70, screen = 2,
                exclusive = false, position = 2, init = false,
                persist = false, nopopup = false, slave = false},

  dz     =  {layout = awful.layout.suit.tile, mwfact = 0.70,
                exclusive = false, position = 3, init = false,
                nopopup = true, leave_kills = true},

  web    =  {layout = awful.layout.suit.tile.bottom, mwfact = 0.65,
                exclusive = true, max_clients = 1, position = 4,  init = false,
                spawn   = settings.apps.browser},

  mail   =  {layout = awful.layout.suit.tile, mwfact = settings.mwfact80,
                exclusive = false, position = 1, init = false,
                spawn = settings.apps.mail, slave = true, screen = 2},

  vbx    =  {layout = awful.layout.suit.tile.bottom, mwfact = 0.75,
                exclusive = true, max_clients = 1, position = 6, init = false,
                spawn = 'VBoxSDL -vm xp2'},

  media  =  {layout = awful.layout.suit.floating, exclusive = false,
                screen = 2, position = 8},

  gimp  =  {layout = awful.layout.suit.tile, exclusive = false,
                position = 9, ncol = 3, mwfact = 0.75,
                nmaster=1,
                spawn = 'gimp-2.6', slave = true},

  office =  {layout = awful.layout.suit.tile, position  = 9}
}
--}}}

shifty.config.apps = {
--{{{
  {match   = {"vim"},
    tag     = "vim", honorsizehints = false, master = true},

  {match   = {"Navigator", "Vimperator", "Gran Paradiso"},
    tag     = "web"},

  {match   = {"mutt"},
    tag     = "mail"},

  {match   = {"gnumeric", "abiword"},
    tag     = "office"},

  {match   = {"pcb", "gschem", "eagle"},
    tag     = "dz",
    slave   = false},

  {match   = {"PCB_Log", "Status", "Page Manager"},
    tag     = "dz",
    slave   = true},

  {match   = {"acroread", "Apvlv", "Evince"},
    tag     = "ds"},

  {match   = {"VBox.*", "VirtualBox.*"},
    tag     = "vbx"},

  {match   = {"Mirage", "gtkpod", "Ufraw", "easytag"},
    tag     = "media",
    nopopup = true},

  {match   = {"gimp%-image%-window", "Ufraw"},
    tag     = "gimp"},

  {match   = {"gimp%-dock", "gimp%-toolbox"},
    tag     = "gimp",
    slave   = true, dockable = true, honorsizehints = false},

  {match   = {"dialog", "Gnuplot", "galculator",
                "R Graphics", "Figure" },
    float   = true, honorsizehints = true, opacity = 1.0},

    {match = {"Skype"},
    sticky = true, tag = "media", honorsizehints = truei, float = true},

  {match = {"MPlayer"},
    float = true, honorsizehints = true, ontop = true, intrusive = true},

  {match   = {"urxvt", "mutt"},
    honorsizehints = false,
    slave   = true},

  {match = {""},
    buttons = awful.util.table.join(
        awful.button({}, 1, function(c) client.focus = c; c:raise() end),
        awful.button({settings.modkey}, 1, function(c)
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({settings.modkey}, 3, awful.mouse.client.resize))
  }
}
--}}}

shifty.config.defaults={
    --{{{
    layout = awful.layout.suit.tile.bottom,
    ncol = 1,
    nmaster = 1,
    run = function(tag)
            number=awful.tag.getproperty(tag, "position") or
                shifty.tag2index(tag.screen, tag)
            naughty.notify({
                text =  markup.fg(beautiful.fg_normal,
                        markup.fg(beautiful.fg_sb_hi,
                        "Shifty Created: " .. number .. " : " ..
                        (tag.name or "foo")))
                })
            end
}
--}}}

shifty.config.sloppy = false

shifty.modkey = settings.modkey

-- the shifty stuff is setting things in the module, so no need to export that
-- here
return settings



-- vim:set ft=lua fdm=marker ts=4 sw=4 et ai si: --

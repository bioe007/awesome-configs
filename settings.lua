-- awesome rc variables
settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/grey"
beautiful.init(settings.theme_path.."/theme.lua")

settings = {
  modkey     = "Mod4",
  theme_path = os.getenv("HOME").."/.config/awesome/themes/grey",
  icon_path  = beautiful.iconpath,

  --{{{ apps
  apps = {
    terminal  = "urxvt",
    browser   = "firefox",
    mail      = "/home/perry/.bin/mutt-start.sh",
    filemgr   = "thunar",
    music     = "mocp --server",
    editor    = "/home/perry/.bin/vim-start.sh"
  },
  --}}}

  --{{{ layouts
  layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating
  },
  --}}}

  -- {{{ opacity
  opacity = { 
    default = { focus = 1.0, unfocus = 0.8 },
    Easytag = { focus = 1.0, unfocus = 0.9 },
    Gschem  = { focus = 1.0, unfocus = 1.0 },
    Gimp    = { focus = 1.0, unfocus = 1.0 },
    MPlayer = { focus = 1.0, unfocus = 1.0 },
  },
  -- }}}
}

--{{{ shifty configured tags
shifty.config.tags = {
  w2     =  { layout = awful.layout.suit.tile.bottom, mwfact = 0.62,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 2 }, 

  vim     =  { layout = awful.layout.suit.tile, mwfact = 0.61,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 1, slave = true, spawn = settings.apps.editor  }, 

  ds     =  { layout = awful.layout.suit.max        , mwfact = 0.70,
                exclusive = false, solitary = false, position = 2, init = false,
                persist = false, nopopup = false , slave = false }, 

  dz     =  { layout = awful.layout.suit.tile       , mwfact = 0.70,
                exclusive = false, solitary = false, position = 3, init = false,
                nopopup = true, leave_kills = true }, 

  web    =  { layout = awful.layout.suit.tile.bottom, mwfact = 0.65,
                exclusive = true, solitary = true, position = 4,  init = false,
                spawn   = settings.apps.browser }, 

  mail   =  { layout = awful.layout.suit.tile        , mwfact = 0.61,
                exclusive = false, solitary = false, position = 5, init = false,
                spawn   = settings.apps.mail, slave       = true  }, 

  vbx    =  { layout = awful.layout.suit.tile.bottom , mwfact = 0.75,
                exclusive = true, solitary = true, position = 6, init = false,
                spawn = 'VBoxSDL -vm xp2' }, 


  media  =  { layout = awful.layout.suit.floating    , exclusive = false , 
                solitary  = false, position = 8     }, 

  gimp  =  { layout = awful.layout.suit.tile    , exclusive = false , 
                solitary  = false, position = 8, ncol = 3, mwfact = 0.75,
                nmaster=1,
                spawn = 'gimp-2.6', slave = true                                    }, 

  office =  { layout = awful.layout.suit.tile        , position  = 9 }
}
--}}}

--{{{ shifty application matching rules
shifty.config.apps = {
  { match   = { "vim","gvim" }, 
    tag     = "vim"                                         },

  { match   = { "Navigator","Vimperator","Gran Paradiso" }, 
    tag     = "web"                                         },

  { match   = { "mutt", "Shredder.*" },
    tag     = "mail"                                        },

  { match   = { "OpenOffice.*" },
    tag     = "office"                                      },

  { match   = { "pcb","gschem", "eagle" },
    tag     = "dz",
    slave   = false                                         },

  { match   = { "PCB_Log","Status","Page Manager" }, 
    tag     = "dz", 
    slave   = true                                          },

  { match   = { "acroread","Apvlv","Evince" }, 
    tag     = "ds"                                          },

  { match   = { "VBox.*","VirtualBox.*" },
    tag     = "vbx"                                         },

  { match   = { "Mirage","gtkpod","Ufraw","easytag"},
    tag     = "media",
    nopopup = true                                          },

  { match   = { "gimp%-image%-window","Ufraw"               },
    tag     = "gimp"                                        },

  { match   = { "gimp%-dock","gimp%-toolbox" },
    tag     = "gimp",                                     
    slave   = true, dockable = true, honorsizehints=false   },

  { match   = { "dialog", "Gnuplot", "galculator","R Graphics" }, 
    float   = true, honorsizehints = true                   },

  { match   = { "MPlayer" }, 
    float   = true, honorsizehints = true, ontop=true       },

  { match   = { "urxvt","vim","mutt" },
    honorsizehints = false, 
    slave   = true                                          },

  { match = { "" }, 
    buttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ settings.modkey }, 1, awful.mouse.client.move),
        awful.button({ settings.modkey }, 3, awful.mouse.client.resize),
        awful.button({ settings.modkey }, 8, awful.mouse.client.resize))
  }
}
--}}}

shifty.config.defaults={
    layout = awful.layout.suit.tile.bottom,
    ncol = 1,
    floatBars=true, 
    run = function(tag)
            number=awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag)
            naughty.notify({
                text = markup.fg(beautiful.fg_normal, markup.fg( beautiful.fg_sb_hi,
                        "Shifty Created: ".. number .." : "..  (tag.name or "foo")))
            })
        end, 
}

shifty.config.sloppy = true

shifty.modkey = settings.modkey

-- the shifty stuff is setting things in the module, so no need to export that here
return settings
-- vim:set filetype=lua textwidth=120 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

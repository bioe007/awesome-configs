-- blue theme for awesome window manager
--
--  *check that path, wp command and font is appropriate
--
-- by: bioe007 perrydothargraveatgmaildotcom
--

white      = "#ffffff"
blue_dark  = "#486274"
blue_light = "#839ab1"
nearwhite  = "#efffff"

theme          = {}
theme.font     = "HeldustryFTVBasic Black 8"
theme.path     = os.getenv("HOME").."/.config/awesome/themes/blue"
theme.iconpath = theme.path

theme.wallpaper_cmd  = { [1]= "nitrogen --restore" }

theme.bg_normal     = blue_dark
theme.bg_focus      = blue_light
theme.bg_urgent     = "#288ef6"
theme.fg_normal     = "#b9b9dd"
theme.fg_focus      = nearwhite
theme.fg_urgent     = white

-- specific
theme.fg_sb_hi      = "#dfdfff"
theme.fg_batt_mid   = "#00cb00"
theme.fg_batt_low   = "#e6f21d"
theme.fg_batt_crit  = "#f8700a"
theme.widg_cpu_st   = "#243367"
theme.widg_cpu_mid  = "#285577"
theme.widg_cpu_end  = "#AEC6D8"
theme.vol_bg        = "#000033"

theme.border_width  = 1
theme.border_normal = "#000124"
theme.border_focus  = "#4148ea"
theme.border_marked = "#0000f0"

-- calendar settings
theme.calendar_w  = 160
theme.calendar_fg = nearwhite
theme.calendar_bg = blue_dark
 
-- menu settings
theme.menu_height = 15
theme.menu_width = 100

theme.titlebar_bg_focus = blue_light
theme.titlebar_bg_normal = blue_dark
  
  -- Display the taglist squares
theme.taglist_squares = true
theme.taglist_squares_sel = theme.path.."/taglist/squarefw.png"
theme.taglist_squares_unsel = theme.path.."/taglist/squarew.png"

theme.tasklist_floating_icon = theme.path.."/tasklist/float.gif"

  -- Display close button inside titlebar
theme.titlebar_close_button = true

  -- Define the image to load
  -- @ (if titlebar_close_button_[normal|focus] these values are ignored)
theme.titlebar_close_button_normal = theme.path.."/titlebar/close-inactive.png"
theme.titlebar_close_button_focus  = theme.path.."/titlebar/close-active.png"

  -- You can use your own layout icons like this:
theme.layout_dwindle    = theme.path.."/layouts/dwindlew.png"
theme.layout_fairh      = theme.path.."/layouts/fairhw.png"
theme.layout_fairv      = theme.path.."/layouts/fairvw.png"
theme.layout_floating   = theme.path.."/layouts/floatingw.png"
theme.layout_magnifier  = theme.path.."/layouts/magnifierw.png"
theme.layout_max        = theme.path.."/layouts/maxw.png"
theme.layout_spiral     = theme.path.."/layouts/spiralw.png"
theme.layout_tilebottom = theme.path.."/layouts/tilebottomw.png"
theme.layout_tileleft   = theme.path.."/layouts/tileleftw.png"
theme.layout_tile       = theme.path.."/layouts/tilew.png"
theme.layout_tiletop    = theme.path.."/layouts/tiletopw.png"
theme.iconpath          = theme.path.."/"

return theme



-- vim:set filetype=lua textwidth=80 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

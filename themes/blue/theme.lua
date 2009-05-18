path="~/.config/awesome/themes/blue"

white = "#ffffff"
blue_dark = "#4e6274"
blue_light = "#839ab1"
nearwhite = "#cfffff"

theme = {}

theme.font = "Terminus 8"
theme.bg_normal     = blue_dark
theme.bg_focus      = blue_light
theme.bg_urgent     = "#288ef6"
theme.fg_normal     = "#a8a8dd"
theme.fg_focus      = nearwhite
theme.fg_urgent     = white
  -- specific
theme.fg_sb_hi     = "#cfcfff"
theme.fg_batt_mid  = "#00cb00"
theme.fg_batt_low  = "#e6f21d"
theme.fg_batt_crit = "#f8700a"
theme.widg_cpu_st  = "#243367"
theme.widg_cpu_mid = "#285577"
theme.widg_cpu_end = "#AEC6D8"
theme.vol_bg       = "#000033"

theme.border_width  = 1
theme.border_normal = "#000124"
theme.border_focus  = "#4148ea"
theme.border_marked = "#0000f0"

  -- calendar settings
theme.calendar_w = 160
theme.calendar_fg = nearwhite
theme.calendar_bg = blue_dark
 
  -- menu settings
theme.menu_height = 15
theme.menu_width = 100
  -- There are another variables sets overriding the default one when
  -- defined, the sets are:
  -- [taglist|tasklist]_[bg|fg]_[focus|urgent]
  -- titlebar_[bg|fg]_[normal|focus]
  -- Example:
  --taglist_bg_focus = #ff0000
theme.titlebar_bg_focus = blue_light
theme.titlebar_bg_normal = blue_dark
  
  -- Display the taglist squares
theme.taglist_squares = true
theme.taglist_squares_sel = path.."/taglist/squarefw.png"
theme.taglist_squares_unsel = path.."/taglist/squarew.png"

theme.tasklist_floating_icon = path.."/tasklist/float.gif"

  -- Display close button inside titlebar
theme.titlebar_close_button = true

  -- Define the image to load
  -- @ (if titlebar_close_button_[normal|focus] these values are ignored)
theme.titlebar_close_button_normal = path.."/titlebar/close-inactive.png"
theme.titlebar_close_button_focus  = path.."/titlebar/close-active.png"

  -- You can use your own layout icons like this:
theme.layout_dwindle    = path.."/layouts/dwindlew.png"
theme.layout_fairh      = path.."/layouts/fairhw.png"
theme.layout_fairv      = path.."/layouts/fairvw.png"
theme.layout_floating   = path.."/layouts/floatingw.png"
theme.layout_magnifier  = path.."/layouts/magnifierw.png"
theme.layout_max        = path.."/layouts/maxw.png"
theme.layout_spiral     = path.."/layouts/spiralw.png"
theme.layout_tilebottom = path.."/layouts/tilebottomw.png"
theme.layout_tileleft   = path.."/layouts/tileleftw.png"
theme.layout_tile       = path.."/layouts/tilew.png"
theme.layout_tiletop    = path.."/layouts/tiletopw.png"
theme.iconpath          = path.."/"
theme.wallpaper_cmd  = { [1] = "nitrogen --restore" }

return theme

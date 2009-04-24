---------------------------
-- Default awesome theme --
---------------------------
path="/home/perry/.config/awesome/themes/blue"

white = "#ffffff"
blue_dark = "#4e6274"
blue_light = "#blue_light"
nearwhite = "#cfffff"

theme = {

  font = "Terminus 8",
  bg_normal     = blue_dark,
  bg_focus      = blue_light,
  bg_urgent     = "#288ef6",
  fg_normal     = "#a8a8dd",
  fg_focus      = nearwhite,
  fg_urgent     = white,
  -- specific
  fg_sb_hi     = #cfcfff,
  fg_batt_mid  = #00cb00,
  fg_batt_low  = #e6f21d,
  fg_batt_crit = #f8700a,
  widg_cpu_st  = #243367,
  widg_cpu_mid = #285577,
  widg_cpu_end = #AEC6D8,
  vol_bg       = #000033,

  border_width  = 1,
  border_normal = #000124,
  border_focus  = #4148ea,
  border_marked = #0000f0,

  -- calendar settings
  calendar_w = 160,
  calendar_fg = nearwhite,
  calendar_bg = blue_dark,
 
  -- menu settings
  menu_height = 15,
  menu_width = 100,
  -- There are another variables sets overriding the default one when
  -- defined, the sets are:
  -- [taglist|tasklist]_[bg|fg]_[focus|urgent],
  -- titlebar_[bg|fg]_[normal|focus],
  -- Example:,
  --taglist_bg_focus = #ff0000,
  titlebar_bg_focus = blue_light,
  titlebar_bg_normal = blue_dark,
  
  -- Display the taglist squares,
  taglist_squares = true,
  taglist_squares_sel = path.."/taglist/squarefw.png",
  taglist_squares_unsel = path.."/taglist/squarew.png",

  tasklist_floating_icon = path.."/tasklist/float.gif",

  -- Display close button inside titlebar,
  titlebar_close_button = true,

  -- Define the image to load,
  -- @ (if titlebar_close_button_[normal|focus] these values are ignored),
  titlebar_close_button_normal = path.."/titlebar/close-inactive.png",
  titlebar_close_button_focus  = path.."/titlebar/close-active.png",

  -- You can use your own layout icons like this:
  layout_dwindle    = path.."/layouts/dwindlew.png",
  layout_fairh      = path.."/layouts/fairhw.png",
  layout_fairv      = path.."/layouts/fairvw.png",
  layout_floating   = path.."/layouts/floatingw.png",
  layout_magnifier  = path.."/layouts/magnifierw.png",
  layout_max        = path.."/layouts/maxw.png",
  layout_spiral     = path.."/layouts/spiralw.png",
  layout_tilebottom = path.."/layouts/tilebottomw.png",
  layout_tileleft   = path.."/layouts/tileleftw.png",
  layout_tile       = path.."/layouts/tilew.png",
  layout_tiletop    = path.."/layouts/tiletopw.png",
  iconpath          = path.."/",
  wallpaper_cmd     = "nitrogen --restore",
}
return theme

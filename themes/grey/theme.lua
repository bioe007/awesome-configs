--[[ Grey theme for awesome window manager
--
--  *check that path, wp command and font is appropriate
--
-- by: bioe007 perrydothargraveatgmaildotcom
-- ]]--

theme          = {}
theme.font     = "HeldustryFTVBasic Black 8"
-- theme.font     = "mintsstrong 16"
-- theme.font     = "SFAutomatonCondensed 9"
-- theme.font     = "PTF NORDIC Std 11"
-- theme.font     = "MANDATORY 9"
theme.path     = os.getenv("HOME").."/.config/awesome/themes/grey"
theme.iconpath = theme.path

theme.wallpaper_cmd = { [1] = "nitrogen --restore" }

theme.bg_normal          = "#ababab"
theme.bg_focus           = "#8d8d8d"
theme.bg_urgent          = "#288ef6"
theme.fg_normal          = "#555555"
theme.fg_focus           = "#dfdfdf"
theme.fg_urgent          = "#ffaaaa"

-- specific
theme.fg_sb_hi           = "#343434"
theme.fg_batt_mid        = "#008600"
theme.fg_batt_low        = "#e4f01b"
theme.fg_batt_crit       = "#a84007"
theme.widg_cpu_st        = "#343434"
theme.widg_cpu_mid       = "#888888"
theme.widg_cpu_end       = "#cccccc"
theme.vol_bg             = "#000000"

theme.border_width  = 2
theme.border_normal = "#000000"
theme.border_focus  = "#3accc5"
theme.border_marked = "#0000f0"
theme.tooltip_border_color = theme.fg_focus

-- calendar settings
theme.calendar_w         = 160
theme.calendar_fg        = theme.bg_normal
theme.calendar_bg        = theme.fg_normal

theme.menu_height        = 15
theme.menu_width         = 100

theme.titlebar_bg_focus  = "#6d6d6d"
theme.titlebar_bg_normal = "#ababab"

-- taglist squares
theme.taglist_squares       = true
theme.taglist_squares_sel   = theme.path.."/taglist/squarefw.png"
theme.taglist_squares_unsel = theme.path.."/taglist/squarew.png"

theme.tasklist_floating_icon = theme.path.."/tasklist/float.gif"

theme.titlebar_close_button        = true
theme.titlebar_close_button_normal = theme.path.."/titlebar/close-inactive.png"
theme.titlebar_close_button_focus  = theme.path.."/titlebar/close-active.png"

-- You can use your own layout icons like this:
theme.layout_dwindle    = theme.path.."/layouts/dwindle.png"
theme.layout_fairh      = theme.path.."/layouts/fairh.png"
theme.layout_fairv      = theme.path.."/layouts/fairv.png"
theme.layout_floating   = theme.path.."/layouts/floating.png"
theme.layout_magnifier  = theme.path.."/layouts/magnifier.png"
theme.layout_max        = theme.path.."/layouts/max.png"
theme.layout_spiral     = theme.path.."/layouts/spiral.png"
theme.layout_tilebottom = theme.path.."/layouts/tilebottom.png"
theme.layout_tileleft   = theme.path.."/layouts/tileleft.png"
theme.layout_tile       = theme.path.."/layouts/tile.png"
theme.layout_tiletop    = theme.path.."/layouts/tiletop.png"


return theme



-- vim:set filetype=lua textwidth=80 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

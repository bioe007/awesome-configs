--[[ Grey theme for awesome window manager
--
--  *check that path, wp command and font is appropriate
--
-- by: resixianatgmail.com
-- ]]--

theme          = {}
theme.font     = "Terminus 10"

theme.path     = os.getenv("HOME").."/.config/awesome/themes/dk_grey"
theme.iconpath = theme.path

theme.wallpaper_cmd = { [1] = "nitrogen --restore" }

theme.fg_normal          = "#abbfab"
theme.bg_normal          = "#555555"
theme.fg_focus           = "#bdedbe"
theme.bg_focus           = "#3f3034"
theme.bg_urgent          = "#288ef6"
theme.fg_urgent          = "#ffaaaa"

-- specific
theme.fg_sb_hi           = "#9dcd9e"
theme.fg_batt_mid        = "#008600"
theme.fg_batt_low        = "#e4f01b"
theme.fg_batt_crit       = "#a84007"
theme.vol_bg             = "#000000"

theme.border_width  = 2
theme.border_normal = "#000000"
theme.border_focus  = "#3accc5"
theme.border_marked = "#0000f0"
theme.tooltip_border_color = theme.fg_focus

-- calendar settings
theme.calendar_w         = 160
theme.calendar_fg        = theme.fg_normal
theme.calendar_bg        = theme.bg_normal

theme.menu_height        = 15
theme.menu_width         = 100

-- titlebar
theme.titlebar_bg_focus  = "#6d6d6d"
theme.titlebar_bg_normal = "#ababab"
theme.titlebar_close_button_focus  = theme.path .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.path .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme.path .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.path .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.path .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.path .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme.path .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.path .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.path .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.path .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme.path .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.path .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.path .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.path .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme.path .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.path .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.path .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.path .. "/titlebar/maximized_normal_inactive.png"

-- taglist squares
theme.taglist_squares       = true
theme.taglist_squares_sel   = theme.path.."/taglist/squarefw.png"
theme.taglist_squares_unsel = theme.path.."/taglist/squarew.png"

theme.tasklist_floating_icon = theme.path.."/tasklist/float.gif"

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

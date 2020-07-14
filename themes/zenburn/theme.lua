-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
theme.wallpaper_cmd = {
    "/usr/bin/nitrogen --restore"
}
theme.home = os.getenv("HOME") ..  "/.config/awesome/themes/zenburn"
-- }}}

-- {{{ Styles
theme.font      = "bitstream vera sans 11"

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#3F3F3F"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width  = "4"
theme.border_normal = "#3F3636"
theme.border_focus  = "#6FAF6F"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#353F38"
theme.titlebar_bg_normal = "#496F66"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "26"
theme.menu_width  = "440"
theme.menu_border_width = "2"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = theme.home .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = theme.home .. "/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme.home .. "/awesome-icon.png"
theme.menu_submenu_icon      = theme.home .. "/default/submenu.png"
theme.tasklist_floating_icon = theme.home .. "/default/tasklist/floatingw.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = theme.home .. "/layouts/tile.png"
theme.layout_tileleft   = theme.home .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme.home .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme.home .. "/layouts/tiletop.png"
theme.layout_fairv      = theme.home .. "/layouts/fairv.png"
theme.layout_fairh      = theme.home .. "/layouts/fairh.png"
theme.layout_spiral     = theme.home .. "/layouts/spiral.png"
theme.layout_dwindle    = theme.home .. "/layouts/dwindle.png"
theme.layout_max        = theme.home .. "/layouts/max.png"
theme.layout_fullscreen = theme.home .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme.home .. "/layouts/magnifier.png"
theme.layout_floating   = theme.home .. "/layouts/floating.png"
-- }}}
-- {{{ Lain
theme.layout_termfair    = theme.home .. "/layouts/termfair.png"
theme.layout_centerfair  = theme.home .. "/layouts/centerfair.png"  -- termfair.center
theme.layout_cascade     = theme.home .. "/layouts/cascade.png"
theme.layout_cascadetile = theme.home .. "/layouts/cascadetile.png" -- cascade.tile
theme.layout_centerwork  = theme.home .. "/layouts/centerwork.png"
theme.layout_centerworkh = theme.home .. "/layouts/centerworkh.png" -- centerwork.horizontal
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = theme.home .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.home .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme.home .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.home .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.home .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.home .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme.home .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.home .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.home .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.home .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme.home .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.home .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.home .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.home .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme.home .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.home .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.home .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.home .. "/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

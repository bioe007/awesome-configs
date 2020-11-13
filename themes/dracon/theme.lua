--[[

  dracon awesomewm theme

--]]

pcall(require, "luarocks.loader")
local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local os = os

local name = "dracon"

local dark_purple = "#120533"
local purple_med = "#250b52"
local purple_light = "#af87ff"

local yellow_bright = "#f9ff87" -- "#ffffff"
local yellow_dim    = "#c49c50"

local blue_bright = "#20d5de"
local blue_dim = "#"

local pink_bright = "#ea32f2"

local theme             = {}
theme.dir               = os.getenv("HOME") .. "/.config/awesome/themes/" .. name
theme.font              = "Roboto Mono Medium 10"
theme.taglist_font      = "Font Awesome 5 Free Solid 12"
theme.fg_normal         = yellow_bright -- "#ffffff"
theme.fg_blue           = "#174DCB"
theme.fg_magenta        = "#CC00CC"
theme.fg_focus          = yellow_bright
theme.fg_urgent         = "#b74822"
theme.bg_normal         = "#22242F"
theme.bg_focus          = "#120533" -- "#174DCB"
theme.bg_urgent         = "#3F3F3F"
theme.taglist_fg_focus  = "#282a36"
theme.tasklist_bg_focus = dark_purple
theme.tasklist_fg_focus = yellow_bright -- "#CC00CC"
theme.tasklist_fg_normal = purple_light

theme.layoutlist_bg_selected = purple_light
theme.layoutlist_fg_selected = yellow_bright

theme.useless_gap   = dpi(6)
theme.border_width  = dpi(4)
theme.border_normal = "#330033"
theme.border_focus  = "#990099"
theme.border_marked = "#990099"

-- {{{ Titlebars
theme.titlebar_bg_focus                         = theme.bg_focus  .. "ff"
theme.titlebar_bg_normal                        = theme.bg_normal .. "ff"
theme.titlebar_fg_focus                         = theme.fg_focus
-- }}}

theme.menu_height = dpi(20)
theme.menu_width = dpi(140)
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

theme.awesome_icon = theme.dir .. "/icons/awesome.png"

theme.layout_tile       = theme.dir .. "/layouts/tile.png"
theme.layout_tileleft   = theme.dir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme.dir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme.dir .. "/layouts/fairv.png"
theme.layout_fairh      = theme.dir .. "/layouts/fairh.png"
theme.layout_spiral     = theme.dir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme.dir .. "/layouts/dwindle.png"
theme.layout_max        = theme.dir .. "/layouts/max.png"
theme.layout_fullscreen = theme.dir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme.dir .. "/layouts/magnifier.png"
theme.layout_floating   = theme.dir .. "/layouts/floating.png"
-- {{{ Lain
theme.layout_termfair    = theme.dir .. "/layouts/termfair.png"
theme.layout_centerfair  = theme.dir .. "/layouts/centerfair.png"  -- termfair.center
theme.layout_cascade     = theme.dir .. "/layouts/cascade.png"
theme.layout_cascadetile = theme.dir .. "/layouts/cascadetile.png" -- cascade.tile
theme.layout_centerwork  = theme.dir .. "/layouts/centerwork.png"
theme.layout_centerworkh = theme.dir .. "/layouts/centerworkh.png" -- centerwork.horizontal
-- }}}

theme.widget_ac          = theme.dir .. "/icons/ac.png"
theme.widget_mem         = theme.dir .. "/icons/mem.png"
theme.widget_cpu         = theme.dir .. "/icons/cpu.png"
theme.widget_temp        = theme.dir .. "/icons/temp.png"
theme.widget_net         = theme.dir .. "/icons/net.png"
theme.widget_hdd         = theme.dir .. "/icons/hdd.png"
theme.widget_music       = theme.dir .. "/icons/note.png"
theme.widget_music_on    = theme.dir .. "/icons/note.png"
theme.widget_music_pause = theme.dir .. "/icons/pause.png"
theme.widget_music_stop  = theme.dir .. "/icons/stop.png"
theme.widget_vol         = theme.dir .. "/icons/vol.png"
theme.widget_vol_low     = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no      = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute    = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail        = theme.dir .. "/icons/mail.png"
theme.widget_mail_on     = theme.dir .. "/icons/mail_on.png"
theme.widget_task        = theme.dir .. "/icons/task.png"
theme.widget_scissors    = theme.dir .. "/icons/scissors.png"
theme.widget_weather     = theme.dir .. "/icons/dish.png"

theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = false

theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"
theme.bg_systray                                = purple_med --"#22242F"

local separators = lain.util.separators




-- Separators
local arrow = separators.arrow_left

function theme.powerline_rl(cr, width, height)
    local arrow_depth, offset = height/2, 0

    -- Avoid going out of the (potential) clip area
    if arrow_depth < 0 then
        width  =  width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset + arrow_depth         , 0        )
    cr:line_to(offset + width               , 0        )
    cr:line_to(offset + width - arrow_depth , height/2 )
    cr:line_to(offset + width               , height   )
    cr:line_to(offset + arrow_depth         , height   )
    cr:line_to(offset                       , height/2 )

    cr:close_path()
end


return theme

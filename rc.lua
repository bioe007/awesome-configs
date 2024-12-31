-- {{{ quick TODO list -
-- 1. fix default layout on second monitor / distinct layouts per monitor (poss
-- dimension based)
-- 3. network widget/vis (for laptop)
-- 4. cpu and memory widgets (heat for laptop)
-- 5. battery for laptop

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
-- local mouse = require("mouse")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local lain = require("lain")

local audio_widget = require("awesome-pulseaudio-widget")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

beautiful.init(
    gears.filesystem.get_configuration_dir() ..  "themes/nord/theme.lua")

local terminal = "wezterm"
local editor = os.getenv("EDITOR") or "vim"
local editor_cmd = terminal .. " -e " .. editor

local modkey = "Mod4"

local max_tags = 4

awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- Table of layouts to cover with awful.layout.inc, order matters.
local my_layouts = {
    lain.layout.centerwork,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    -- lain.layout.termfair.center,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.max,
    -- awful.layout.suit.magnifier,
}
awful.layout.append_default_layouts(my_layouts)


-- {{{ Helper functions
local function layout_by_aspect(s)
    local screen_ratio = s.geometry.width / s.geometry.height
    if screen_ratio < 1 then return awful.layout.suit.tile.bottom end
    if screen_ratio < 2 then return awful.layout.suit.tile end
    return lain.layout.centerwork
end

local tags = {}
local function make_default_tag(number, screen, volatile)
    local t = awful.tag.add(tostring(number), {
        screen=screen,
        layout=layout_by_aspect(screen), -- awful.layout.layouts[1],
        master_count=1,
        volatile=volatile,
    })
    if tags[screen.index] == nil  then tags[screen.index] = {} end
    tags[screen.index][number] = t
end

local function launch(s)
    local lf = function()
        awful.util.spawn(s, false)
    end
    return lf
end

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Layout Dialog
-- My new, preferred way to change layouts.
local ll = awful.widget.layoutlist {
    opacity = .5,   -- TODO - this isn't working.
    base_layout = wibox.widget {
        spacing         = 15,
        forced_num_cols = 5,
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
        {
            {
                id            = 'icon_role',
                forced_height = 96,
                forced_width  = 96,
                widget        = wibox.widget.imagebox,
            },
            margins = 4,
            widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = 96,
        forced_height   = 96,
        shape           = gears.shape.rounded_rect,
        widget          = wibox.container.background,
    },
}


local layout_popup = awful.popup {
    widget = wibox.widget {
        ll,
        margins = 48,
        widget  = wibox.container.margin,
    },
    border_color = beautiful.fg_magenta,
    border_width = beautiful.border_width,
    placement    = awful.placement.centered,
    ontop        = true,
    visible      = false,
    shape        = gears.shape.rounded_rect
}

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
    awful.button({}, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end),
    awful.button({}, 3, client_menu_toggle_fn()),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    for i=1,max_tags,1 do
        make_default_tag(i, s)
    end
    s.tags[1]:view_only()


    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt({done_callback=function() s.mywibox.visible = false end})
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, visible = false })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            audio_widget(),
            mytextclock,
            s.mylayoutbox,
        },
    }


    s.detect = gears.timer {
        timeout = 0.25,
        callback = function ()
            if (mouse.screen ~= s) or
                (mouse.coords().y > s.mywibox.height)
            then
                s.mywibox.visible = false
            s.detect:stop()
        end
    end
    }

    s.enable_wibar = function ()
        s.mywibox.visible = true
        if not s.detect.started then
            s.detect:start()
        end
    end

    s.activation_zone = wibox ({
        x = s.geometry.x,
        -- y = s.geometry.y + s.geometry.height - 1,
        -- y = s.mywibox.height -1,
        y = 0,
        opacity = 0.0, width = s.geometry.width, height = 1,
        screen = s, input_passthrough = false, visible = true,
        ontop = true, type = "dock",
    })


    s.activation_zone:connect_signal("mouse::enter", function ()
        s.enable_wibar()
    end)
end)
-- }}}

-- {{{ systray
local my_systray = wibox.widget.systray()
local orig_bg = beautiful.bg_systray
function force_systray_redraw()
    beautiful.bg_systray = "#ff0000" -- Assuming this is not the actual BG color of your systray
    my_systray:emit_signal("widget::redraw_needed")
    gears.timer.start_new(0.5, function()
        beautiful.bg_systray = orig_bg
        my_systray:emit_signal("widget::redraw_needed")
    end)
end
-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

-- A lot of the times this just "Does the Wrong Thing(tm)" so I give up and
-- specify always the music player.
local playerctl = "playerctl -p YoutubeMusic"
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "/",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, "Shift" }, "space",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "space",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "b", function()
        local s = awful.screen.focused()
        s.mywibox.visible = not s.mywibox.visible
    end,
              {description = "toggle statusbar wibox", group = "tag"}),

    --- {{{ Windo Navigation
    awful.key({ modkey,           }, "j",
        function ()
        awful.client.focus.global_bydirection("down", nil, true)
        if client.focus then client.focus:raise() end
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.global_bydirection("up", nil, true)
            if client.focus then client.focus:raise() end
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey }, "h",
    function()
        awful.client.focus.global_bydirection("left", nil, true)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "l",
    function()
        awful.client.focus.global_bydirection("right", nil, true)
        if client.focus then client.focus:raise() end
    end),
    -- by index w/cursors because sometimes windows are buried
    awful.key({modkey}, "Up",
    function()
        awful.client.focus.byidx(1)
    end),
    awful.key({modkey}, "Down",
    function()
        awful.client.focus.byidx(-1)
    end),
    --- end experiment }}}
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({modkey, "Shift"}, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({modkey,}, "q", launch("dm-tool lock"),
              {description = "Lock screen", group = "awesome"}),
    awful.key({}, "Print", function()
            local cmd = "scrot -s " .. os.getenv("HOME") .. "/Images/Screenshots/"
            cmd = cmd .. "%F_%T_$wx$h.png "
            cmd = cmd .. "-e 'xclip -selection clipboard -target image/png -i $f'"
            awful.spawn(cmd)
        end,
        {description = "Screenshot - Rectangle select", group = "awesome"}),
    awful.key({"Shift"}, "Print", function()
            local cmd = "scrot -u -F " .. os.getenv("HOME") .. "/Images/Screenshots/"
            cmd = cmd .. "%F_%T_$wx$h.png "
            cmd = cmd .. "-e 'xclip -selection clipboard -target image/png -i $f'"
            awful.spawn(cmd)
        end,
        {description = "Screenshot - Window select", group = "awesome"}),

    -- {{{ Layout Manipulation
    awful.key({modkey}, "-", function() awful.tag.incmwfact(-0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({modkey, }, "=", function() awful.tag.incmwfact(0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({modkey, "Shift"}, "h", function() awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({modkey, "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({modkey, "Control"}, "h", function() awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({modkey, }, "Next", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, }, "Prior", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",
        function ()
            awful.screen.focused().mywibox.visible = true
            awful.screen.focused().mypromptbox:run()
        end,
        {description = "run prompt", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "r",
              function ()
                local wb = awful.screen.focused().mywibox
                wb.visible = true
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval",
                    done_callback= function() wb.visible = false end
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    -- Media keys
    awful.key({}, "XF86AudioPlay", function() awful.spawn.with_shell(playerctl .. " play-pause") end),
    awful.key({}, "XF86AudioNext", function() awful.spawn.with_shell(playerctl .. " next") end),
    awful.key({}, "XF86AudioPrev", function() awful.spawn.with_shell(playerctl .. " previous") end),

    awful.key({}, "XF86AudioRaiseVolume", function() os.execute("amixer set Master 5%+") end),
    awful.key({}, "XF86AudioLowerVolume", function() os.execute("amixer set Master 5%-") end),
    awful.key({}, "XF86AudioMute", function() os.execute("amixer set Master toggle") end)

)

clientkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey, "Shift"}, "0",
              function(c) c.sticky = not c.sticky end,
              {description = "Stick it", group = "client"}),
    awful.key({ modkey, }, "x", function(c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, }, "f",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({modkey, "Control"}, "Return", function(c)
            master = awful.client.getmaster()
            if c == master then
                -- quick hack to handle error when no other client on screen
                swap_target = awful.client.focus.history.get(c.screen, 1)
                if swap_target then c:swap(swap_target) end
            else
                c:swap(master)
            end
        end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"})
    -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
    --           {description = "toggle keep on top", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                            if awful.screen.focused().selected_tag == tag then
                                awful.tag.history.restore()
                            else
                                tag:view_only()
                            end
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
	    titlebars_enabled = false,
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Anki",
                "Arandr",
                "Bitwarden",
                "Blueman-manager",
                "Caja",
                "kdeconnect.app",
                "kdeconnect.sms",
                "mpv",
                "Pavucontrol",
                "YouTube Music Desktop App",
                "YouTube Music", -- this is youtube-music-bin from aur
            },
            name = {
                "Event Tester",  -- xev.
                "Steam Settings",
            },
            role = {
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            },
            type = { "dialog" }
        },
        properties = {
            floating = true,
            titlebars_enabled = true,
        }
    },

    -- sticky clients
    {
        rule = { class =  "YouTube Music" , },
        properties = {
		sticky = true,
		floating = true,
            titlebars_enabled = true,
	},
    },

    { rule_any = { class = { "steam" } },
        properties = {
            titlebars_enabled = false,
            floating = true,
            border_width = 0,
            border_color = 0,
            size_hints_honor = false,
            placement = awful.placement.centered,
        },
    },

    { rule_any = {
        class = {"disco.exe",},
        },
      properties = {
          titlebars_enabled = false,
          fullscreen = true,
          size_hints_honor = true,
      },
      callback = function(c)
          if c.fullscreen then
              gears.timer.delayed_call(function()
                  if c.valid then c:geometry(c.screen.geometry) end
              end
              )
          end
      end,
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    if c.transient_for then
        awful.placement.centered(c, {parent=c.transient_for})
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Properly size fullscreen clients over wibar
-- see here: https://github.com/awesomeWM/awesome/issues/1608
client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then c:geometry(c.screen.geometry)  end
        end)
    end
end)
-- }}}

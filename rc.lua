-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")


local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local lain = require("lain")

-- More efficient CPU/temp widgets from conky here:
--                  https://github.com/varingst/awesome-conky
-- Note that have to set nvidia_display in conkyrc and set output only to
-- stderr.
local conky = require("conky")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

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
    gears.filesystem.get_configuration_dir() ..  "themes/zenburn/theme.lua")

terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

max_tags = 5

autostart_applications = { 
    "mate-session",
    -- Disabled everything below here and just leaning on mate
    -- "mate-settings-daemon",
    -- "mate-panel",
    -- "mate-power-manager",
    -- "gpmdp",
    -- "redshift-gtk",
    -- "slack -u"
}

for app = 1, #autostart_applications do
    awful.spawn.with_shell(autostart_applications[app])
end


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    lain.layout.centerwork,
    lain.layout.termfair.center,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.max,
    -- awful.layout.suit.magnifier,
}

-- {{{ Helper functions
local function make_default_tag(number, screen, volatile)
    return awful.tag.add(tostring(number), {
        screen=screen,
        layout=awful.layout.layouts[1],
        master_count=0,
        volatile=volatile,
    })
end

local function launch(s) 
    lf = function()
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

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

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
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
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
    s.mypromptbox = awful.widget.prompt()
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
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {
            layout = wibox.layout.fixed.horizontal,
            conky.widget({
                label = "CPU: ",
                conky = "${cpu}%",
            }),
            conky.widget({
                label = " ",
                conky = "",
            }),
            conky.widget({
                label = "MEM: ",
                conky = "${memperc}%",
            }),
            conky.widget({
                label = " ",
                conky = "",
            }),
            conky.widget({
                label = "T_CPU: ",
                conky = "${hwmon 1 temp 1}",
            }),
            conky.widget({
                label = " ",
                conky = "",
            }),
            conky.widget({
                label = "T_GPU: ",
                conky = "${nvidia temp}",
            }),
            conky.widget({
                label = " ",
                conky = "",
            }),
            conky.widget({
                label = "/: ",
                conky = "${diskio /dev/disk/by-path/pci-0000:01:00.0-nvme-1-part5}",
            }),
            conky.widget({
                label = " ",
                conky = "",
            }),
            conky.widget({
                label = "var: ",
                conky = "${diskio /dev/disk/by-path/pci-0000:01:00.0-nvme-1-part6}",
            }),
            -- wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev),
    awful.button({modkey}, 4, launch("/home/perry/bin/pavol +5%")),
    awful.button({modkey}, 5, launch("/home/perry/bin/pavol -5%"))
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, "Shift"   }, "space",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "space",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    --- Experimental - by-direction... {{{
    awful.key({modkey,}, "j",
        function ()
            awful.client.focus.global_bydirection("down", nil, true)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({modkey,}, "k",
        function ()
            awful.client.focus.global_bydirection("up", nil, true)
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
    -- by direction w/cursors because sometimes windows are buried
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

    awful.key({ modkey,           }, "w", function () awful.spawn("google-chrome") end,
              {description = "Browser", group = "launcher"}),

    awful.key({}, "XF86MediaPlayer", launch("gpmdp"),
              {description = "Start music", group = "launcher"}),
    awful.key({}, "XF86AudioPlay", launch("playerctl play-pause"),
              {description = "Start music", group = "launcher"}),
    awful.key({}, "XF86AudioNext", launch("playerctl next"),
              {description = "Next song", group = "launcher"}),
    awful.key({}, "XF86AudioPrev", launch("playerctl previous"),
              {description = "Next song", group = "launcher"}),
    -- awful.key({}, "XF86AudioRaiseVolume", launch("/home/perry/bin/pavol +5%"),
              -- {description = "Raise volume", group = "launcher"}),
    -- awful.key({}, "XF86AudioLowerVolume", launch("/home/perry/bin/pavol -5%"),
              -- {description = "...", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

              awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Mod1"   }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Mod1"   }, "l", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "c",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey, "Shift"}, "0",
              function(c) c.sticky = not c.sticky end,
              {description = "Stick it", group = "client"}),
    awful.key({ modkey, }, "x",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" },
              "space", function(c) awful.client.floating.toggle(c) end,
              {description = "toggle floating", group = "client"}),
    awful.key({modkey, "Control"}, "Return", function(c)
            master = awful.client.getmaster()
            if c == master then
                c:swap(awful.client.focus.history.get(c.screen, 1))
            else
                c:swap(master)
            end
        end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              -- {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({modkey}, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = awful.tag.find_by_name(screen, tostring(i))
                        if not tag then
                            tag = make_default_tag(i, screen, true)
                        end
                        tag:view_only()
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = awful.tag.find_by_name(screen, tostring(i))
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local c = client.focus
                      if c then
                        local tag = awful.tag.find_by_name(screen, tostring(i))
                        if not tag then
                            tag = make_default_tag(tostring(i),c.screen, true) 
                        end
                        c:move_to_tag(tag)
                      end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.find_by_name(
                            client.focus.screen,
                            tostring(i))
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
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            -- titlebars_enabled = true,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Caja",
                "Mate-control-center",
                "Mate-appearance-properties",
                "Signal",
                "Slack",
                "Wpa_gui",
                "Pavucontrol",
                "Blueman-manager",
            },

            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            },
            type = { "dialog" }
        },
        properties = {
            floating = true,
        }
    },
    -- For mate-panel!
    {
        rule_any = {
            type = {"dock"},
        },
        properties = {
            floating = true,
            ontop = true,
            focusable = false,
            titlebars_enabled = false
        }
    },

    -- Add titlebars to normal clients and dialogs
    { 
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }
    },

    -- float, stick and *no* titlebars
    {
        rule_any = {
            class = {
                "Google Play Music Desktop Player",
            },
        },
        properties = {
            floating = true,
            titlebars_enabled = false,
            sticky = true,
        }
    }


}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Tried this in floating, etc... only place it works to hide the titlebar
    -- for mate-panel is here.
    if c.type == "dock" then
        awful.titlebar.hide(c)
    end
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
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

    if not ((awful.layout.get(c.screen) == awful.layout.suit.floating)
            or c.floating
            or c.titlebars_enabled) then
        awful.titlebar.hide(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    c.ontop = true
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("property::floating", function(c)
    if c.floating  then
        awful.titlebar.show(c)
        c.size_hints_honor = true
    else
        awful.titlebar.hide(c)
        c.size_hints_honor = false
    end

end)

tag.connect_signal("", function(t) end)

-- }}}


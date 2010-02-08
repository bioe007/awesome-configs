-- rc.lua for awesome-git'ish window manager
---------------------------
-- bioe007, perrydothargraveatgmaildotcom
--
print("Entered rc.lua: " .. os.time())
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
-- custom modules
require("markup")
require("shifty")
require("mocp")
require("calendar")
require("battery")
require("markup")
require("fs")
require("volume")
require("vicious")
require("revelation")
print("Modules loaded: " .. os.time())

function tag_restore_defaults(t)
    -- {{{
    local t_defaults = shifty.config.tags[t.name] or shifty.config.defaults

    for k,v in pairs(t_defaults) do
        awful.tag.setproperty(t, k, v)
    end
end
-- }}}

function tag_move(t, scr)
    -- {{{
    local ts = t or awful.tag.selected()
    local screen_target = scr or awful.util.cycle(screen.count(), ts.screen + 1)

    shifty.set(ts, { screen = screen_target })
end
-- }}}

function tag_to_screen(t, scr)
    -- {{{
    local ts = t or awful.tag.selected()
    local screen_origin = ts.screen
    local screen_target = scr or awful.util.cycle(screen.count(), ts.screen + 1)

    awful.tag.history.restore(ts.screen,1)
    tag_move(ts, screen_target)

    -- never waste a screen
    if #(screen[screen_origin]:tags()) == 0 then
        for _, tag in pairs(screen[screen_target]:tags()) do
            if not tag.selected then
                tag_move(tag, screen_origin) 
                tag.selected = true
                break
            end
        end
    end

    awful.tag.viewonly(ts)
    mouse.screen = ts.screen
    if #ts:clients() > 0 then
        local c = ts:clients()[1]
        client.focus = c
    end

end
-- }}}

function workspace_next()
    for s=1,screen.count() do
        awful.tag.viewnext(screen[s])
    end
end

function workspace_prev()
    for s=1,screen.count() do
        awful.tag.viewprev(screen[s])
    end
end

function tagSearch(name)
    -- {{{
  for s = 1, screen.count() do
    t = shifty.name2tag(name,s)
    if t ~= nil then
        if t.screen ~= mouse.screen then
            awful.screen.focus(t.screen)
        end
      awful.tag.viewonly(t)
      return true
    end
  end
  return false
end
-- }}}

-- {{{ wip
function tagScreenless()
    local allTags = {}
    local curTag = awful.tag.selected()
    for s = 1, screen.count() do
        t = shifty.name2tag(name,s)
        if t ~= nil then
            awful.tag.viewonly(t)
            awful.screen.focus(awful.util.cycle(screen.count(),s+mouse.screen))
            return true
        end
    end
    return false
end
-- }}}

-- Called externally and just pops to or merges with my active vim server when 
-- new files are dumped to it. (vim-start.sh) 
-- though it could easily be used with any tag by passing a different 'name'
-- parameter
function tagPop(name)
    -- {{{ tagPop() 
    for s = 1, screen.count() do
        t = shifty.name2tag(name,s)
        if t ~= nil then
            if t.screen == awful.tag.selected().screen then
                t.selected = true
            else
                awful.tag.viewonly(t)
                awful.screen.focus(t.screen)
            end
        end
    end
end
-- }}}

settings   = dofile(awful.util.getdir("config") .."/settings.lua")
widgets    = dofile(awful.util.getdir("config") .. "/widgets.lua")
globalkeys = dofile(awful.util.getdir("config") .. "/keys.lua")

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

--{{{ clientkeys
clientkeys = awful.util.table.join(
    awful.key({ settings.modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ settings.modkey, "Shift"   }, "c", function (c) c:kill()                         end),
    awful.key({ settings.modkey, "Shift"   }, "0", function (c) c.sticky = not c.sticky          end),
    awful.key({ settings.modkey, "Mod1" }, "space",function(c)
        awful.client.floating.toggle(c)
        if awful.client.floating.get(c) then
            awful.placement.centered(c)
            client.focus = c
            client.focus:raise()
        else
            awful.client.setslave(c)
        end
    end),
    awful.key({ settings.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ settings.modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ settings.modkey, "Mod1"    }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ settings.modkey, "Control"}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
            c:raise()
        end)
    )
-- }}}

-- Set keys
root.keys(globalkeys)

shifty.config.clientkeys = clientkeys
shifty.taglist = widgets.taglist
shifty.init()

-- {{{ signals
client.add_signal("focus", function (c)

    c.border_color = beautiful.border_focus

    if settings.opacity[c.class] then 
       c.opacity = settings.opacity[c.class].focus
    else
        c.opacity = settings.opacity.default.focus or 1
    end
    c:raise()
end) 

-- Hook function to execute when unfocusing a client.
client.add_signal("unfocus", function (c)

    c.border_color = beautiful.border_normal

    if settings.opacity[c.class] then 
        c.opacity = settings.opacity[c.class].unfocus
    else
        c.opacity = settings.opacity.default.unfocus or 0.7
    end
end)
-- }}}

-- vim:set ft=lua tw=80 fdm=marker ts=4 sw=4 et sta ai sti: --

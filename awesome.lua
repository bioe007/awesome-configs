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

-- {{{ tag run or raise
function tagSearch(name)
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

-- {{{ tagPop() 
-- Called externally and just pops to or merges with my active vim server when 
-- new files are dumped to it. (vim-start.sh) 
-- though it could easily be used with any tag by passing a different 'name'
-- parameter
function tagPop(name)
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
    awful.key({ settings.modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ settings.modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ settings.modkey, "Shift"   }, "0",      function (c) c.sticky=not c.sticky            end),
    awful.key({ settings.modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ settings.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ settings.modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ settings.modkey, "Mod1"    }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ settings.modkey, "Control"}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
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

-- vim:set filetype=lua textwidth=120 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

--! @file   menu.lua
--
-- @brief Some menus for awesome wm.
--
-- @author  Perry Hargrave
-- @date    2011-10-25
--

local ipairs = ipairs
local pairs = pairs
local string = string
local table = table

local awful = require('awful')
local capi = {
  client = client,
  tag = tag,
  screen = screen,
}
local shifty = require('shifty')
local tb = require('toolbox')

module('menu')


local function gen_tags_menu(menu, t)
    if not menu then
        menu = {}
    end
    menu.items = {}
    menu.items = {
        {
            (t.selected and "Hide") or "Merge",
            function() t.selected = not t.selected end
        },
        {
            "Rename",
            function() shifty.rename(t) end
        },
        {
            "Restore",
            function() tb.tag.restore_defaults(t) end
        },
        {
            "Delete",
            function() shifty.del(t) end
        },
    }

    num_screens = capi.screen.count()
    if num_screens > 1 then
        -- decide to show 'move next' only or also prev screen
        next_screen = tb.screen.next(t.screen)
        table.insert(menu.items,
                     2,
                     {
                         "Move to screen " .. next_screen,
                         function() tb.tag.to_screen(t, next_screen) end
                     })

        if num_screens > 2 then
            prev_screen = tb.screen.prev(t.screen)
            table.insert(menu.items,
                         3,
                         {
                             "Move to screen " .. prev_screen,
                             function() tb.tag.to_screen(t, prev_screen) end
                         })
        end
    end

    local m = awful.menu.new(menu)
    m:show()
    return m
end

-- Helper creates the table of clients for menus
local function client_items(clients, func)
    local data = {}
    for _, c in pairs(clients) do
        data[#data + 1] = {
            tb.client.title(c),
            function() func(c) end,
            c.icon
        }
    end
    return data
end

local function tag_items_inner(c, s, func, add)
    local data = {}
    for i, t in ipairs(capi.screen[s]:tags()) do
        data[i] = {
            awful.util.escape(t.name) or "",
            function() func(t, c) end,
            t.icon
        }
    end

    local addf = function()
        t = shifty.add({screen = s})
        awful.tag.viewonly(t)
        awful.client.movetotag(t, c)
        capi.client.focus = c
        c:raise()
    end

    if add == true then
        table.insert(data, #data + 1, {"New tag", addf})
    end

    return data
end

local function tag_items(c, func)
    local tgs_m = {}
    for s = 1, capi.screen.count() do
        skey = 'Screen '..s
        tgs_m[s] = {skey, tag_items_inner(c, s, func, true)}
    end
    return tgs_m
end

-- filter = {key=client property, value=equality value, max=number clients}
-- func = A function that accepts client
-- function clients(menu, c, filter, func)
local function gen_clients_menu(menu, c, filter, func)
    -- list of other clients
    local cls = {}
    if filter then
        cls = tb.client.filter(filter.key, filter.value, filter.max)
    else
        cls = capi.client.get()
    end

    local gen_f = function(c)
        if not c:isvisible() then
            awful.tag.viewmore(c:tags(), c.screen)
        end
        capi.client.focus = c
    end

    local cls_t = client_items(cls, func or gen_f)

    if not menu then
        menu = {width = 120}
    end
    menu.items = {
        {
            "⬛⬛⬛ " .. tb.client.title(c) .. " ⬛⬛⬛",
            function() end
        },
        {
            "✖ Close",
            function() c:kill() end
        },
        {
            (tb.client.is_maximized(c) and "ⴿ  Restore") or "ⴽ  Maximize",
            function() tb.client.maximize(c) end
        },
        {
            (c.minimized and "⇱  Restore") or "⇲  Minimize",
            function() c.minimized = not c.minimized end
        },
        {
            (c.sticky and "⚫  Un-Stick") or "⚪  Stick",
            function() c.sticky = not c.sticky end
        },
        {
            (c.ontop and "⤼  Offtop") or "⤽  Ontop",
            function()
                c.ontop = not c.ontop
                if c.ontop then c:raise() end
            end
        },
        {
            ((awful.client.floating.get(c) and "▦  Tile") or "☁  Float"),
            function() awful.client.floating.toggle(c) end
        },
        {"Move to tag", tag_items(c, awful.client.movetotag)},
        {"Toggle tags", tag_items_inner(c, c.screen, awful.client.toggletag)},
        {"Clients", cls_t}
    }
    local m = awful.menu.new(menu)
    m:show()
    return m
end

create = {
    tags = gen_tags_menu,
    clients = gen_clients_menu,
}


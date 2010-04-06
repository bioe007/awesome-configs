-- revelation.lua
-- This is a modification of the original awesome library that implemented
-- expose like behavior.
--
-- @author Perry Hargrave (aka bioe007)
--          perry)dot(hargrave)at(gmail.com
-- awesome v3.4-20-g8e02306 (Closing In)
--
-- original file information:
-- @author Espen Wiborg &lt;espenhw@grumblesmurf.org&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Espen Wiborg, Julien Danjou
--
-- USE:
-- 1. save this file as $HOME/.config/awesome/revelation.lua
-- 2. put near the top of your rc.lua
--          require("revelation")
-- 3. make a global keybinding for revelation in your rc.lua:
--          awful.key({ modkey }, "e",  revelation.revelation)
-- 4. reload rc.lua and try the keybinding. It should bring all clients to the
-- current tag and set the layout to fair.  You can focus clients with
-- cursor(arrow) or 'hjkl' keys then press <enter> to select or <escape> to
-- abort
--
-- NOTES: I have dumbed this down to simply merge all clients to the current tag
-- the class filter is of little use (to me?) but I could reimplement it
-- if anyone is interested
--
local math = math
local table = table
local pairs = pairs
local button = button
local awful = awful
local capi =
{
  tag = tag,
  client = client,
  keygrabber = keygrabber,
  mouse = mouse,
  screen = screen
}
local print = print
--- Exposé implementation
module("revelation")

--{{{ clients
-- a now unused filter to grab clients based on their class
--
-- @param class the class string to find
-- @s the screen
function clients(class, s)
  local clients
  if class then
    clients = {}
    for k, c in pairs(capi.client.get(s)) do
      if c.class == class then
        table.insert(clients, c)
      end
    end
  else
    clients = capi.client.get(s)
  end
  return clients
end
--}}}

--{{{ selectfn
-- executed when user selects a client from expose view
--
-- @param restore function to reset the current tags view
function selectfn(restore)
  return function(c)
    restore()
    -- Pop to client tag
    awful.tag.viewonly(c:tags()[1], c.screen)
    -- Focus and raise
    capi.client.focus = c
    c:raise()
  end
end
--}}}

--{{{ keyboardhandler
-- Returns keyboardhandler.
-- Arrow keys and 'hjkl' move focus, Return selects, Escape cancels. Ignores
-- modifiers.
--
-- @param restore a function to call if the user presses escape
function keyboardhandler (restore)
  return function (mod, key, event)
    if event ~= "press" then return true end
    -- translate vim-style home keys to directions
    if key == "j" or key == "k" or key == "h" or key == "l" then
      if key == "j" then
        key = "Down"
      elseif key == "k" then
        key = "Up"
      elseif key == "h" then
        key = "Left"
      elseif key == "l" then
        key = "Right"
      end
    end

    --
    if key == "Escape" then
      restore()
      return false
    elseif key == "Return" then
      selectfn(restore)(capi.client.focus)
      return false
    elseif key == "Left" or key == "Right" or
      key == "Up" or key == "Down" then
      awful.client.focus.bydirection(key:lower())
    end
    return true
  end
end
--}}}

--{{{ revelation
-- Implement Exposé (from Mac OS X).
-- @param class The class of clients to expose, or nil for all clients.
-- @param fn A binary function f(t, n) to set the layout for tag t for n
-- clients, or nil for the default layout.
-- @param s The screen to consider clients of, or nil for "current screen".
function revelation(class, fn, s)
  local scr = s or capi.mouse.screen
  local t = capi.screen[scr]:tags()[1]
  local oldlayout = awful.tag.getproperty( t, "layout" )

  awful.tag.viewmore( capi.screen[scr]:tags(), t.screen )
  awful.layout.set(awful.layout.suit.fair,t)

  local function restore()
    awful.layout.set(oldlayout,t)
    awful.tag.viewonly(t)

    capi.keygrabber.stop()
  end

  capi.keygrabber.run(keyboardhandler(restore))
end
--}}}

-- vim:set ft=lua fdm=marker ts=4 sw=4 et ai si: --

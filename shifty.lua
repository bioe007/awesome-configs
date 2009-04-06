--- Shifty: Dynamic tagging library for awesome3-git
-- @author koniu &lt;gkusnierz@gmail.com&gt;
--
-- http://awesome.naquadah.org/wiki/index.php?title=Shifty

-- this version of shifty has been modified by bioe007
-- (perry<dot>hargrave[at]gmail[dot]com)
--
-- TODO:
-- * init: if awesome reloads, some stray tags are initialized (eg urxvt ) but 
-- their properties are left blank
--
-- * fix multi-headed setups. i want one set of tags across all monitors, be
-- able to move across any of them on either monitor, combine them from either
-- monitor, etc etc.
--
-- * awful.tag history is stupid, deleted tags are not removed from history so
-- switching mod+esc after deleting takes to nil tag
--
-- package env

local type = type
local tag = tag
local ipairs = ipairs
local table = table
local client = client
local image = image
local hooks = hooks
local string = string
local widget = widget
local screen = screen
local button = button
local mouse = mouse
local capi = { hooks = hooks, client = client }
local beautiful = require("beautiful")
local awful = require("awful")
local pairs = pairs
local io = io
local tostring = tostring
local tonumber = tonumber
local wibox = wibox
local print = print
module("shifty")

index_cache = {}
config = {}
config.tags = {}
config.apps = {}
config.defaults = {}
config.guess_name = true
config.guess_position = true
config.remember_index = true
config.clientkeys = {}

--{{{ name2tag: matches string 'name' to return a tag object 
-- @param name : name of tag to find
-- @param scr : screen to look for tag on
-- @return the tag object, or nil
function name2tag(name, scr)
  local a, b = scr or 1, scr or screen.count()
  for s = a, b do
    for i, t in ipairs(screen[s]:tags()) do
      if name == t.name then
        return t 
      end 
    end
  end
end
--}}}

--{{{ tag2index: finds index of a tag object
-- @param scr : screen number to look for tag on
-- @param tag : the tag object to find
-- @return the index [or zero] or end of the list
function tag2index(scr, tag)
  local tags = screen[scr]:tags()
  for i = 1, #tags do
    if tags[i] == tag then
      return i
    end
  end
  return #tags+1 
end
--}}}

--{{{ rename
--@param tag: tag object to be renamed
--@param prefix: if any prefix is to be added
--@param no_selectall:
--@param initial: boolean if this is initial creation of tag
--
-- FIXME: promptbox is located incorrectly for scr == 2
function rename(tag, prefix, no_selectall, initial)
  local theme = beautiful.get()
  local t = tag or awful.tag.selected(mouse.screen)
  local scr = t.screen
  local bg = nil
  local fg = nil
  local text = prefix or t.name or ""
  local before = t.name

  if t == awful.tag.selected(scr) then 
    bg = theme.bg_focus or '#535d6c'
    fg = theme.fg_urgent or '#ffffff'
  else 
    bg = theme.bg_normal or '#222222'
    fg = theme.fg_urgent or '#ffffff'
  end
  text = '<span color="'..fg..'">'..text..'</span>'

  awful.prompt.run( { 
    fg_cursor = fg, bg_cursor = bg, ul_cursor = "single",
    prompt = tag2index(scr,t)..": ", selectall = not no_selectall,  },
    taglist[scr][tag2index(scr,t)*2],
    function (name) if name:len() > 0 then t.name = name; end end, 
    completion,
    awful.util.getdir("cache") .. "/history_tags", nil,
    function () if initial and t.name == before then del(t)
      else awful.tag.setproperty(t,"initial",true); set(t) end
      awful.hooks.user.call("tags", scr)
    end
    )
end
--}}}

--{{{ send: moves client to tag[idx]
-- maybe this isn't needed here in shifty? 
-- @param idx the tag number to send a client to
function send(idx)
  local scr = client.focus.screen or mouse.screen
  local sel = awful.tag.selected(scr)
  local sel_idx = tag2index(scr,sel)
  local target = awful.util.cycle(#screen[scr]:tags(), sel_idx + idx)
  awful.tag.viewonly(screen[scr]:tags()[target])
  awful.client.movetotag(screen[scr]:tags()[target], client.focus)
end
--}}}

function send_next() send(1) end
function send_prev() send(-1) end

-- FIXME: both of these seem broken
function shift_next() set(awful.tag.selected(), { rel_index = 1 }) end
function shift_prev() set(awful.tag.selected(), { rel_index = -1 }) end

--{{{ pos2idx: translate shifty position to tag index
--@param pos: position (an integer)
--@param scr: screen number
function pos2idx(pos, scr)
  local v = 1
  if pos and scr then
    for i = #screen[scr]:tags() , 1, -1 do
      local t = screen[scr]:tags()[i]
      if awful.tag.getproperty(t,"position") and awful.tag.getproperty(t,"position") <= pos then 
        v = i + 1
        break 
      end
    end
  end
  return v
end
--}}}

--{{{ select : helper function chooses the first non-nil argument
--@param args - table of arguments
function select(args)
  for i, a in pairs(args) do
    if a ~= nil then
      return a
    end
  end
end
--}}}

--{{{ tagtoscr : move an entire tag to another screen
--
--@param scr : the screen to move tag to
--@param t : the tag to be moved [awful.tag.selected()]
--@return the tag
function tagtoscr(scr,t)
  if not scr or scr < 1 or scr > screen.count() then return end
  local otag = t or awful.tag.selected() 
  local oscr = otag.screen
  local rel_scr = oscr - scr
  local vargs = { screen = scr }

  set(otag,vargs)

  if #otag:clients() > 0 then
    for _ , c in ipairs(otag:clients()) do
      if not c.sticky then
        c.screen = scr
        c:tags( { otag } )
      end
    end
  end
  awful.hooks.user.call("tags",scr)

  awful.tag.history.restore(oscr)

  -- if this is a configured tag, then sort
  if awful.tag.getproperty(otag,"position") ~= nil then
    tsort(scr)
  end
  awful.tag.viewonly(otag)
  awful.screen.focus(rel_scr)
  return otag
end
---}}}

--{{{ set : set a tags properties
--@param t: the tag
--@param args : a table of optional (?) tag properties
--@return t - the tag object
function set(t, args)
  if not t then return end
  if not args then args = {} end
  local guessed_position = nil

  -- get the name and preset
  local name = args.name or t.name
  local preset = config.tags[name] or {}

  -- try to get position from then name
  if not (args.position or preset.position) and config.guess_position then
    local num = name:find('^[1-9]')
    if num then guessed_position = tonumber(name:sub(1,1)) end
  end

  -- set tag attributes screen and name are directly set
  t.screen = args.screen or preset.screen or t.screen or mouse.screen 
  t.name = name

  -- have to have a layout, or else change layout by idx fails later?
  layout = args.layout or preset.layout or config.defaults.layout or awful.layout.suit.tile

  -- configs or sane defaults
  mwfact  = args.mwfact or preset.mwfact or config.defaults.mwfact or t.mwfact or 0.55
  nmaster = args.nmaster or preset.nmaster or config.defaults.nmaster or t.nmaster or 1
  ncol    = args.ncol or preset.ncol or config.defaults.ncol or t.ncol or 1

  awful.tag.setproperty(t,"matched", select{ args.matched, awful.tag.getproperty(t,"matched") } )
  awful.tag.setproperty(t,"notext", select{ args.notext, preset.notext, awful.tag.getproperty(t,"notext"), config.defaults.notext })
  awful.tag.setproperty(t,"exclusive", select{ args.exclusive, preset.exclusive, awful.tag.getproperty(t,"exclusive"), config.defaults.exclusive })
  awful.tag.setproperty(t,"persist", select{ args.persist, preset.persist, awful.tag.getproperty(t,"persist"), config.defaults.persist })
  awful.tag.setproperty(t,"nopopup", select{ args.nopopup, preset.nopopup, awful.tag.getproperty(t,"nopopup"), config.defaults.nopopup })
  awful.tag.setproperty(t,"leave_kills", select{ args.leave_kills, preset.leave_kills, awful.tag.getproperty(t,"leave_kills"), config.defaults.leave_kills })
  awful.tag.setproperty(t,"solitary", select{ args.solitary, preset.solitary, awful.tag.getproperty(t,"solitary"), config.defaults.solitary })
  awful.tag.setproperty(t,"position", select{ args.position, preset.position, guessed_position, awful.tag.getproperty(t,"position" )})
  awful.tag.setproperty(t,"skip_taglist", select{ args.skip_taglist, preset.skip_taglist, awful.tag.getproperty(t,"skip_taglist") })
  awful.tag.setproperty(t,"icon", select{ args.icon and image(args.icon), preset.icon and image(preset.icon), awful.tag.getproperty(t,"icon"), config.defaults.icon and image(config.defaults.icon) })
  awful.layout.set(layout,t)
  awful.tag.setmwfact(mwfact,t)
  awful.tag.setnmaster(nmaster,t)
  awful.tag.setncol(ncol, t)

  -- calculate desired taglist index
  local index = args.index or preset.index or config.defaults.index
  local rel_index = args.rel_index or preset.rel_index or config.defaults.rel_index
  local sel = awful.tag.selected(scr)
  local sel_idx = (sel and tag2index(t.screen,sel)) or 0 --TODO: what happens with rel_idx if no tags selected
  local t_idx = tag2index(t.screen,t)
  local limit = (not t_idx and #screen[t.screen]:tags() + 1) or #screen[t.screen]:tags()
  local idx = nil

  if rel_index then
    idx = awful.util.cycle(limit, (t_idx or sel_idx) + rel_index)
  elseif index then
    idx = awful.util.cycle(limit, index)
  elseif awful.tag.getproperty(t,"position") then
    idx = pos2idx(awful.tag.getproperty(t,"position"), t.screen)
    if t_idx and t_idx < idx then idx = idx - 1 end
  elseif config.remember_index and index_cache[t.name] then
    idx = index_cache[t.name]
  elseif not t_idx then
    idx = #screen[t.screen]:tags() + 1
  end

  -- if tag already in the table, remove it
  if idx and t_idx then table.remove(screen[t.screen]:tags(), t_idx) end

  -- if we have an index, insert the notification
  if idx then
    index_cache[t.name] = idx
    table.insert(screen[t.screen]:tags(), idx, t)
  end

  -- refresh taglist and return
  awful.hooks.user.call("tags", t.screen)
  return t
end
--}}}

--{{{ tsort : to re-sort awesomes tags to follow shifty's config positions
--
--  @param scr : optional screen number [mouse.screen]
function tsort(scr)
  local scr = scr or mouse.screen
  local tags = screen[scr]:tags()

  local k = 1
  for i=1,#tags do
    ipos = awful.tag.getproperty(tags[i],"position")
    -- bail if this is not a configured tag?
    if ipos ~= nil then
      nextpos = awful.tag.getproperty(tags[i+1], "position")
      if nextpos ~= nil then
        if ipos > nextpos then
          k = 1
          newpos = awful.tag.getproperty(tags[i+k], "position")
          while newpos ~= nil and ipos > newpos and k <= #tags do
            k = k+1
            newpos = awful.tag.getproperty(tags[i+k], "position")
          end
          set(tags[i],{rel_index=k})
          tsort(scr)
        end
      end
    end
  end
end
--}}}

--{{{ add : adds a tag
--@param args: table of optional arguments
--
function add(args)
  if not args then args = {} end
  local scr = mouse.screen 
  -- check that args.scr is valid number
  if args.scr and (args.scr > 0) and (args.screen <= screen.count()) then 
    scr = args.scr 
  end
  local name = args.name or ( args.rename and args.rename .. "_" ) or "_" --FIXME: pretend prompt '_'

  -- initialize a new tag object and its data structure
  local t = tag( name )
  -- initial flag is used in set() so it must be initialized here
  awful.tag.setproperty(t,"initial", true)

  -- apply tag settings
  set(t, args)

  if config.tags[name] ~= nil then
    local spawn = config.tags[name].spawn or config.defaults.spawn or nil
  end
  local run = args.run or config.defaults.run
  if spawn and args.matched ~= true then awful.util.spawn(spawn, scr) end
  if run then run(t) end
  -- unless forbidden or if first tag on the screen, show the tag
  if not (awful.tag.getproperty(t,"nopopup") or args.noswitch) or #screen[scr]:tags() == 1 then awful.tag.viewonly(t) end

  -- get the name or rename
  if args.name then t.name = args.name
  elseif args.position then rename(t, args.position .. ":", true, true)
  else rename(t, "", nil, true)
  end

  -- if this is a configured tag, then sort
  if config.tags[name] ~= nil then
    tsort(scr)
  end
  return t
end
--}}}

--{{{ del : delete a tag
--@param tag : the tag to be deleted [current tag]
function del(tag)
  local scr = mouse.screen or 1
  local tags = screen[scr]:tags()
  local sel = awful.tag.selected(scr)
  local t = tag or sel
  local idx = tag2index(scr,t)

  -- should a tag ever be deleted if #tags[scr] < 1 ?
  if #tags > 1 then
    if #(t:clients()) > 0 then return end

    -- this is also checked in sweep, but where is better? 
    if not awful.tag.getproperty(t,"persist") then
      index_cache[t.name] = idx

      -- if the current tag is being deleted, move to a previous
      if t == sel and #tags > 1 then
        awful.tag.history.restore(scr)
        -- this is supposed to cycle if history is invalid?
        -- e.g. if many tags are deleted in a row
        if not awful.tag.selected(scr) then 
          awful.tag.viewonly(tags[awful.util.cycle(#tags, idx - 1)]) 
        end
      end

      t.screen = nil
      awful.hooks.user.call("tags", scr)
    end
    if client.focus then client.focus:raise() end
  end
end
--}}}

--{{{ match : handles app->tag matching, a replacement for the manage hook in
--            rc.lua
--@param c : client to be matched
function match(c)
  local target_tag, target_screen, target, nopopup, intrusive = nil
  -- type is the only field we're guaranteed
  local typ = c.type
  local cls = c.class or ""
  local inst = c.instance or ""
  local role = c.role or ""
  local name = c.name or ""

  -- If we are not managing this application at startup, move it to the screen where the mouse is.
  -- We only do it for filtered windows (i.e. no dock, etc).
  if not startup and awful.client.focus.filter(c) then
    c.screen = mouse.screen
  end

  -- Add mouse bindings
  c:buttons({
    button({ }, 1, function (c) client.focus = c; c:raise() end),
    button({ modkey }, 1, function (c) awful.mouse.client.move() end),
    button({ modkey }, 3, awful.mouse.client.resize ),
  })
  c.border_color = beautiful.border_normal
  -- Set key bindings
  c:keys(config.clientkeys)


  -- try matching client to config.apps unless its a dialog, then don't do
  -- anything
  if typ ~= "dialog" then
    for i, a in ipairs(config.apps) do
      if a.match then
        for k, w in ipairs(a.match) do
          if cls:find(w) or inst:find(w) or name:find(w) or role:find(w) or typ:find(w) then
            if a.tag and config.tags[a.tag] and config.tags[a.tag].screen then
              target_screen = config.tags[a.tag].screen
            elseif a.screen then
              target_screen = a.screen
            else
              target_screen = c.screen
            end
            if a.tag then
              target_tag = a.tag
            end
            if a.float then awful.client.floating.set( c, true) end
            if a.geometry ~=nil then c:fullgeometry(a.geometry) end
            if a.slave ~=nil and a.slave then awful.client.setslave(c) end
            if a.nopopup ~=nil then nopopup = true end
            if a.intrusive ~=nil then intrusive = true end
            if a.fullscreen ~=nil then c.fullscreen = a.fullscreen end
            if a.honorsizehints ~=nil then c.size_hints_honor = a.honorsizehints end
          end
        end
      end
    end
  end

  -- set properties of floating clients
  if awful.client.floating.get(c) then

    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal
    if config.defaults.floatBars then       -- add a titlebar if requested in config.defaults
      awful.titlebar.add( c, { modkey = modkey } )
    end
    awful.placement.centered(c, c.transient_for)
    awful.placement.no_offscreen(c) -- this always seems to stick the client at 0,0 (incl titlebar)
  end

  -- if not matched or matches currently selected, see if we can leave at the current tag
  local sel = awful.tag.selected(c.screen)
  if #screen[c.screen]:tags() > 0 and (not target_tag or (sel and target_tag == sel.name)) then
    if typ == "dialog" or not (awful.tag.getproperty(sel,"exclusive") or awful.tag.getproperty(sel,"solitary")) or intrusive  then 
      client.focus = c
      c:raise()
      return
    end 
  end

  -- if still unmatched, try guessing the tag
  if not target_tag then
    if config.guess_name and cls then target_tag = cls:lower() else target_tag = "new" end
  end

  -- get/create target tag and move the client
  if target_tag then
    target = name2tag(target_tag, target_screen)
    if not target or (awful.tag.getproperty(target,"solitary") and #target:clients() > 0 and not intrusive) then
      target = add({ name = target_tag, noswitch = true, matched = true, screen = target_screen }) 
    end
    awful.client.movetotag(target, c)
  end
  if target_screen and c.screen ~= target_screen then c.screen = target_screen end

  -- if target different from current tag, switch unless nopopup
  if target and (not (awful.tag.getproperty(target,"nopopup") or nopopup) and target ~= sel) then
    awful.tag.viewonly(target)
  end

  -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
  client.focus = c
  c:raise()
end
--}}}

--{{{ sweep : hook function that marks tags as used, visited, deserted
--  also handles deleting used and empty tags 
function sweep()
  for s = 1, screen.count() do
    for i, t in ipairs(screen[s]:tags()) do
      if #t:clients() == 0 then
        if not awful.tag.getproperty(t,"persist") and awful.tag.getproperty(t,"used") then
          if awful.tag.getproperty(t,"deserted") or not awful.tag.getproperty(t,"leave_kills") then
            del(t)
          else
            if not t.selected and awful.tag.getproperty(t,"visited") then awful.tag.setproperty(t,"deserted", true) end
          end
        end
      else
        awful.tag.setproperty(t,"used",true)
      end
      if t.selected then awful.tag.setproperty(t,"visited",true) end
    end
  end
end
--}}}

--{{{ getpos : returns a tag to match position
--      * originally this function did a lot of client stuff, i think its
--      * better to leave what can be done by awful to be done by awful
--      *           -perry
-- @param pos : the index to find
-- @return v : the tag (found or created) at position == 'pos'
function getpos(pos)
  local v = nil
  local existing = {}
  local selected = nil
  local scr = mouse.screen or 1
  -- search for existing tag assigned to pos
  for i = 1, screen.count() do
    local s = awful.util.cycle(screen.count(), scr + i - 1)
    for j, t in ipairs(screen[s]:tags()) do
      if awful.tag.getproperty(t,"position") == pos then
        table.insert(existing, t)
        if t.selected and s == scr then selected = #existing end
      end
    end
  end
  if #existing > 0 then
    -- if makeing another of an existing tag, return the end of the list
    if selected then v = existing[awful.util.cycle(#existing, selected + 1)] else v = existing[1] end
  end
  if not v then
    -- search for preconf with 'pos' and create it
    for i, j in pairs(config.tags) do
      if j.position == pos then v = add({ name = i, position = pos, noswitch = not switch }) end
    end
  end
  if not v then
    -- not existing, not preconfigured
    v = add({ position = pos, rename = pos .. ':', no_selectall = true, noswitch = not switch })
  end
  return v
end
--}}}

--{{{ init : search shifty.config.tags for initial set of tags to open
function init()
  local numscr = screen.count()

  for i, j in pairs(config.tags) do
    local scr = j.screen or 1
    if j.init and ( scr <= numscr ) then
        add({ name = i, persist = true, screen = scr, layout = j.layout, mwfact = j.mwfact }) 
    end
  end

  -- try and prevent ugly awesome 'default' tag from appearing
  for s = 1,numscr do
    if #screen[s]:tags() < 1 then
      add({ name = "1:shifty", persist = true, screen = s, layout = (config.defaults.layout or awful.util.suit.tile)})
    end
  end
end
--}}}

--{{{ count : utility function returns the index of a table element
--FIXME: this is currently used only in remove_dup, so is it really necessary?
function count(table, element)
  local v = 0
  for i, e in pairs(table) do
    if element == e then v = v + 1 end
  end
  return v
end
--}}}

--{{{ remove_dup : used by shifty.completion when more than one
--tag at a position exists
function remove_dup(table)
  local v = {}
  for i, entry in ipairs(table) do
    if count(v, entry) == 0 then v[#v+ 1] = entry end
  end
  return v
end
--}}}

--{{{ completion : prompt completion
--
function completion(cmd, cur_pos, ncomp)
  local list = {}

  -- gather names from config.tags
  for n, p in pairs(config.tags) do table.insert(list, n) end

  -- gather names from config.apps
  for i, p in pairs(config.apps) do
    if p.tag then table.insert(list, p.tag) end
  end

  -- gather names from existing tags, starting with the current screen
  for i = 1, screen.count() do
    local tags = screen[i]:tags()
    local s = awful.util.cycle(screen.count(), mouse.screen + i - 1)
    for j, t in pairs(tags) do table.insert(list, t.name) end
  end

  -- gather names from history
  f = io.open(awful.util.getdir("cache") .. "/history_tags")
  for name in f:lines() do table.insert(list, name) end
  f:close()

  -- do nothing if it's pointless
  if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
    return cmd, cur_pos
  elseif #cmd == 0 then
    return cmd, cur_pos
  end

  -- find matching indices
  local matches = {}
  for i, j in ipairs(list) do
    if list[i]:find("^" .. cmd:sub(1, cur_pos)) then
      table.insert(matches, list[i])
    end
  end

  -- no matches
  if #matches == 0 then return cmd, cur_pos end

  -- remove duplicates
  matches = remove_dup(matches)

  -- cycle
  while ncomp > #matches do ncomp = ncomp - #matches end

  -- return match and position
  return matches[ncomp], cur_pos
end
--}}}

awful.hooks.tags.register(sweep)
awful.hooks.arrange.register(sweep)
awful.hooks.clients.register(sweep)
awful.hooks.manage.register(match)

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80

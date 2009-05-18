--- Shifty: Dynamic tagging library for awesome3-git
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @author bioe007 &lt;perry.hargrave@gmail.com&gt;
--
-- http://awesome.naquadah.org/wiki/index.php?title=Shifty

-- package env
local type = type
local tag = tag
local ipairs = ipairs
local table = table
local client = client
local image = image
local string = string
local screen = screen
local button = button
local mouse = mouse
local beautiful = require("beautiful")
local awful = require("awful")
local pairs = pairs
local io = io
local tonumber = tonumber
local wibox = wibox
local root = root
local dbg= dbg
module("shifty")

config = {}
config.tags = {}
config.apps = {}
config.defaults = {}
config.guess_name = true
config.guess_position = true
config.remember_index = true
config.default_name = "new"
config.clientkeys = {}
config.globalkeys = nil
config.prompt_sources = { "config_tags", "config_apps", "existing", "history" }
config.prompt_matches = { "^", ":", "" }

local matchp = ""
local index_cache = {}
for i = 1, screen.count() do index_cache[i] = {} end

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
  for i,t in ipairs(screen[scr]:tags()) do
    if t == tag then return i end
  end
end
--}}}

--{{{ rename
--@param tag: tag object to be renamed
--@param prefix: if any prefix is to be added
--@param no_selectall:
function rename(tag, prefix, no_selectall)
  local theme = beautiful.get()
  local t = tag or awful.tag.selected(mouse.screen)
  local scr = t.screen
  local bg = nil
  local fg = nil
  local text = prefix or t.name
  local before = t.name

  if t == awful.tag.selected(scr) then 
    bg = theme.bg_focus or '#535d6c'
    fg = theme.fg_urgent or '#ffffff'
  else 
    bg = theme.bg_normal or '#222222'
    fg = theme.fg_urgent or '#ffffff'
  end

  awful.prompt.run( { 
    fg_cursor = fg, bg_cursor = bg, ul_cursor = "single",
    text = text, selectall = not no_selectall, prompt = " "  },
    taglist[scr][tag2index(scr,t)*2],
    function (name) if name:len() > 0 then t.name = name; end end, 
    completion,
    awful.util.getdir("cache") .. "/history_tags", nil,
    function ()
      if t.name == before then
        if awful.tag.getproperty(t, "initial") then del(t) end
      else
        awful.tag.setproperty(t, "initial", true)
        set(t)
      end
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

function send_next() send(1) end
function send_prev() send(-1) end
--}}}

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
function tagtoscr(scr, t)
  -- break if called with an invalid screen number
  if not scr or scr < 1 or scr > screen.count() then return end
  -- tag to move
  local otag = t or awful.tag.selected() 

  -- set screen and then reset tag to order properly
  if #otag:clients() > 0 then
    for _ , c in ipairs(otag:clients()) do
      if not c.sticky then
        c.screen = scr
        c:tags( { otag } )
      else
        awful.client.toggletag(otag,c)
      end
    end
  end
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

  -- set the name
  t.name = args.name or t.name

  -- attempt to load preset on initial run
  local preset = (awful.tag.getproperty(t, "initial") and config.tags[t.name]) or {}

  -- pick screen and get its tag table
  local scr = args.screen or (not t.screen and preset.screen) or t.screen or mouse.screen
  if t.screen and scr ~= t.screen then
    tagtoscr(scr, t)
    t.screen = nil
  end
  local tags = screen[scr]:tags()

  -- try to guess position from the name
  local guessed_position = nil
  if not (args.position or preset.position) and config.guess_position then
    local num = t.name:find('^[1-9]')
    if num then guessed_position = tonumber(t.name:sub(1,1)) end
  end

  -- select from args, preset, getproperty, config.defaults.configs or defaults
  local props = {
    layout = select{ args.layout, preset.layout, awful.tag.getproperty(t,"layout"), config.defaults.layout, awful.layout.suit.tile },
    mwfact = select{ args.mwfact, preset.mwfact, awful.tag.getproperty(t,"mwfact"), config.defaults.mwfact, 0.55 },
    nmaster = select{ args.nmaster, preset.nmaster, awful.tag.getproperty(t,"nmaster"), config.defaults.nmaster, 1 },
    ncol = select{ args.ncol, preset.ncol, awful.tag.getproperty(t,"ncol"), config.defaults.ncol, 1 },
    matched = select{ args.matched, awful.tag.getproperty(t,"matched") },
    exclusive = select{ args.exclusive, preset.exclusive, awful.tag.getproperty(t,"exclusive"), config.defaults.exclusive },
    persist = select{ args.persist, preset.persist, awful.tag.getproperty(t,"persist"), config.defaults.persist },
    nopopup = select{ args.nopopup, preset.nopopup, awful.tag.getproperty(t,"nopopup"), config.defaults.nopopup },
    leave_kills = select{ args.leave_kills, preset.leave_kills, awful.tag.getproperty(t,"leave_kills"), config.defaults.leave_kills },
    solitary = select{ args.solitary, preset.solitary, awful.tag.getproperty(t,"solitary"), config.defaults.solitary },
    position = select{ args.position, preset.position, guessed_position, awful.tag.getproperty(t,"position" ) },
    icon = select{ args.icon and image(args.icon), preset.icon and image(preset.icon), awful.tag.getproperty(t,"icon"), config.defaults.icon and image(config.defaults.icon) },
    icon_only = select{ args.icon_only, preset.icon_only, awful.tag.getproperty(t,"icon_only"), config.defaults.icon_only },
    sweep_delay = select{ args.sweep_delay, preset.sweep_delay, awful.tag.getproperty(t,"sweep_delay"), config.defaults.sweep_delay },
  }

  -- calculate desired taglist index
  local index = args.index or preset.index or config.defaults.index
  local rel_index = args.rel_index or preset.rel_index or config.defaults.rel_index
  local sel = awful.tag.selected(scr)
  local sel_idx = (sel and tag2index(scr,sel)) or 0 --TODO: what happens with rel_idx if no tags selected
  local t_idx = tag2index(scr,t)
  local limit = (not t_idx and #tags + 1) or #tags
  local idx = nil

  if rel_index then
    idx = awful.util.cycle(limit, (t_idx or sel_idx) + rel_index)
  elseif index then
    idx = awful.util.cycle(limit, index)
  elseif props.position then
    idx = pos2idx(props.position, scr)
    if t_idx and t_idx < idx then idx = idx - 1 end
  elseif config.remember_index and index_cache[scr][t.name] then
    idx = index_cache[scr][t.name]
  elseif not t_idx then
    idx = #tags + 1
  end

  -- if we have a new index, remove from old index and insert
  if idx then
    if t_idx then table.remove(tags, t_idx) end
    table.insert(tags, idx, t)
    index_cache[scr][t.name] = idx
  end

  -- set tag properties and push the new tag table
  for prop, val in pairs(props) do awful.tag.setproperty(t, prop, val) end
  screen[scr]:tags(tags)

  -- execute run/spawn
  if awful.tag.getproperty(t, "initial") then
    local spawn = args.spawn or preset.spawn or config.defaults.spawn
    local run = args.run or preset.run or config.defaults.run
    if spawn and args.matched ~= true then awful.util.spawn(spawn, true, scr) end
    if run then run(t) end
    awful.tag.setproperty(t, "initial", nil)
  end

  return t
end
--}}}

--{{{ add : adds a tag
--@param args: table of optional arguments
--
function add(args)
  if not args then args = {} end
  local name = args.name or " "

  -- initialize a new tag object and its data structure
  local t = tag( name )

  -- tell set() that this is the first time
  awful.tag.setproperty(t, "initial", true)

  -- apply tag settings
  set(t, args)

  -- unless forbidden or if first tag on the screen, show the tag
  if not (awful.tag.getproperty(t,"nopopup") or args.noswitch) or #screen[t.screen]:tags() == 1 then awful.tag.viewonly(t) end

  -- get the name or rename
  if args.name then
    t.name = args.name
  else
    -- FIXME: hack to delay rename for un-named tags for tackling taglist refresh
    --        which disabled prompt from being rendered until input
    awful.tag.setproperty(t, "initial", true)
    if args.position then
      f = function() rename(t, args.rename, true); awful.hooks.timer.unregister(f) end
    else
      f = function() rename(t); awful.hooks.timer.unregister(f) end
    end
    awful.hooks.timer.register(0.01, f)
  end

  return t
end
--}}}

--{{{ del : delete a tag
--@param tag : the tag to be deleted [current tag]
function del(tag)
  local scr = (tag and tag.screen) or mouse.screen or 1
  local tags = screen[scr]:tags()
  local sel = awful.tag.selected(scr)
  local t = tag or sel
  local idx = tag2index(scr,t)

  -- return if tag not empty
  if #(t:clients()) > 0 then return end

  -- store index for later
  index_cache[scr][t.name] = idx

  -- remove tag
  t.screen = nil

  -- if the current tag is being deleted, restore from history
  if t == sel and #tags > 1 then
    awful.tag.history.restore(scr)
    -- this is supposed to cycle if history is invalid?
    -- e.g. if many tags are deleted in a row
    if not awful.tag.selected(scr) then
      awful.tag.viewonly(tags[awful.util.cycle(#tags, idx - 1)])
    end
  end

  -- FIXME: what is this for??
  if client.focus then client.focus:raise() end
end
--}}}

--{{{ match : handles app->tag matching, a replacement for the manage hook in
--            rc.lua
--@param c : client to be matched
function match(c, startup)
  local target_tag, target, nopopup, intrusive, nofocus, run, slave = nil
  local typ = c.type
  local cls = c.class
  local inst = c.instance
  local role = c.role
  local name = c.name
  local keys = config.clientkeys or c:keys() or {}
  local target_screen = mouse.screen

  c.border_color = beautiful.border_normal
  c.border_width = beautiful.border_width

  -- try matching client to config.apps
  for i, a in ipairs(config.apps) do
    if a.match then
      for k, w in ipairs(a.match) do
        if
          (cls and cls:find(w)) or
          (inst and inst:find(w)) or
          (name and name:find(w)) or
          (role and role:find(w)) or
          (typ and typ:find(w))
        then
          if a.screen then target_screen = a.screen end
          if a.tag then target_tag = a.tag end
          if a.float ~= nil then awful.client.floating.set(c, a.float) end
          if a.geometry ~=nil then c:geometry({ x = a.geometry[1], y = a.geometry[2], width = a.geometry[3], height = a.geometry[4] }) end
          if a.slave ~=nil then slave = a.slave end
          if a.nopopup ~=nil then nopopup = a.nopopup end
          if a.intrusive ~=nil then intrusive = a.intrusive end
          if a.fullscreen ~=nil then c.fullscreen = a.fullscreen end
          if a.honorsizehints ~=nil then c.size_hints_honor = a.honorsizehints end
          if a.kill ~=nil then c:kill(); return end
          if a.ontop ~= nil then c.ontop = a.ontop end
          if a.above ~= nil then c.above = a.above end
          if a.below ~= nil then c.below = a.below end
          if a.buttons ~= nil then c:buttons(a.buttons) end
          if a.nofocus ~= nil then nofocus = a.nofocus end
          if a.keys ~= nil then keys = awful.util.table.join(keys, a.keys) end
          if a.hide ~= nil then c.hide = a.hide end
          if a.minimized ~= nil then c.minimized = a.minimized end
          if a.dockable ~= nil then awful.client.dockable.set(c, a.dockable) end
          if a.urgent ~= nil then c.urgent = a.urgent end
          if a.opacity ~= nil then c.opacity = a.opacity end
          if a.titlebar ~= nil then awful.titlebar.add(c, { modkey = modkey }) end
          if a.run ~= nil then run = a.run end
          if a.sticky ~= nil then c.sticky = a.sticky end
        end
      end
    end
  end

  -- set key bindings
  c:keys(keys)

  -- set properties of floating clients
  if awful.client.floating.get(c) then
    if config.defaults.floatBars then       -- add a titlebar if requested in config.defaults
      awful.titlebar.add( c, { modkey = modkey } )
    end
    awful.placement.centered(c, c.transient_for)
    awful.placement.no_offscreen(c) -- this always seems to stick the client at 0,0 (incl titlebar)
  end

  -- select target tag if unset
  local sel = awful.tag.selected(target_screen)
  if not target_tag then
    if c.transient_for then
      target = c.transient_for:tags()[1] --FIXME: should make target_tag a table
    elseif sel and (not (awful.tag.getproperty(sel,"exclusive") or awful.tag.getproperty(sel,"solitary")) or intrusive) then
      target = sel
    elseif config.guess_name and cls then
      target_tag = cls:lower()
    else
      target_tag = config.default_name
    end
  end

  -- translate target name to tag object, creating one if needed
  if target_tag and not target then
    target = name2tag(target_tag, target_screen) or name2tag(target_tag)
    if not target or (awful.tag.getproperty(target,"solitary") and #target:clients() > 0 and not intrusive) then
      target = add({ name = target_tag, noswitch = true, matched = true }) 
    end
  end

  -- set client's screen/tag if needed
  if target then target_screen = target.screen end
  if target_screen and c.screen ~= target_screen then c.screen = target_screen end
  if target then c:tags({ target }) end
  if slave then awful.client.setslave(c) end

  -- if target different from current tag, switch or highlight
  if target and target ~= sel then
    if not(awful.tag.getproperty(target,"nopopup") or nopopup) then
      awful.tag.viewonly(target)
    elseif not startup then
      c.urgent = true
    end
  end

  -- focus and raise accordingly or lower if supressed
  if not (nofocus or c.hide or c.minimized) then
    if (awful.tag.getproperty(target,"nopopup") or nopopup) and (target and target ~= sel) then
      awful.client.focus.history.add(c)
    else
      client.focus = c
    end
    c:raise()
  else
    c:lower()
  end

  -- execute run function if specified
  if run then run(c, target) end
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
            local delay = awful.tag.getproperty(t,"sweep_delay")
            if delay then
              --FIXME: global f, what if more than one at a time is being swept
              f = function() del(t); awful.hooks.timer.unregister(f) end
              awful.hooks.timer.register(delay, f)
            else
              del(t)
            end
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
  local list = {
    config_tags = {},
    config_apps = {},
    existing = {},
    history = {}
  }

  -- gather names from config.tags
  for n, p in pairs(config.tags) do table.insert(list.config_tags, n) end

  -- gather names from config.apps
  for i, p in pairs(config.apps) do
    if p.tag then table.insert(list.config_apps, p.tag) end
  end

  -- gather names from existing tags, starting with the current screen
  for i = 1, screen.count() do
    local tags = screen[i]:tags()
    local s = awful.util.cycle(screen.count(), mouse.screen + i - 1)
    for j, t in pairs(tags) do table.insert(list.existing, t.name) end
  end

  -- gather names from history
  f = io.open(awful.util.getdir("cache") .. "/history_tags")
  for name in f:lines() do table.insert(list.history, name) end
  f:close()

  -- if empty, match all
  if #cmd == 0 or cmd == " " then cmd = "" end

  -- match all up to the cursor if moved or no matchphrase
  if matchp == "" or cmd:sub(cur_pos, cur_pos+#matchp) ~= matchp then
    matchp = cmd:sub(1, cur_pos)
  end

  -- find matching commands
  local matches = {}
  for i, src in ipairs(config.prompt_sources) do
    local source = list[src]
    for j, matcher in ipairs(config.prompt_matches) do
      for k, name in ipairs(source) do
        if name:find(matcher .. matchp) then
          table.insert(matches, name)
        end
      end
    end
  end

  -- no matches
  if #matches == 0 then return cmd, cur_pos end

  -- remove duplicates
  matches = remove_dup(matches)

  -- cycle
  while ncomp > #matches do ncomp = ncomp - #matches end

  -- put cursor at the end of the matched phrase
  if #matches == 1 then
    cur_pos = #matches[ncomp] + 1
  else
    cur_pos = matches[ncomp]:find(matchp) + #matchp
  end

  -- return match and position
  return matches[ncomp], cur_pos
end
--}}}

-- {{{ tagkeys : hook function that sets keybindings per tag
function tagkeys(s)
  -- FIXME: hack to fix slow focus, we do this first
  if not client.focus then
    local c = awful.client.focus.history.get(s, 0)
    if c then client.focus = c; c:raise() end
  end

  if not config.globalkeys then return end
  local sel = awful.tag.selected(s)
  root.keys(awful.util.table.join(config.globalkeys, sel and config.tags[sel.name] and config.tags[sel.name].keys or {}))
end
-- }}}

awful.hooks.manage.unregister(awful.tag.withcurrent)
awful.hooks.tags.register(sweep)
awful.hooks.arrange.register(sweep)
awful.hooks.arrange.register(tagkeys)
awful.hooks.clients.register(sweep)
awful.hooks.manage.register(match)

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80


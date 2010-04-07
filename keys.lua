
-- some helper functins to make keybindings a bit more readable (?)
function key_gen(args, ...)
    --{{{ try to make keybindings look less messy
    -- vargs[1] must be a function address suitable for awful.key()
    local vargs = {...}
    if args == nil or vargs == nil then return end

    local key = args.key
    nvargs = #vargs

    -- sanity
    if type(key) ~= 'string' then return end
    if vargs ~= nil and type(vargs[1]) ~= 'function' then
        print("key_gen: rec'vd non fx arg", vargs[1])
        return
    end

    local modkeys = {}
    if args.modifiers ~= nil and type(args.modifiers) ~= 'table' then
        print("key_gen: rec'vd non table modifiers", args.modifiers)
        return
    else
        modkeys = args.modifiers or {}
    end

    if args.use_modkey == nil or args.use_modkey == true then
        table.insert(modkeys, settings.modkey)
    end

    local f = table.remove(vargs, 1)
    if nvargs > 1 then
        return awful.key.new(modkeys, key, function()
            f(unpack(vargs)) end)
    else
        return awful.key(modkeys, key, f)
    end

end
--}}}


function key_app(args, ...)
    --{{{ applications that are started by util.spawn...
    -- i add "Mod1" to application starting
    local vargs = {...}
    local modkeys = args.modfiers or {}
    table.insert(modkeys, "Mod1")
    args.modifiers = modkeys

    return key_gen(args, awful.util.spawn, unpack(vargs), false)

end
-- }}}


globalkeys = awful.util.table.join(
    --{{{ global keys
    key_gen({key = "t", modifiers = {"Control", "Shift"}},
        keygrabber.run, tag_strmatch),
    key_gen({modifiers = {"Control"}, key = "r"}, awesome.restart),
    key_gen({modifiers = {"Shift"}, key = "q"}, awesome.quit),
    key_gen({key = "space"}, awful.tag.viewnext),
    key_gen({key = "space", modifiers = {"Shift"}}, awful.tag.viewprev),
    key_gen({key = "space", modifiers = {"Control"}}, workspace_next),
    key_gen({key = "space", modifiers = {"Control", "Shift"}}, workspace_prev),
    key_gen({key = "j"}, awful.client.focus.byidx, 1),
    key_gen({key = "k"}, awful.client.focus.byidx, -1),
    key_gen({key = "e"}, revelation.revelation),

    --{{{ shiftycentric
    key_gen({key = "Escape"}, awful.tag.history.restore),
    key_gen({key = "n"}, shifty.send_next),
    key_gen({key = "n", modifiers = {"Shift"}}, shifty.send_prev),
    key_gen({key = "n", modifiers = {"Control"}}, tag_to_screen),
    key_gen({key = "r", modifiers = {"Shift"}}, shifty.rename),
    key_gen({key = "d", modifiers = {"Shift"}}, shifty.del),
    key_gen({key = "a", modifiers = {"Shift"}}, shifty.add),
    --}}}

    --{{{ Layout manipulation
    key_gen({key = "j", modifiers = {"Shift"}}, awful.client.swap.byidx, 1),
    key_gen({key = "k", modifiers = {"Shift"}}, awful.client.swap.byidx, -1),
    key_gen({key = "s"}, awful.screen.focus_relative, 1),
    key_gen({key = "s", modifiers = {"Shift"}}, awful.client.movetoscreen),
    key_gen({key = "u"}, awful.client.urgent.jumpto),
    key_gen({key = "Tab"}, function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    --}}}

    --{{{ APPLICATIONS
    key_gen({key = "Return"}, function()
        awful.util.spawn(settings.apps.terminal, false) end),
    key_app({key="f"}, settings.apps.filemgr),
    key_app({key="c"}, "galculator"),
    key_app({modifiers = {"Shift"}, key = "g"}, "gimp"),
    key_app({key = "v"}, "/home/perry/.bin/vim-start.sh"),

    -- run or raise type behavior but with benefits of shifty
    key_gen({key = "w"}, function()
        if not tagSearch("web") then
            awful.util.spawn(settings.apps.browser)
        end
    end),
    key_gen({key = "m"}, function()
        if not tagSearch("mail") then
            awful.util.spawn(settings.apps.mail)
        end
    end),
    key_gen({modifiers = {"Mod1", "Shift"}, key = "v"}, function()
        if not tagSearch("vbx") then
            awful.util.spawn('VBoxSDL -vm xp2')
        end
    end),
    key_gen({key = "g"}, function()
        if not tagSearch("dz") then
            awful.util.spawn('gschem')
        end
    end),
    key_gen({key = "p"}, function()
        if not tagSearch("dz") then
            awful.util.spawn('pcb')
        end
    end),
    --}}}

    -- {{{- MEDIA
    -- music player
    key_gen({key = "p"}, mocp.play, "PLAY"),
    key_gen({key = "Down"}, mocp.play, "FWD"),
    key_gen({key = "Up"}, mocp.play, "REV"),
    key_gen({key = "XF86AudioPlay", use_modkey = false}, mocp.play, "PLAY"),
    key_gen({key = "XF86AudioPrev", use_modkey = false}, mocp.play, "REV"),
    key_gen({key = "XF86AudioNext", use_modkey = false}, mocp.play, "FWD"),
    key_gen({key = "XF86AudioStop", use_modkey = false}, mocp.play, "STOP"),
    key_gen({key = "XF86AudioRaiseVolume", use_modkey = false}, volume.vol,
        "up", "5"),
    key_gen({key = "XF86AudioLowerVolume", use_modkey = false}, volume.vol,
        "down", "5"),
    key_gen({key = "XF86AudioMute", use_modkey = false}, volume.vol ),
    --}}}

    --{{{ Clients
    key_gen({key = "q"}, awful.client.incwfact, 0.03),
    key_gen({key = "a"}, awful.client.incwfact, -0.03),
    key_gen({key = "l"}, awful.tag.incmwfact, 0.03),
    key_gen({key = "h"}, awful.tag.incmwfact, -0.03),
    key_gen({key = "h", modifiers = {"Shift"}}, awful.tag.incnmaster, 1),
    key_gen({key = "l", modifiers = {"Shift"}}, awful.tag.incnmaster, -1),
    key_gen({key = "h", modifiers = {"Control"}}, awful.tag.incncol, 1),
    key_gen({key = "l", modifiers = {"Control"}}, awful.tag.incncol, -1),
    key_gen({key ="l", modifiers = {"Mod1"}}, awful.layout.inc,
            settings.layouts, 1),
    key_gen({key = "l", modifiers = {"Mod1", "Shift"}}, awful.layout.inc,
            settings.layouts, -1),

    -- Prompt
    key_gen({key = "F1"}, function() widgets.promptbox[mouse.screen]:run() end),
    key_gen({key = "F2"}, function()
        widgets.promptbox[mouse.screen]:run(nil, nil, function(args)
            cmd = "urxvt -name man -e zsh -c \'man "
            cmd = cmd .. unpack(args) .. "\'"
            print("MANKB::::::::::::::: ",cmd)
            awfult.util.spawn_with_shell(cmd)
        end) end),
    --}}}

    -- {{{- POWER
    key_app({key = "h"}, 'sudo pm-hibernate'),
    key_app({key = "r"}, 'sudo reboot'),
    key_gen({key = "s", modifiers = {"Mod1"}}, function()
        awful.util.spawn('slock',false)
        os.execute('sudo pm-suspend')
    end),
    --}}}

    -- monitors
    key_app({key = "F4"}, '/home/perry/.bin/stupid.sh --soyo'),
    key_app({key = "F5"}, '/home/perry/.bin/stupid.sh --sync --pos left-of'),
    key_app({key = "F6"}, '/home/perry/.bin/stupid.sh --off')
)
--}}}

for i = 1, 9 do
    --{{{ bind the numeric keys to 'normal' awesome keybindings
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({settings.modkey}, i, function()
            awful.tag.viewonly(shifty.getpos(i))
        end),

        awful.key({settings.modkey, "Control"}, i, function()
            this_screen = awful.tag.selected().screen
            t = shifty.getpos(i, this_screen)
            t.selected = not t.selected
        end),

        awful.key({settings.modkey, "Shift"}, i, function()
            if client.focus then
                local c = client.focus
                slave = not (client.focus ==
                                awful.client.getmaster(mouse.screen))
                t = shifty.getpos(i)
                awful.client.movetotag(t,c)
                awful.tag.viewonly(t)
                if slave then awful.client.setslave(c) end
            end
        end)
    )
end
--}}}

return globalkeys

-- vim:set ft=lua fdm=marker ts=4 sw=4 et ai si: --

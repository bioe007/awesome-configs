-- --stolen from http://www.markurashi.de/dotfiles/awesome/rc.lua

-- failsafe mode
-- if the current config fail, load the default rc.lua

require("awful")
require("naughty")

confdir = awful.util.getdir("config")
local rc, err = loadfile(confdir .. "/awesome.lua");
if rc then
    rc, err = pcall(rc);
    if rc then
        return;
    end
end

dofile("/etc/xdg/awesome/rc.lua");

for s = 1,screen.count() do
    mypromptbox[s].text = awful.util.escape(err:match("[^\n]*"));
end

naughty.notify{text="Awesome crashed during startup on " ..
                os.date("%d%/%m/%Y %T:\n\n")
                .. err .. "\n", timeout = 0}



-- vim:set ft=lua fdm=marker ts=4 sw=4 et ai si: --

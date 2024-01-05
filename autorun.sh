#!/usr/bin/env bash
#

function run {
    if ! prgrep $1 ; then
        $@&
    fi
}

xrandr --output DP-4 --mode 3440x1440 --rate 75.05
xrandr --output DP-0 --rotate left --left-of DP-4 --output DP-4 --primary
nvidia-settings --assign CurrentMetamode="DP-4: 3440x1440_75 +1440+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}, DP-0: 2560x1440 +0+0 {rotation=left, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"


sleep 1
run "/usr/bin/nitrogen --restore"
run "/usr/bin/playerctld"
run "/usr/bin/blueman-applet"
run "/usr/bin/slack -u"
run "/usr/bin/brave"
run "/usr/bin/youtube-music"

# kdeconnect-indicator is safe to restart, the export is to fix its colorscheme
export QT_QPA_PLATFORMTHEME=gtk2 && kdeconnect-indicator
#run "/usr/bin/redshift -t 6500:5800"

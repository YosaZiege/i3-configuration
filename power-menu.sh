#!/usr/bin/env bash 

#Power menu using rofi 
# Triggered by polybar click or keybind 
options="lock\nlogout\nsuspend\nreboot\nshutdown"

chosen=$(echo -e "$options" | rofi -dmenu -p " power" \ 
-theme ~/.config/rofi/power-menu.rasi \
-no-custom)

case $chosen in 
	lock)
	 	i3lock -c 2e3440
		;;
	logout)
		i3-msg exit
		;;
	suspend)
		systemctl suspend
		;;
	reboot)
		systemctl reboot
		;;
	shutdown)
		systemctl poweroff
		;;
esac

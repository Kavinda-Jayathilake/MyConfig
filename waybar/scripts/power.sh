#!/bin/bash

choice=$(printf "⏻ Shutdown\n Reboot\n Suspend\n󰒲 Hibernate\n Lock\n󰍃 Logout" | wofi --dmenu --width 300 --height 260)

case "$choice" in
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
  *Suspend) systemctl suspend ;;
  *Hibernate) systemctl hibernate ;;
  *Lock) loginctl lock-session ;;
  *Logout) hyprctl dispatch exit ;;
esac


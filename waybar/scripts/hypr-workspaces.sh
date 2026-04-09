#!/bin/bash
hyprctl workspaces -j | jq -r '.[] | .name' | while read ws; do
    echo "{\"text\":\"$ws\",\"tooltip\":\"Switch to $ws\",\"on-click\":\"hyprctl dispatch workspace $ws\"}"
done


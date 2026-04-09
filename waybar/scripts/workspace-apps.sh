#!/bin/bash

# Get current workspace ID
CURRENT=$(hyprctl activeworkspace -j | jq -r '.id')

# Get clients with their workspace and class
clients=$(hyprctl clients -j | jq -r '.[] | " \(.workspace.id) \(.class)"')

# Build a list of classes per workspace
declare -A ws_windows
while read -r ws_id class; do
    if [[ -n "$class" ]]; then
        ws_windows["$ws_id"]+="$class "
    fi
done <<< "$clients"

# Icon mapping using case statement for reliability
get_icon() {
    local cls="$1"
    case "$cls" in
        kitty) echo " " ;;
        firefox) echo " " ;;
        thunar) echo " " ;;
        mpv) echo " " ;;
        org.pwmt.zathura) echo " " ;;
        code|Code) echo " " ;;
        discord) echo " " ;;
        spotify) echo " " ;;
        obs) echo " " ;;
        zoom) echo " " ;;
        *) echo "${cls:0:1}" ;;
    esac
}

# Get unique classes for current workspace
output_text=">>>  "
if [[ -n "${ws_windows[$CURRENT]}" ]]; then
    classes=$(echo "${ws_windows[$CURRENT]}" | tr ' ' '\n' | sort -u)
    for cls in $classes; do
        icon=$(get_icon "$cls")
        output_text+="$icon "
    done
fi

output_text=$(echo "$output_text" | sed 's/ $//')
if [[ -z "$output_text" ]]; then
    output_text="$CURRENT"
else
    output_text="$CURRENT  $output_text"
fi

# Build tooltip
tooltip=""
for ws_id in $(hyprctl workspaces -j | jq -r '.[].id'); do
    win_list=""
    if [[ -n "${ws_windows[$ws_id]}" ]]; then
        win_list=$(echo "${ws_windows[$ws_id]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    fi
    tooltip+="Workspace $ws_id: $win_list\n"
done

cat <<EOF
{"text": "$output_text", "tooltip": "$tooltip", "on-click": "hyprctl dispatch workspace $CURRENT"}
EOF

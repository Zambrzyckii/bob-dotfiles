#!/bin/bash

eth_status=$(nmcli -t -f TYPE,STATE device 2>/dev/null | grep "^ethernet:" | head -n1 | cut -d: -f2)
wifi_status=$(nmcli -t -f TYPE,STATE device 2>/dev/null | grep "^wifi:" | head -n1 | cut -d: -f2)

if [ "$eth_status" = "connected" ]; then
    net_icon="󰒢"
elif [ "$wifi_status" = "connected" ]; then
    net_icon=""
else
    net_icon="󰖪"
fi

bt=""

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bt="󰂲" 
    
    devices=$(echo -e 'devices\nquit' | bluetoothctl 2>/dev/null | grep "^Device" | awk '{print $2}')
    
    for mac in $devices; do
        if echo -e "info $mac\nquit" | bluetoothctl 2>/dev/null | grep -q "Connected: yes"; then
            bt="󰂱" 
            break
        fi
    done
fi

if [ -z "$bt" ]; then
    echo "$net_icon"
else
    echo "$net_icon $bt"
fi

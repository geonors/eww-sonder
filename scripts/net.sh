#!/usr/bin/env bash
# Measures download/upload in KB/s over 1 second on the default interface.
# Output: {"down":123,"up":45}

iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
[[ -z $iface ]] && { echo '{"down":0,"up":0}'; exit 0; }

read rx1 tx1 < <(awk -v i="$iface:" '$1==i {print $2, $10}' /proc/net/dev)
sleep 1
read rx2 tx2 < <(awk -v i="$iface:" '$1==i {print $2, $10}' /proc/net/dev)

down=$(( (rx2 - rx1) / 1024 ))
up=$(( (tx2 - tx1) / 1024 ))

printf '{"down":%d,"up":%d}\n' "$down" "$up"

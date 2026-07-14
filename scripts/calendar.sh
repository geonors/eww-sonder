#!/usr/bin/env bash
# Emits the current month as JSON for the eww calendar.
# Weeks start on Monday. For a Sunday start:
#   - change the two "+%u" lines below to "+%w"
#   - map Sunday: %w gives 0=Sun..6=Sat, so use (first_weekday) directly
#     and reorder the header in eww.yuck to "Sun Mon Tue Wed Thu Fri Sat".

year=$(date +%Y)
month=$(date +%m)
today=$(date +%-d)

days_in_month=$(date -d "$year-$month-01 +1 month -1 day" +%-d)
first_weekday=$(date -d "$year-$month-01" +%u)   # 1=Mon ... 7=Sun
month_name=$(date +%B)                             # English by default

weeks=""
week="["
col=1

# Empty cells before the 1st
while (( col < first_weekday )); do
    week+='{"d":"","t":false},'
    (( col++ ))
done

day=1
while (( day <= days_in_month )); do
    t=false
    (( day == today )) && t=true
    week+='{"d":"'"$day"'","t":'"$t"'},'
    (( col++ ))
    if (( col > 7 )); then
        weeks+="${week%,}],"
        week="["
        col=1
    fi
    (( day++ ))
done

# Empty cells after the last day
if [[ $week != "[" ]]; then
    while (( col <= 7 )); do
        week+='{"d":"","t":false},'
        (( col++ ))
    done
    weeks+="${week%,}],"
fi

printf '{"month":"%s","weeks":[%s]}\n' "$month_name" "${weeks%,}"

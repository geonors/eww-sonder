#!/usr/bin/env bash
# Fetches weather from Open-Meteo (free, no API key) as compact JSON for eww.
#
# >>> SET YOUR COORDINATES HERE <<<  (find yours at https://www.latlong.net/)
LAT="50.50" # Insert own location
LON="50.50"

url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}"
url+="&current=temperature_2m,relative_humidity_2m,weather_code"
url+="&daily=weather_code,temperature_2m_max,temperature_2m_min"
url+="&timezone=auto&forecast_days=5"
# Open-Meteo defaults to Celsius. For Fahrenheit, append:
#   &temperature_unit=fahrenheit

curl -sf --max-time 10 "$url" | jq -c '
  # WMO weather code -> Nerd Font icon (as \uXXXX so the glyphs survive as ASCII)
  def icon:
    if   . == 0            then "\ue30d"      # clear
    elif . <= 2            then "\ue302"      # partly cloudy
    elif . == 3            then "\ue312"      # overcast
    elif . <= 48           then "\ue313"      # fog
    elif . <= 57           then "\ue31b"      # drizzle
    elif . <= 67           then "\ue318"      # rain
    elif . <= 77           then "\ue31a"      # snow
    elif . <= 82           then "\ue319"      # rain showers
    elif . <= 86           then "\ue35e"      # snow showers
    else                        "\ue31d"      # thunderstorm
    end;

  {
    temp: (.current.temperature_2m | round),
    hum:  (.current.relative_humidity_2m | round),
    icon: (.current.weather_code | icon),
    days: [ range(0; (.daily.time | length)) as $i | {
      name: (if $i == 0 then "Today"
             else (.daily.time[$i] | strptime("%Y-%m-%d") | strftime("%a")) end),
      date: (.daily.time[$i] | strptime("%Y-%m-%d") | strftime("%b %-d")),
      max:  (.daily.temperature_2m_max[$i] | round),
      min:  (.daily.temperature_2m_min[$i] | round),
      icon: (.daily.weather_code[$i] | icon)
    } ]
  }
' || echo '{"temp":"--","hum":"--","icon":"","days":[]}'

#!/usr/bin/env bash
# Fetches weather from Open-Meteo (free, no API key) as compact JSON for eww.
#
# >>> SET YOUR COORDINATES HERE <<<  (find yours at https://www.latlong.net/)
LAT="51.5074"    # example: London
LON="-0.1278"

url="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}"
url+="&current=temperature_2m,relative_humidity_2m,weather_code"
url+="&daily=weather_code,temperature_2m_max,temperature_2m_min"
url+="&timezone=auto&forecast_days=5"
# Open-Meteo defaults to Celsius. For Fahrenheit, append:
#   &temperature_unit=fahrenheit

curl -sf --max-time 10 "$url" | jq -c '
  # WMO weather code -> Nerd Font icon
  def icon:
    if   . == 0            then ""      # clear
    elif . <= 2            then ""      # partly cloudy
    elif . == 3            then ""      # overcast
    elif . <= 48           then ""      # fog
    elif . <= 57           then ""      # drizzle
    elif . <= 67           then ""      # rain
    elif . <= 77           then ""      # snow
    elif . <= 82           then ""      # rain showers
    elif . <= 86           then ""      # snow showers
    else                        ""      # thunderstorm
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

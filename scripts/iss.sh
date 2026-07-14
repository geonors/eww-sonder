#!/usr/bin/env bash
# Fetches the ISS position from wheretheiss.at (free, no key) and projects it
# into the map's coordinate space (must match build_map.py: W=700, H=350).
# Output: {"x":..,"y":..,"lat":..,"lon":..,"alt":..,"vel":..}
# Note: this is the satellite's public position, not the user's location.

W=700
H=350

data=$(curl -sf --max-time 20 "https://api.wheretheiss.at/v1/satellites/25544") \
  || { echo '{"x":-99,"y":-99,"lat":"--","lon":"--","alt":"--","vel":"--"}'; exit 0; }

echo "$data" | jq -c --argjson W "$W" --argjson H "$H" '
  {
    x:   (((.longitude + 180) / 360 * $W) | floor),
    y:   (((90 - .latitude) / 180 * $H) | floor),
    lat: (.latitude  | . * 10 | round / 10),
    lon: (.longitude | . * 10 | round / 10),
    alt: (.altitude  | round),
    vel: (.velocity  | round)
  }
' || echo '{"x":-99,"y":-99,"lat":"--","lon":"--","alt":"--","vel":"--"}'

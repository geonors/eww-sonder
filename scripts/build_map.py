#!/usr/bin/env python3
"""Convert ne_110m_land.geojson into a minimalist equirectangular world-map SVG.
Run once to (re)generate assets/world.svg. The shipped map is already built;
only run this if you want to change colors or size.

    curl -sf -o /tmp/land.geojson \\
      https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_land.geojson
    python3 scripts/build_map.py /tmp/land.geojson assets/world.svg
"""
import json, sys

W, H = 700, 350           # must match the values in iss.sh
LAND = "#8fbc8f"          # muted green, matches the accent color
OPACITY = 0.30

def project(lon, lat):
    x = (lon + 180.0) / 360.0 * W
    y = (90.0 - lat) / 180.0 * H
    return x, y

def ring_to_path(ring):
    pts = [f"{project(lon,lat)[0]:.1f},{project(lon,lat)[1]:.1f}" for lon, lat in ring]
    return "M" + "L".join(pts) + "Z"

def main(src, dst):
    data = json.load(open(src))
    paths = []
    for feat in data["features"]:
        geom = feat["geometry"]
        polys = geom["coordinates"]
        if geom["type"] == "Polygon":
            polys = [polys]
        for poly in polys:
            for ring in poly:
                if len(ring) >= 3:
                    paths.append(ring_to_path(ring))
    d = "".join(paths)
    svg = (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
        f'width="{W}" height="{H}">'
        f'<path d="{d}" fill="{LAND}" fill-opacity="{OPACITY}" '
        f'stroke="{LAND}" stroke-opacity="0.5" stroke-width="0.4"/>'
        f'</svg>'
    )
    open(dst, "w").write(svg)
    print(f"wrote {dst} ({len(svg)} bytes, {len(paths)} rings)")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "/tmp/land.geojson",
         sys.argv[2] if len(sys.argv) > 2 else "world.svg")

# eww-sonder

A [Sonder](https://github.com/mpurses/Sonder)-inspired desktop overlay for
[eww](https://github.com/elkowar/eww) on Wayland — thin light typography with a
green accent, sitting on the background layer behind your windows.

Five widgets: a large clock with date, current weather + 5-day forecast
(Open-Meteo), a month calendar with today highlighted, system stats
(CPU / memory / GPU / network), and a live ISS tracker on a world map.

![screenshot](screenshot.png)

## Dependencies

- `eww` (Wayland build)
- `jq`, `curl` — weather + ISS data
- `librsvg` — so eww can render the SVG map (usually already present on GTK systems)
- A **Nerd Font** for the weather glyphs (e.g. `ttf-nerd-fonts-symbols`)
- A **thin sans-serif** font for the look — Lato, Montserrat, or Comfortaa.
  Edit `$font` at the top of `eww.scss` to match what you have.

On Arch:

```bash
paru -S eww jq curl librsvg ttf-lato ttf-nerd-fonts-symbols
```

## Install

```bash
git clone https://github.com/YOURNAME/eww-sonder.git
mkdir -p ~/.config/eww
cp -r eww-sonder/* ~/.config/eww/
chmod +x ~/.config/eww/scripts/*.sh
```

Then set your location for the weather: open `~/.config/eww/scripts/weather.sh`
and change `LAT` / `LON` near the top (find yours at https://www.latlong.net/).

Test it:

```bash
eww daemon
eww open-many clock weather calendar stats iss
eww logs        # if something doesn't show
```

## Autostart

### niri

Add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "eww" "daemon"
spawn-at-startup "eww" "open-many" "clock" "weather" "calendar" "stats" "iss"
```

Optional — make the widgets live inside the overview backdrop (visible when you
zoom out). Find eww's layer namespace with `niri msg layers`, then:

```kdl
layer-rule {
    match namespace="^gtk4-layer-shell$"
    place-within-backdrop true
}
```

### KDE Plasma 6 (Wayland)

eww's Wayland backend uses layer-shell, which Plasma 6 supports, so the widgets
render on the desktop the same way. Add a login script under
**System Settings → Autostart → Add → Login Script**, pointing at:

```bash
#!/bin/sh
eww daemon
eww open-many clock weather calendar stats iss
```

(X11 sessions are not supported by this config — use a Wayland session.)

## Customization

- **Location**: `LAT` / `LON` in `scripts/weather.sh`.
- **Units**: Open-Meteo defaults to Celsius; see the comment in `weather.sh`
  for Fahrenheit. Change `km/h` in `eww.yuck` if you prefer other ISS units.
- **Colors / font**: top of `eww.scss` (`$font`, `$accent`).
- **Positions**: the `:geometry` block in each `defwindow` in `eww.yuck`.
- **Week start**: Monday by default; see the comment in `scripts/calendar.sh`
  and reorder the header row in `eww.yuck` for a Sunday start.
- **Map**: `assets/world.svg` is pre-built. To recolor or resize, edit
  `scripts/build_map.py` and rerun it (see the header comment).

## Credits

- Layout inspired by [Sonder](https://github.com/mpurses/Sonder) (Rainmeter).
- Weather from [Open-Meteo](https://open-meteo.com/).
- ISS position from [wheretheiss.at](https://wheretheiss.at/).
- Coastlines from [Natural Earth](https://www.naturalearthdata.com/).

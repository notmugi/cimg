# cimg

A tiny C image viewer for X11 and Wayland.

`cimg` opens an image (or a directory of images) and displays it. No
menus, no thumbnails, no album mode — just a window with the image in
it, sized to your screen, that you can pan, zoom, flip, rotate, tile,
fullscreen, animate, skim, and drag-drop files onto.

## Features

- **Native X11 and Wayland** via SDL3.
- **Broad format support**: PNG, JPEG, TIFF, BMP, PSD, single-frame WebP,
  AVIF, PNM, HDR, EXR, TGA, etc. via GEGL; **animated GIF / APNG /
  animated WebP / animated AVIF** via gdk-pixbuf; **SVG** via librsvg,
  re-rasterized on demand for crispness at any zoom.
- **Aspect-locked window** that snaps back to the image's aspect during
  interactive resize, with a graceful black-bar fallback for tilers.
  Toggleable at runtime.
- **Smooth pan and zoom** — wheel zoom anchors on whatever you pan to;
  drag pans 1:1 with the cursor.
- **Flip and rotate** with `h`, `v`, `k`, `l`.
- **Tile mode** — repeat the image outward in a grid, with optional
  mirrored tiling so seams match.
- **Pixel-art mode** — nearest-neighbor texture sampling toggle.
- **Animation control** — pause/resume, frame-by-frame skim.
- **Directory navigation** — launch with a directory and arrow-key
  through images with wrap-around.
- **Drag-and-drop** an image or a directory onto the window — even when
  the window is blank.
- **Info overlay** — toggle with `i` to see path, size, dimensions,
  format, animation status, current frame, and zoom level.
- **Lightweight**: pure C, single binary, no vendored libraries.

## Build

### Arch Linux

```sh
sudo pacman -S base-devel sdl3 gegl babl gdk-pixbuf2 librsvg cairo
git clone https://github.com/notmugi/cimg
cd cimg
make
```

For more animated format support, also install the matching gdk-pixbuf
loaders, e.g. `webp-pixbuf-loader`.

### Other distros

You need development headers for:

| Package      | pkg-config       | minimum |
|--------------|------------------|---------|
| SDL3         | `sdl3`           | 3.2     |
| GEGL         | `gegl-0.4`       | 0.4     |
| babl         | `babl-0.1`       | 0.1     |
| gdk-pixbuf 2 | `gdk-pixbuf-2.0` | 2.42    |

Then `make`. There is no autoconf or cmake step.

## Install

```sh
sudo make install                # to /usr/local
sudo make PREFIX=/usr install    # system-wide
make DESTDIR=/tmp/pkg install    # staged for packaging
```

`make install` lays down the binary, the manpage (`cimg.1`), the
`cimg.desktop` file, and (if present in `dist/icons/`) the icon files
under the freedesktop hicolor tree.

To uninstall:

```sh
sudo make uninstall
```

## Usage

```sh
cimg [OPTIONS] [IMAGE|DIRECTORY]
```

Open a single image:

```sh
cimg image.png
```

Open a directory and arrow-key through it:

```sh
cimg ~/Pictures/
```

Launch blank — drop something onto the window to begin:

```sh
cimg
```

Fullscreen, pixel-art mode, starting zoomed in:

```sh
cimg -f -n -z 2.0 sprite.png
```

Custom title and magenta letterbox:

```sh
cimg -t "Reference" --bg=#ff00ff ref.jpg
```

Force X11 backend (uses XWayland on a Wayland session):

```sh
cimg --x11 image.png
```

See `cimg --help` and `man cimg` for the full reference.

## Controls

| Key / Mouse       | Action                                                       |
|-------------------|--------------------------------------------------------------|
| `f`               | Toggle fullscreen                                            |
| `r`               | Hard reset: zoom, pan, flips, rotation, window size restored |
| `i`               | Toggle the info overlay (bottom-left)                        |
| `b`               | Toggle the keybind cheat-sheet (centered)                    |
| `n`               | Toggle nearest-neighbor sampling (pixel art)                 |
| `a`               | Toggle aspect-ratio locking                                  |
| `h`               | Flip horizontal                                              |
| `v`               | Flip vertical                                                |
| `k`               | Rotate 90° counter-clockwise                                 |
| `l`               | Rotate 90° clockwise                                         |
| `t`               | Toggle tile mode                                             |
| `w`               | Toggle mirrored tiling (when tile mode is on)                |
| `1`–`9`           | Tile radius (N tiles from center → (2N+1) × (2N+1) grid)     |
| `p`               | Pause/resume animation (animated images only)                |
| `-`               | Previous animation frame (skim; implicitly pauses)           |
| `=`               | Next animation frame                                         |
| `,` / `.`         | Previous / next image in directory (wraps)                   |
| `Home` / `End`    | First / last image in directory                              |
| `q` or `Esc`      | Quit                                                         |
| Mouse wheel       | Zoom in/out (anchors on the panned-to point)                 |
| Left-drag         | Pan (1:1 with cursor)                                        |
| Drop a file / dir | Open the dropped path                                        |

## CLI options

| Flag                  | Description                                       |
|-----------------------|---------------------------------------------------|
| `-h`, `--help`        | Show help and exit                                |
| `-v`, `--version`     | Show version and exit                             |
| `-f`, `--fullscreen`  | Start in fullscreen                               |
| `-n`, `--nearest`     | Start with nearest-neighbor sampling              |
| `--no-aspect-lock`    | Don't request aspect-lock from the WM             |
| `--x11`               | Force the X11 video backend (uses XWayland)       |
| `--wayland`           | Force the Wayland video backend                   |
| `-z`, `--zoom=N`      | Initial zoom factor (default `1.0`)               |
| `-t`, `--title=STR`   | Window title (default: filename)                  |
| `--app-id=STR`        | Wayland `app_id` / X11 `WM_CLASS` (default below) |
| `--bg=#RRGGBB`        | Background / letterbox color (default `#000000`)  |

The default `app_id` is `io.github.notmugi.cimg`. This is the string a
compositor matches against `cimg.desktop` to pick up the icon, so don't
override it unless you also install a matching `.desktop`.

## Behavior notes

- **`r` is partial reset**: it clears zoom, pan, flip, rotation, and
  restores the window to its initial fitted size. It preserves tile
  mode and aspect-lock state. It does NOT change pause/skim state — if
  you were paused on frame 4, you stay paused on frame 4.
- **Per-image reset**: when navigating with arrows or drag-dropping a
  new file, the view state (zoom, pan, flip, rotate, pause) resets.
  Tile mode is preserved across navigation.
- **Tile zoom** zooms the whole composition (each tile grows together),
  not individual tiles.
- **Skim builds a frame cache** on first use. For a typical 500x500x30-frame
  GIF that's ~30MB. The cache is freed when you navigate away.

## Icons and .desktop integration

### Wayland

Wayland's xdg-shell protocol has no `set_icon` request. Compositors
match the window's `app_id` against a `.desktop` file in the standard
freedesktop search paths. `make install` puts both `cimg.desktop` and
the icon files in place.

Icon files live under
`$PREFIX/share/icons/hicolor/scalable/apps/cimg.svg` (preferred) and
`$PREFIX/share/icons/hicolor/SIZExSIZE/apps/cimg.png` for the size
variants `16, 24, 32, 48, 64, 128, 256, 512`.

To supply your own icon, drop files into `dist/icons/` (see
`dist/icons/README.md`) and re-run `make install`.

### X11 / XWayland

On X11, `cimg` also pushes the icon directly via `SDL_SetWindowIcon`,
reading the same hicolor files at startup. This works even without a
`.desktop` file installed.

## Format support

| Family        | Animation | Loader     | Notes                       |
|---------------|-----------|------------|-----------------------------|
| PNG           | n/a       | GEGL       |                             |
| JPEG          | n/a       | GEGL       |                             |
| TIFF          | n/a       | GEGL       | first frame                 |
| BMP           | n/a       | GEGL       |                             |
| PSD           | n/a       | GEGL       | composited                  |
| TGA           | n/a       | GEGL       |                             |
| PNM / PPM     | n/a       | GEGL       |                             |
| HDR / EXR     | n/a       | GEGL       | tone-mapped to SDR display  |
| GIF           | yes       | gdk-pixbuf |                             |
| APNG          | yes       | gdk-pixbuf |                             |
| Animated WebP | yes       | gdk-pixbuf | needs webp loader pkg       |
| Animated AVIF | yes       | gdk-pixbuf | needs avif loader pkg       |
| Static WebP   | n/a       | GEGL       |                             |
| SVG           | n/a       | librsvg    | vector; crisp at every zoom |

## Architecture notes

- **SVG path** keeps a low-res whole-image "backdrop" rasterized once at
  load, drawn beneath a high-quality clipped raster produced by a
  dedicated worker thread on demand. A 60 ms debounce keeps fast wheel
  / pan from queuing redundant work. Flips, rotation, and tile mode are
  supported on SVGs: when any of those are active the worker switches
  from "raster only the visible portion" to "raster the whole image",
  so each rendered tile is sharp at the current per-tile scale.
- **Animated images** use SDL3's event-loop timeout to wake at each
  frame's delay; nothing polls. Pause/skim builds a lazy full-frame
  cache only when needed.
- **Pan + cursor tracking**: pan deltas are computed in window units,
  not renderer-pixel units, so the image moves 1:1 with the cursor on
  HiDPI displays.

## Dependencies (runtime)

- `libsdl3`
- `libgegl-0.4`, `libbabl-0.1` (and the loader modules GEGL needs for
  the formats you intend to view)
- `libgdk_pixbuf-2.0`
- `librsvg-2` and `cairo` (used for SVG rasterization)

Plus, optionally, gdk-pixbuf loader packages for additional animated
formats (`webp-pixbuf-loader`, AVIF loaders, …).

## License

MIT. See `LICENSE`.

## Contributing

Issues and pull requests welcome at
<https://github.com/notmugi/cimg>.

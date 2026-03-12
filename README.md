# 🎮 GB_HPC

**Play GameBoy games entirely in your terminal — on your HPC cluster.**

Ever been deep in an SSH session thinking *"I deserve a break, but I don't want to leave my terminal"*? Same. This repo packages a full GameBoy Advance emulator into a Singularity container that renders directly in your terminal. No X forwarding, no GUI, no VNC — just your game, your terminal, and your time management skills.

Worried your admin or others are going to flag you playing games? No worries. With a discreet name and run ID labeled "critical_analysis" you'll always *appear* ontop of things.

---

> ⚠️ **This repo is actively under development — check back for updates!**

---

## How It Works

The container runs [mGBA](https://mgba.io/) on a headless virtual display inside Singularity, captures frames, and streams them to your terminal using one of three rendering modes. Input is handled via raw terminal keypresses forwarded to the emulator through `xdotool`.

## 🖥️ Render Modes

Set the render mode with the `RENDER_MODE` environment variable:

| Mode | Command | Description |
|------|---------|-------------|
| **Kitty** | `RENDER_MODE=kitty` | Native pixel rendering via the Kitty graphics protocol. Best quality — actual pixels in your terminal. Auto-detected if you're using Kitty. |
| **ASCII** | `RENDER_MODE=ascii` | True ASCII art using `libcaca`. Renders with `@#%&*+=-:.` characters and ANSI colors. Looks cool as hell. |
| **Blocks** | `RENDER_MODE=blocks` | Unicode half-block characters via `chafa`. A middle ground between pixels and ASCII. |

If you don't set `RENDER_MODE`, it auto-detects: Kitty terminal → `kitty` mode, everything else → `ascii` mode.

### Recommended Terminals

For the best experience, use a terminal that supports modern rendering:

- **[Kitty](https://sw.kovidgoyal.net/kitty/)** — Best option. Supports native pixel rendering for the sharpest output.
- **[iTerm2](https://iterm2.com/)** — Great option on macOS. Works well with ASCII and block modes.
- **Any terminal** — ASCII mode works everywhere, even over basic SSH.

## 🕹️ Controls

| Key | Action |
|-----|--------|
| `W` / `A` / `S` / `D` | D-Pad (Up / Left / Down / Right) |
| `L` | A Button |
| `P` | B Button |
| `E` | Start |
| `Q` | Select |
| `O` / `K` | L / R Bumpers |
| `Ctrl+C` | Quit |

## 📁 Setup

### Folder Structure

Organize your ROMs like this — one folder per game:

```
~/games/
├── pkmon_frr/
│   ├── pokemon_fire_red_U.gba
│   ├── saves/
│   ├── states/
│   └── screenshots/
└── pkmon_emr/
    ├── pokemon_emerald.gba
    ├── saves/
    ├── states/
    └── screenshots/
```

The `saves/`, `states/`, and `screenshots/` directories are created automatically on first run.

### Build the Container

```bash
sudo singularity build ga_em.sif Singularity_gb_emulator
```

### Run

```bash
# Launch with game selection
./critical_analysis.sh /path/to/games

# Launch a specific game directly
./critical_analysis.sh /path/to/games pkmon_frr

# Force a specific render mode
RENDER_MODE=ascii ./critical_analysis.sh /path/to/games pkmon_frr
```

## 🔧 Requirements

- **Singularity** (or Apptainer) on your HPC
- **A GBA ROM** (`.gba` file)
- **A terminal** (Kitty recommended, but anything works)

Everything else (mGBA, chafa, libcaca, xdotool, Xvfb, ffmpeg, ImageMagick) is built into the container.

## 📦 What's in the Container

| Tool | Purpose |
|------|---------|
| [mGBA](https://mgba.io/) | GBA emulator (built from source) |
| [Xvfb](https://www.x.org/) | Virtual X display |
| [chafa](https://hpjansson.org/chafa/) | Unicode block rendering (built from source) |
| [libcaca](http://caca.zoy.org/wiki/libcaca) | ASCII art rendering |
| [xdotool](https://github.com/jordansissel/xdotool) | Input forwarding |
| [ffmpeg](https://ffmpeg.org/) | Frame capture |
| [ImageMagick](https://imagemagick.org/) | Image processing |

## Incase you were wondering...

This project provides a container build for running your own legally obtained ROMs. No ROMs are included.

---

*Built for researchers who need "critical analysis" breaks.* 🧬🎮

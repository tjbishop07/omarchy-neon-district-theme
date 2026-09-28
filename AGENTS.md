# Agent instructions

This repository is the Neon District Omarchy theme. Read INSTALL.md before installing.

## Installation task

- Requires Python 3 and an Omarchy desktop that supports `colors.toml` and the Quickshell shell.
- Run `python3 install.py --dry-run` to inspect the installation.
- If the user requested installation and activation, run `python3 install.py --apply`. Their request authorizes this normal reversible operation; do not ask again just because a config file changes.
- If the user only requested downloading or staging, use `python3 install.py` without `--apply`.
- The installer copies only theme assets, backs up an existing theme before changes, and leaves unrelated files alone. Repeated installation with identical assets makes no file changes.
- Do not use sudo. If your tool sandbox restricts user configuration writes, use its normal permission mechanism.
- Never modify `/usr/share/omarchy/`.
- Do not install the optional Starship prompt or Hyprland overrides unless they are within the user's requested scope. They are documented in README.md and require backing up existing user configuration.

## Weather widget

- Install only when requested: `python3 install.py --weather-widget`, then rescan and enable as described in README.md.
- Live weather sends configured coordinates to Open-Meteo; `allowNetwork` defaults to false. Obtain explicit authorization for that data transfer before enabling it.
- Bundle widget fonts and their licenses; use `WidgetTypography.qml` and `DigitalReadout.qml` for consistent labels and numbers. Do not change the global desktop font for a widget styling request.
- Never present fixture/sample readings as live weather. The README preview is labeled SAMPLE.
- The plugin reads the existing Omarchy weather location; do not invent or overwrite location settings.
- Run `python3 widgets/neon-district.weather/test_weather.py` after backend changes.

## System monitor

- Install when requested with `python3 install.py --system-widget`; enable `neon-district.system` after a plugin rescan. No network permission is needed: it only reads local counters.
- Run `python3 widgets/neon-district.system/test_monitor.py` after collector changes.
- The system plugin packages copies of the weather plugin's shared frame, `RainGlass.qml`, typography, digital readout, fonts, and licenses. Keep these assets byte-identical; Omarchy forbids symlinks inside plugin packages.
- For new plugins, finish copying and validating before enabling them. Avoid overlapping file-triggered hot reloads with a shell restart, given the observed Quickshell reload crash.

## Verification

After activation, run `omarchy theme current` and confirm `Neon District`. Run `hyprctl configerrors`; report any errors rather than claiming success. Check the current background symlink resolves to an installed wallpaper. Do not lock the user's session to test styling.

## Editing this repository

- `colors.toml` is the base palette; `shell.toml` styles shell surfaces and the lock screen.
- `backgrounds/` contains the actual wallpapers; `preview.png` and `assets/` are documentation illustrations, not screenshots.
- `extras/` contains optional user configuration and image-generation prompts.
- `widgets/` contains optional Quickshell desktop plugins. Keep `ChamferFrame.qml` reusable and use clearly labeled sample data for preview images.
- Keep generated runtime editor/terminal configs out of the repository; Omarchy generates them from the palette.
- Use standard-library Python for the installer; it needs no pip dependencies or network access.
- Preserve other user changes. Run `git diff --check` before committing.
- Do not change repository visibility, publish a release, or send messages to others without user authorization.

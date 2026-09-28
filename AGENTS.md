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

## Verification

After activation, run `omarchy theme current` and confirm `Neon District`. Run `hyprctl configerrors`; report any errors rather than claiming success. Check the current background symlink resolves to an installed wallpaper. Do not lock the user's session to test styling.

## Editing this repository

- `colors.toml` is the base palette; `shell.toml` styles shell surfaces and the lock screen.
- `backgrounds/` contains the actual wallpapers; `preview.png` and `assets/` are documentation illustrations, not screenshots.
- `extras/` contains optional user configuration and image-generation prompts.
- Keep generated runtime editor/terminal configs out of the repository; Omarchy generates them from the palette.
- Use standard-library Python for the installer; it needs no pip dependencies or network access.
- Preserve other user changes. Run `git diff --check` before committing.
- Do not change repository visibility, publish a release, or send messages to others without user authorization.

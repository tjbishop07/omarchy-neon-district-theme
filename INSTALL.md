# Installing Neon District

## Quick start for humans and agents

Prerequisites: Python 3 and a running Omarchy desktop with `colors.toml` and Quickshell support. Clone or download the complete repository first. A private repository requires GitHub access; the installer itself does not access the network.

From the repository directory:

```bash
python3 install.py --dry-run
python3 install.py --apply
omarchy theme current
hyprctl configerrors
```

Expected results: current theme `Neon District`, no Hyprland configuration errors. Wallpaper selection is handled by Omarchy; cycle with `omarchy theme bg next`.

## Installer behavior

- No flags: copy theme assets into `~/.config/omarchy/themes/neon-district` without activating.
- `--dry-run`: show the planned file changes and optional activation; make no changes.
- `--weather-widget`: also copy the optional desktop weather plugin. Enabling it and authorizing weather requests are separate steps documented in README.md.
- `--apply`: copy assets and run `omarchy theme set neon-district`.
- `--config-dir PATH`: use a different configuration root for staging or testing. Cannot be combined with activation outside `~/.config`.
- Existing installations are backed up under `~/.config/omarchy/theme-backups/` before changes. Unchanged installations are not backed up again.
- No root privileges, package installation, shell profile edits, or automatic optional-extras activation.

The installer only manages the four root theme configuration files and PNG wallpapers in `backgrounds/`. It does not delete unrelated or older files.

## Optional extras and rollback

See [README.md](README.md) for Starship prompt and theme-specific Hyprland effects. These are separate choices because they modify user configuration outside the theme directory.

Record `omarchy theme current` before switching if you want to restore it later. To return to that theme, run `omarchy theme set <previous-theme>`. If restoring an earlier Neon District installation, copy its saved files from the printed backup location into the theme directory and reapply it.

If activation fails, the copied files remain installed. Resolve the reported desktop/session problem and rerun `omarchy theme set neon-district`.

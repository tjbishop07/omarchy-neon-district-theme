#!/usr/bin/env python3
"""Install Neon District's theme assets; optional desktop activation."""

import argparse
from datetime import datetime
import filecmp
from pathlib import Path
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Show changes without writing files")
    parser.add_argument("--apply", action="store_true", help="Activate the installed theme using Omarchy")
    parser.add_argument("--config-dir", type=Path, default=Path.home() / ".config",
                        help="Configuration root (default: ~/.config)")
    args = parser.parse_args()
    source = Path(__file__).resolve().parent
    config = args.config_dir.expanduser().resolve()
    target = config / "omarchy/themes/neon-district"
    if args.apply and config != (Path.home() / ".config").resolve():
        parser.error("--apply requires the default ~/.config destination")
    if args.apply and not args.dry_run and shutil.which("omarchy") is None:
        parser.error("omarchy is not available; omit --apply to install files only")

    files = [Path(name) for name in ("colors.toml", "shell.toml", "icons.theme", "keyboard.rgb")]
    files += sorted(p.relative_to(source) for p in (source / "backgrounds").glob("*.png"))
    if len(files) <= 4 or any(not (source / p).is_file() for p in files):
        parser.error("Theme assets are missing; run from a complete repository checkout")
    # Refuse redirection of a managed asset outside the installation directory.
    for path in [target, target / "backgrounds"] + [target / p for p in files]:
        if path.is_symlink():
            parser.error(f"Destination is a symlink; review it before installing: {path}")
    changed = [p for p in files if not (target / p).is_file()
               or not filecmp.cmp(source / p, target / p, shallow=False)]
    for relative in changed:
        print(f"Install {target / relative}")
    if not changed:
        print(f"Already up to date: {target}")
    if changed and not args.dry_run:
        if target.exists():
            stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
            backup = config / "omarchy/theme-backups" / f"neon-district-{stamp}"
            shutil.copytree(target, backup, symlinks=True)
            print(f"Backup: {backup}")
        for relative in changed:
            dest = target / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source / relative, dest)
    if args.apply:
        print("Apply: omarchy theme set neon-district")
        if not args.dry_run:
            subprocess.run(["omarchy", "theme", "set", "neon-district"], check=True)
    elif not args.dry_run:
        print("Activate with: omarchy theme set neon-district")


if __name__ == "__main__":
    main()

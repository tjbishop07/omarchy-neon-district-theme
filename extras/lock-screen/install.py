#!/usr/bin/env python3
"""Install the optional Lock Explorer rain design without changing auth code."""
from pathlib import Path
from datetime import datetime
import shutil

source = Path(__file__).resolve().parent
config = Path.home() / '.config/omarchy'
plugin = config / 'plugins/io.github.sirjul1337.lock-explorer/designs'
if not (plugin / 'DesignBase.qml').is_file():
    raise SystemExit('Install Lock Screen Explorer before installing this design.')
target = config / 'lock-designs'
files = [(source / 'NeonDistrictRain.qml', target / 'NeonDistrictRain.qml'),
         (source / 'RainGlass.qml', target / 'neon-district/RainGlass.qml')]
backup = config / 'theme-backups' / ('lock-rain-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
for src, dst in files:
    if any(p.is_symlink() for p in [dst, *dst.parents]):
        raise SystemExit(f'Refusing symlink destination: {dst}')
    if dst.exists() and dst.read_bytes() == src.read_bytes():
        continue
    if dst.exists():
        saved = backup / dst.relative_to(target)
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(dst, saved)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    print(f'Installed {dst}')
print('Rescan: omarchy-shell lock rescanDesigns')
print('Activate: omarchy-shell lock setDesign my-neondistrictrain')

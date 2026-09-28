#!/usr/bin/env python3
"""Read local Linux counters. No network requests, external packages or root needed."""
import argparse
import json
import os
from pathlib import Path
import time

GIB = 1024 ** 3


def cpu_counters(text):
    values = [int(x) for x in text.splitlines()[0].split()[1:9]]
    if len(values) < 5:
        raise ValueError("Incomplete CPU counters")
    # guest and guest_nice are already included in user and nice: omit them.
    return sum(values), values[3] + values[4]


def cpu_percent(previous, current):
    if previous is None:
        return None
    total = current[0] - previous[0]
    idle = current[1] - previous[1]
    if total <= 0 or idle < 0:
        return None
    return round(max(0, min(100, 100 * (total - idle) / total)), 1)


def memory(text):
    values = {line.split(':')[0]: int(line.split()[1]) * 1024
              for line in text.splitlines() if ':' in line}
    total = values['MemTotal']
    available = values.get('MemAvailable', values.get('MemFree', 0))
    used = max(0, min(total, total - available))
    return {'memoryPercent': round(100 * used / total, 1),
            'memoryUsedGiB': round(used / GIB, 1), 'memoryTotalGiB': round(total / GIB, 1)}


def network_counters(text):
    result = {}
    for line in text.splitlines()[2:]:
        name, _, data = line.partition(':')
        values = data.split()
        if name.strip() != 'lo' and len(values) >= 9:
            result[name.strip()] = (int(values[0]), int(values[8]))
    return result


def default_interface(routes, counters, ipv6_routes=''):
    candidates = []
    for line in routes.splitlines()[1:]:
        row = line.split()
        if len(row) > 7 and row[1] == '00000000' and row[7] == '00000000' and int(row[3], 16) & 1 and row[0] in counters:
            candidates.append((int(row[6]), row[0]))
    if candidates:
        return min(candidates)[1]
    for line in ipv6_routes.splitlines():
        row = line.split()
        if len(row) >= 10 and row[0] == '0' * 32 and row[1] == '00' and row[9] in counters and int(row[8], 16) & 1:
            candidates.append((int(row[5], 16), row[9]))
    return min(candidates)[1] if candidates else ''


def rates(previous, current, elapsed):
    if previous is None or current is None or elapsed <= 0 or any(c < p for p, c in zip(previous, current)):
        return None, None
    return tuple(round((c - p) / elapsed, 1) for p, c in zip(previous, current))


class Sampler:
    def __init__(self, disk_path, interface=''):
        self.disk_path = disk_path
        self.interface = interface
        self.previous_cpu = None
        self.previous_net = {}
        self.previous_time = None
        self.previous_interface = ''

    def read(self):
        now = time.monotonic()
        cpu = cpu_counters(Path('/proc/stat').read_text())
        net = network_counters(Path('/proc/net/dev').read_text())
        name = self.interface or default_interface(Path('/proc/net/route').read_text(), net,
                                                    Path('/proc/net/ipv6_route').read_text())
        if not name and not self.interface:
            # No default route: show an active physical interface if available.
            name = next((n for n in sorted(net) if (Path('/sys/class/net') / n / 'device').exists()
                         and (Path('/sys/class/net') / n / 'operstate').read_text().strip() == 'up'), '')
        elapsed = now - self.previous_time if self.previous_time is not None else 0
        old_net = self.previous_net.get(name) if name == self.previous_interface else None
        rx, tx = rates(old_net, net.get(name), elapsed)
        disk = os.statvfs(self.disk_path)
        used = (disk.f_blocks - disk.f_bfree) * disk.f_frsize
        available = disk.f_bavail * disk.f_frsize
        result = {'ok': True, 'cpu': cpu_percent(self.previous_cpu, cpu),
                  **memory(Path('/proc/meminfo').read_text()),
                  'diskPercent': round(100 * used / (used + available), 1) if used + available else 0,
                  'diskUsedGiB': round(used / GIB, 1),
                  'diskTotalGiB': round(disk.f_blocks * disk.f_frsize / GIB, 1),
                  'rxBps': rx, 'txBps': tx, 'interface': name if name in net else '',
                  'uptime': int(float(Path('/proc/uptime').read_text().split()[0])), 'updated': time.time()}
        self.previous_cpu, self.previous_net, self.previous_time, self.previous_interface = cpu, net, now, name
        return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk-path', default=str(Path.home()))
    parser.add_argument('--interface', default='')
    parser.add_argument('--once', action='store_true')
    args = parser.parse_args()
    sampler = Sampler(args.disk_path, args.interface)
    try:
        while True:
            try:
                data = sampler.read()
            except (OSError, ValueError, KeyError, ZeroDivisionError):
                data = {'ok': False, 'error': 'System data unavailable; check disk path and permissions'}
            print(json.dumps(data), flush=True)
            if args.once:
                break
            time.sleep(2)
    except (BrokenPipeError, KeyboardInterrupt):
        pass

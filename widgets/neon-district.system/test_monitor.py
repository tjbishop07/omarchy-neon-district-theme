import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('monitor', Path(__file__).with_name('monitor.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class MonitorTests(unittest.TestCase):
    def test_guest_cpu_is_not_counted_twice(self):
        self.assertEqual(m.cpu_counters('cpu 10 0 5 80 5 0 0 0 10 0\n'), (100, 85))

    def test_cpu_delta_and_first_sample(self):
        self.assertIsNone(m.cpu_percent(None, (100, 80)))
        self.assertEqual(m.cpu_percent((100, 80), (200, 130)), 50)
        self.assertIsNone(m.cpu_percent((100, 80), (90, 70)))

    def test_memory_uses_available_including_reclaimable_cache(self):
        result = m.memory('MemTotal: 1000 kB\nMemFree: 100 kB\nMemAvailable: 400 kB\n')
        self.assertEqual(result['memoryPercent'], 60)

    def test_network_delta_and_reset(self):
        self.assertEqual(m.rates((1000, 2000), (3000, 6000), 2), (1000, 2000))
        self.assertEqual(m.rates((1000, 2000), (10, 20), 2), (None, None))
        self.assertEqual(m.rates(None, (10, 20), 2), (None, None))

    def test_default_route_uses_lowest_metric(self):
        routes = 'Iface Destination Gateway Flags RefCnt Use Metric Mask\nwlan0 00000000 01000000 0003 0 0 600 00000000\neth0 00000000 01000000 0003 0 0 100 00000000\n'
        self.assertEqual(m.default_interface(routes, {'wlan0': (0, 0), 'eth0': (0, 0)}), 'eth0')

    def test_ipv6_only_default_route(self):
        route = '0' * 32 + ' 00 ' + '0' * 32 + ' 00 ' + '0' * 32 + ' 00000064 00000000 00000000 00000003 wlan0'
        self.assertEqual(m.default_interface('header', {'wlan0': (0, 0)}, route), 'wlan0')

    def test_loopback_not_in_network_counters(self):
        text = 'header\nheader\nlo: 10 0 0 0 0 0 0 0 20\nwlan0: 100 0 0 0 0 0 0 0 200\n'
        self.assertEqual(m.network_counters(text), {'wlan0': (100, 200)})


if __name__ == '__main__':
    unittest.main()

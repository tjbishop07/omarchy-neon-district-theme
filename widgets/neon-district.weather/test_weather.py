import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("weather", Path(__file__).with_name("weather.py"))
weather = importlib.util.module_from_spec(spec)
spec.loader.exec_module(weather)


class WeatherTests(unittest.TestCase):
    def data(self):
        return {"current": {"temperature_2m": 30.2, "apparent_temperature": 31.8,
                "relative_humidity_2m": 24, "wind_speed_10m": 9.3, "weather_code": 0,
                "is_day": 1, "time": "2026-09-27T14:00"},
                "daily": {"time": ["2026-09-27", "2026-09-28", "2026-09-29", "2026-09-30"],
                "temperature_2m_max": [33, 34, 35, 32], "temperature_2m_min": [22, 23, 24, 21],
                "weather_code": [0, 2, 3, 61]}}

    def test_forecast_preserves_today_and_three_following_days(self):
        result = weather.normalize(self.data(), "Example", "metric")
        self.assertEqual(result["temperature"], 30)
        self.assertEqual(result["days"][1]["date"], "2026-09-28")
        self.assertEqual(len(result["days"]), 4)

    def test_missing_temperature_is_not_zero_degrees(self):
        data = self.data()
        data["current"]["temperature_2m"] = None
        with self.assertRaises(ValueError):
            weather.normalize(data, "Example", "metric")

    def test_incomplete_forecast_is_rejected(self):
        data = self.data()
        data["daily"]["time"] = []
        with self.assertRaises(ValueError):
            weather.normalize(data, "Example", "metric")

    def test_invalid_numbers_are_rejected(self):
        for value in (None, True, float("nan"), float("inf")):
            with self.assertRaises(ValueError):
                weather.number(value)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Read Omarchy's configured coordinates and query Open-Meteo (no API key)."""
import json
import math
from pathlib import Path
import sys
from datetime import datetime, timezone
from urllib.parse import urlencode
from urllib.request import Request, urlopen


def number(value):
    if isinstance(value, bool) or value is None:
        raise ValueError("Missing numeric weather data")
    result = float(value)
    if not math.isfinite(result):
        raise ValueError("Invalid numeric weather data")
    return result


def normalize(data, location, unit):
    current = data["current"]
    daily = data["daily"]
    days = []
    for i, date in enumerate(daily["time"][:4]):
        days.append({"date": date, "high": round(number(daily["temperature_2m_max"][i])),
                     "low": round(number(daily["temperature_2m_min"][i])),
                     "code": int(number(daily["weather_code"][i]))})
    if len(days) < 4:
        raise ValueError("Incomplete forecast")
    return {"ok": True, "location": location, "unit": unit,
            "temperature": round(number(current["temperature_2m"])),
            "feels": round(number(current["apparent_temperature"])),
            "humidity": round(number(current["relative_humidity_2m"])),
            "wind": round(number(current["wind_speed_10m"])),
            "code": int(number(current["weather_code"])),
            "isDay": bool(current["is_day"]), "observed": current["time"],
            "updated": datetime.now(timezone.utc).isoformat(), "days": days}


def fetch(unit):
    path = Path.home() / ".local/state/omarchy/settings/weather.json"
    try:
        location = json.loads(path.read_text())
        latitude, longitude = number(location["latitude"]), number(location["longitude"])
        if not (-90 <= latitude <= 90 and -180 <= longitude <= 180):
            raise ValueError("Coordinates out of range")
    except (OSError, ValueError, KeyError, TypeError):
        return {"ok": False, "setup": True, "error": "Set your location in Omarchy's weather panel"}
    query = urlencode({"latitude": latitude, "longitude": longitude,
                       "current": "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day",
                       "daily": "temperature_2m_max,temperature_2m_min,weather_code",
                       "forecast_days": 4, "timezone": "auto",
                       "temperature_unit": "fahrenheit" if unit == "imperial" else "celsius",
                       "wind_speed_unit": "mph" if unit == "imperial" else "kmh"})
    request = Request("https://api.open-meteo.com/v1/forecast?" + query,
                      headers={"User-Agent": "NeonDistrictWeather/1.0"})
    with urlopen(request, timeout=20) as response:
        data = json.load(response)
    return normalize(data, str(location.get("name") or "Local weather"), unit)


if __name__ == "__main__":
    unit = sys.argv[1] if len(sys.argv) > 1 else "metric"
    if unit not in ("metric", "imperial"):
        unit = "metric"
    try:
        result = fetch(unit)
    except Exception:
        result = {"ok": False, "error": "Weather unavailable — retrying automatically"}
    print(json.dumps(result))

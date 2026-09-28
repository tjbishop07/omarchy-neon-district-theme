function condition(code, night) {
    if (code === 0) return night ? "Clear night" : "Clear sky"
    if (code <= 2) return "Partly cloudy"
    if (code === 3) return "Overcast"
    if (code === 45 || code === 48) return "Fog"
    if (code >= 51 && code <= 57) return "Drizzle"
    if (code >= 61 && code <= 67) return "Rain"
    if (code >= 71 && code <= 77) return "Snow"
    if (code >= 80 && code <= 82) return "Rain showers"
    if (code === 85 || code === 86) return "Snow showers"
    if (code >= 95 && code <= 99) return "Thunderstorms"
    return "Unknown conditions"
}
function icon(code, night) {
    if (code === 0) return night ? "" : ""
    if (code <= 2) return night ? "" : ""
    if (code === 3) return ""
    if (code === 45 || code === 48) return ""
    if ((code >= 71 && code <= 77) || code === 85 || code === 86) return ""
    if (code >= 95) return ""
    return ""
}
function day(date) {
    return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][new Date(date + "T12:00:00").getDay()]
}

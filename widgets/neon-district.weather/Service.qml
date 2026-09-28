import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root
  property var shell: null
  readonly property var config: {
    var entries = shell && shell.shellConfig ? shell.shellConfig.plugins || [] : []
    for (var i = 0; i < entries.length; ++i)
      if (entries[i].id === "neon-district.weather") return entries[i]
    return {}
  }
  readonly property string unit: config.unit === "metric" || config.unit === "imperial"
    ? config.unit : (Qt.locale().name.indexOf("en_US") === 0 ? "imperial" : "metric")
  readonly property var chosenScreen: {
    var screens = Quickshell.screens
    for (var i = 0; i < screens.length; ++i)
      if (screens[i].name === config.monitor) return screens[i]
    return screens.length ? screens[0] : null
  }
  property var weather: null
  property string error: "Weather access is not enabled"
  readonly property bool allowNetwork: config.allowNetwork === true
  onAllowNetworkChanged: {
    if (allowNetwork) refresh()
    else { fetch.running = false; weather = null; error = "Weather access is not enabled" }
  }
  property double now: Date.now()
  readonly property bool stale: weather !== null && (error !== "" || now - Date.parse(weather.updated) > 1800000)
  function refresh() {
    if (allowNetwork && !fetch.running) {
      if (!weather) error = ""
      fetch.running = true
    }
  }
  function offset(value, fallback, maximum) {
    var n = Number(value)
    return Math.max(0, Math.min(value === undefined || !isFinite(n) ? fallback : n, maximum))
  }
  IpcHandler {
    target: "neon-weather"
    function refresh(): void { root.refresh() }
    function status(): string {
      return JSON.stringify({enabled: root.allowNetwork, loading: fetch.running,
        available: root.weather !== null, stale: root.stale, error: root.error,
        unit: root.unit, updated: root.weather ? root.weather.updated : null})
    }
  }
  onUnitChanged: { weather = null; if (fetch.running) fetch.running = false; refresh() }
  Component.onCompleted: refresh()

  Process {
    id: fetch
    command: ["python3", decodeURIComponent(Qt.resolvedUrl("weather.py").toString().replace("file://", "")), root.unit]
    stdout: StdioCollector {
      onStreamFinished: {
        if (!root.allowNetwork) return
        try {
          var result = JSON.parse(text)
          if (result.ok) { if (result.unit !== root.unit) return; root.weather = result; root.error = ""; root.now = Date.now() }
          else { root.error = result.error || "Weather unavailable"; if (result.setup) root.weather = null }
        } catch (e) { root.error = "Unable to read weather data" }
      }
    }
  }
  Timer { interval: 900000; running: true; repeat: true; onTriggered: root.refresh() }
  Timer { interval: 60000; running: true; repeat: true; onTriggered: root.now = Date.now() }
  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/settings/weather.json"
    watchChanges: true
    printErrors: false
    onFileChanged: { reload(); root.weather = null; if (fetch.running) fetch.running = false; root.refresh() }
  }

  PanelWindow {
    id: window
    screen: root.chosenScreen
    visible: root.chosenScreen !== null
    implicitWidth: 380
    implicitHeight: 382
    anchors { top: true; left: true }
    margins {
      left: root.offset(root.config.x, 28, root.chosenScreen ? root.chosenScreen.width - 380 : 28)
      top: root.offset(root.config.y, 72, root.chosenScreen ? root.chosenScreen.height - 382 : 72)
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "neon-district-weather"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    WeatherCard {
      anchors.fill: parent
      rainEnabled: root.config.rainEnabled !== false
      surfaceOpacity: root.config.backgroundOpacity !== undefined && isFinite(Number(root.config.backgroundOpacity))
        ? Math.max(0.1, Math.min(1, Number(root.config.backgroundOpacity))) : 0.82
      weather: root.weather
      error: root.error
      unit: root.unit
      stale: root.stale
      fetching: fetch.running
      onRefreshRequested: root.refresh()
    }
  }
}

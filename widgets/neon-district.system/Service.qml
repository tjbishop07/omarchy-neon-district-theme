import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root
  property var shell: null
  function entry(id) {
    var entries = shell && shell.shellConfig ? shell.shellConfig.plugins || [] : []
    for (var i = 0; i < entries.length; ++i) if (entries[i].id === id) return entries[i]
    return {}
  }
  readonly property var config: entry("neon-district.system")
  readonly property var weatherConfig: entry("neon-district.weather")
  readonly property var chosenScreen: {
    var screens = Quickshell.screens
    var monitor = config.monitor || weatherConfig.monitor
    for (var i = 0; i < screens.length; ++i) if (screens[i].name === monitor) return screens[i]
    return screens.length ? screens[0] : null
  }
  property var stats: null
  property var cpuHistory: []
  property var memoryHistory: []
  property string error: ""
  property double received: 0
  property double now: Date.now()
  readonly property bool stale: error !== "" || (received > 0 && now - received > 6000)
  function position(value, fallback, maximum) {
    var n = Number(value)
    return Math.max(0, Math.min(value === undefined || !isFinite(n) ? fallback : n, maximum))
  }
  function append(values, n) {
    if (n === null || n === undefined || !isFinite(n)) return values
    var next = values.slice(-39); next.push(n); return next
  }
  Process {
    id: sampler
    running: true
    command: ["python3", "-u", decodeURIComponent(Qt.resolvedUrl("monitor.py").toString().replace("file://", "")),
      "--disk-path", String(root.config.diskPath || Quickshell.env("HOME")), "--interface", String(root.config.interface || "")]
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var data = JSON.parse(line)
          if (!data.ok) { root.error = data.error || "System data unavailable"; return }
          root.stats = data; root.error = ""; root.received = Date.now(); root.now = root.received
          root.cpuHistory = root.append(root.cpuHistory, data.cpu)
          root.memoryHistory = root.append(root.memoryHistory, data.memoryPercent)
        } catch (e) { root.error = "Unable to read system data" }
      }
    }
    onExited: { root.error = "Collector stopped"; restart.start() }
  }
  Timer { id: restart; interval: 3000; onTriggered: sampler.running = true }
  Timer { interval: 2000; running: true; repeat: true; onTriggered: root.now = Date.now() }
  IpcHandler {
    target: "neon-system"
    function status(): string { return JSON.stringify({running: sampler.running, available: root.stats !== null, stale: root.stale, error:root.error, stats:root.stats, samples:root.cpuHistory.length}) }
  }
  PanelWindow {
    screen: root.chosenScreen
    visible: root.chosenScreen !== null
    implicitWidth: 380; implicitHeight: 398
    anchors { top: true; left: true }
    margins {
      left: root.position(root.config.x, root.weatherConfig.x === undefined ? (root.chosenScreen ? root.chosenScreen.width - 408 : 28) : Number(root.weatherConfig.x), root.chosenScreen ? root.chosenScreen.width - 380 : 28)
      top: root.position(root.config.y, (Number(root.weatherConfig.y) || 72) + 400, root.chosenScreen ? root.chosenScreen.height - 398 : 472)
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "neon-district-system"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    SystemCard {
      anchors.fill: parent
      stats: root.stats; cpuHistory: root.cpuHistory; memoryHistory: root.memoryHistory
      stale: root.stale; error: root.error
      diskLabel: root.config.diskPath ? "DISK USAGE" : "HOME DISK"
      rainEnabled: root.config.rainEnabled === undefined ? root.weatherConfig.rainEnabled !== false : root.config.rainEnabled !== false
      surfaceOpacity: root.config.backgroundOpacity === undefined
        ? (root.weatherConfig.backgroundOpacity === undefined ? 0.35 : Number(root.weatherConfig.backgroundOpacity))
        : Math.max(0.1, Math.min(1, Number(root.config.backgroundOpacity)))
    }
  }
}

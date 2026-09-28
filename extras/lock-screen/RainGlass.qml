import QtQuick

// A decorative layer under the readings; no mouse handling or external assets.
Canvas {
  id: rain
  property real cut: 22
  property bool animated: true
  property var beads: []
  property real elapsed: 0
  property double lastTick: 0
  visible: animated

  Component.onCompleted: {
    var drops = []
    // Deterministic spacing keeps reloads from producing distracting flashes.
    for (var i = 0; i < 110; ++i)
      drops.push({x: ((i * 137 + 29) % 359) / 359,
        y: ((i * 97 + 41) % 373) / 373, r: 1.4 + (i % 5) * 0.55,
        speed: i % 6 === 0 ? 9 + i % 13 : 0, phase: i * 0.83})
    beads = drops
    requestPaint()
  }
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()
  onVisibleChanged: { lastTick = 0; if (visible) requestPaint() }
  onCutChanged: requestPaint()

  Timer {
    interval: 50; repeat: true; running: rain.visible
    onTriggered: {
      var now = Date.now()
      if (rain.lastTick) rain.elapsed += Math.min(0.1, (now - rain.lastTick) / 1000)
      rain.lastTick = now
      rain.requestPaint()
    }
  }
  onPaint: {
    var c = getContext("2d")
    c.reset()
    var edge = 3, k = Math.min(cut, width / 3, height / 3)
    c.beginPath()
    c.moveTo(edge + k, edge); c.lineTo(width - edge, edge)
    c.lineTo(width - edge, height - edge - k)
    c.lineTo(width - edge - k, height - edge)
    c.lineTo(edge, height - edge); c.lineTo(edge, edge + k)
    c.closePath(); c.clip()
    for (var i = 0; i < beads.length; ++i) {
      var d = beads[i], r = d.r
      var y = (d.y * height + elapsed * d.speed) % (height + 70) - 20
      var x = 12 + d.x * (width - 24)
      if (d.speed) {
        x += Math.sin(elapsed * 0.45 + d.phase) * 2
        var trail = c.createLinearGradient(x, y - 48, x, y)
        trail.addColorStop(0, "transparent")
        trail.addColorStop(1, "rgba(112,218,239,0.20)")
        c.beginPath(); c.moveTo(x - 1, y - 48)
        c.quadraticCurveTo(x + 3, y - 22, x, y)
        c.strokeStyle = trail; c.lineWidth = r * 0.7; c.stroke()
      }
      // Shadow, curved rim and a pinprick highlight suggest water on glass.
      c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2)
      c.fillStyle = "rgba(4,8,22,0.24)"; c.fill()
      c.strokeStyle = "rgba(132,210,231,0.22)"; c.lineWidth = 0.7; c.stroke()
      c.beginPath(); c.arc(x, y, r * 0.75, Math.PI * 0.95, Math.PI * 1.65)
      c.strokeStyle = "rgba(207,250,255,0.48)"; c.lineWidth = 0.85; c.stroke()
      c.beginPath(); c.arc(x + r * 0.27, y + r * 0.48, r * 0.22, 0, Math.PI * 2)
      c.fillStyle = i % 3 === 0 ? "rgba(255,79,154,0.45)" : "rgba(54,249,246,0.42)"
      c.fill()
    }
  }
}

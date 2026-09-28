import QtQuick

Canvas {
  id: root
  property var samples: []
  property color lineColor: "#36f9f6"
  property int capacity: 40
  onSamplesChanged: requestPaint()
  onLineColorChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()
  onPaint: {
    var ctx = getContext("2d")
    ctx.reset()
    ctx.strokeStyle = "#383054"
    ctx.lineWidth = 1
    for (var row = 1; row <= 3; ++row) {
      var y = row * (height - 2) / 3
      ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
    }
    if (samples.length < 2) return
    ctx.beginPath()
    for (var i = 0; i < samples.length; ++i) {
      var x = (capacity - samples.length + i) * width / (capacity - 1)
      var point = height - 2 - Math.max(0, Math.min(100, samples[i])) * (height - 4) / 100
      if (i === 0) ctx.moveTo(x, point); else ctx.lineTo(x, point)
    }
    ctx.strokeStyle = lineColor; ctx.lineWidth = 2; ctx.stroke()
  }
}

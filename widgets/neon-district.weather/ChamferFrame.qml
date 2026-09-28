import QtQuick

Item {
  id: root
  property real cut: 22
  property real borderWidth: 2
  property color startColor: "#36f9f6"
  property color endColor: "#ff4f9a"
  property color surfaceColor: "#ee0b0914"
  default property alias content: body.data

  Canvas {
    id: outline
    anchors.fill: parent
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var c = getContext("2d")
      c.reset()
      var inset = root.borderWidth / 2
      var right = width - inset, bottom = height - inset
      var cut = Math.min(root.cut, width / 3, height / 3)
      c.beginPath()
      c.moveTo(inset + cut, inset)
      c.lineTo(right, inset)
      c.lineTo(right, bottom - cut)
      c.lineTo(right - cut, bottom)
      c.lineTo(inset, bottom)
      c.lineTo(inset, inset + cut)
      c.closePath()
      c.fillStyle = root.surfaceColor
      c.fill()
      var gradient = c.createLinearGradient(0, 0, width, height)
      gradient.addColorStop(0, root.startColor)
      gradient.addColorStop(1, root.endColor)
      c.strokeStyle = gradient
      c.lineWidth = root.borderWidth
      c.stroke()
    }
  }
  onCutChanged: outline.requestPaint()
  onBorderWidthChanged: outline.requestPaint()
  onStartColorChanged: outline.requestPaint()
  onEndColorChanged: outline.requestPaint()
  onSurfaceColorChanged: outline.requestPaint()
  Item { id: body; anchors.fill: parent; anchors.margins: 24 }
}

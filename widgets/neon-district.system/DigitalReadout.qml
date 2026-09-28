import QtQuick

Row {
  id: root
  property string value: "--"
  property string suffix: ""
  property string numberFamily: "monospace"
  property string labelFamily: "sans-serif"
  property real pixelSize: 18
  property color color: "#e5def5"
  spacing: 5
  Text {
    text: root.value
    font.family: root.numberFamily
    font.pixelSize: root.pixelSize
    color: root.color
  }
  Text {
    text: root.suffix
    anchors.bottom: parent.bottom
    font.family: root.labelFamily
    font.pixelSize: Math.max(9, Math.min(17, root.pixelSize * 0.6))
    color: root.color
  }
}

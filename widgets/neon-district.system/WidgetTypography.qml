import QtQuick

QtObject {
  readonly property string labelFamily: labels.status === FontLoader.Ready ? labels.name : "sans-serif"
  readonly property string numberFamily: digits.status === FontLoader.Ready ? digits.name : "monospace"
  readonly property string iconFamily: "monospace"
  readonly property FontLoader labels: FontLoader { source: Qt.resolvedUrl("Orbitron.ttf") }
  readonly property FontLoader digits: FontLoader { source: Qt.resolvedUrl("DSEG7Classic-Regular.ttf") }
}

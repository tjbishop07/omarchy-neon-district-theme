import QtQuick
import QtQuick.Layouts
import "Weather.js" as Weather

ChamferFrame {
  id: root
  property var weather: null
  property string error: ""
  property string unit: "metric"
  property bool stale: false
  property bool fetching: false
  property bool sample: false
  readonly property string degree: unit === "imperial" ? "°F" : "°C"
  signal refreshRequested()
  width: 380
  height: 382
      Column {
        anchors.fill: parent
        spacing: 12
        RowLayout {
          width: parent.width
          Text { text: root.sample ? "WEATHER / SAMPLE" : "WEATHER / 01"; color: "#36f9f6"; font.family: "monospace"; font.pixelSize: 12; font.letterSpacing: 2; Layout.fillWidth: true }
          Text {
            text: root.fetching ? "···" : "↻"
            color: refreshMouse.containsMouse ? "#36f9f6" : "#a59abb"
            font.pixelSize: 23
            MouseArea { id: refreshMouse; anchors.fill: parent; anchors.margins: -5; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.refreshRequested() }
          }
        }
        Text { width: parent.width; text: root.weather ? root.weather.location.toUpperCase() : "LOCAL WEATHER"; elide: Text.ElideRight; color: "#e5def5"; font.family: "monospace"; font.pixelSize: 18; font.letterSpacing: 1 }
        RowLayout {
          width: parent.width
          height: 84
          Text { text: root.weather ? root.weather.temperature + "°" : "—"; color: "#e5def5"; font.family: "monospace"; font.pixelSize: 68; font.weight: Font.Light; Layout.fillWidth: true }
          Text { text: root.degree; color: "#a59abb"; font.family: "monospace"; font.pixelSize: 18; Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 13 }
          Text { text: root.weather ? Weather.icon(root.weather.code, !root.weather.isDay) : ""; color: "#ff4f9a"; font.family: "monospace"; font.pixelSize: 50; Layout.leftMargin: 14 }
        }
        Text { width: parent.width; elide: Text.ElideRight; text: root.weather ? Weather.condition(root.weather.code, !root.weather.isDay) + " · Feels " + root.weather.feels + root.degree : (root.error || "Loading current conditions…"); color: "#a59abb"; font.family: "monospace"; font.pixelSize: 12 }
        RowLayout {
          width: parent.width
          Text { text: "WIND  " + (root.weather ? root.weather.wind + (root.unit === "imperial" ? " mph" : " km/h") : "—"); color: "#36f9f6"; font.family: "monospace"; font.pixelSize: 12; Layout.fillWidth: true }
          Text { text: "HUMIDITY  " + (root.weather ? root.weather.humidity + "%" : "—"); color: "#e5def5"; font.family: "monospace"; font.pixelSize: 12 }
        }
        Rectangle { width: parent.width; height: 1; color: "#383054" }
        Row {
          width: parent.width
          Repeater {
            model: root.weather ? root.weather.days.slice(1, 4) : []
            Column {
              required property var modelData
              width: 110
              spacing: 5
              Text { text: Weather.day(modelData.date); color: "#a59abb"; font.family: "monospace"; font.pixelSize: 11; font.letterSpacing: 1 }
              Text { text: Weather.icon(modelData.code, false) + "  " + modelData.high + "°"; color: "#e5def5"; font.family: "monospace"; font.pixelSize: 17 }
              Text { text: modelData.low + "° LOW"; color: "#a59abb"; font.family: "monospace"; font.pixelSize: 10 }
            }
          }
        }
        RowLayout {
          width: parent.width
          Text { text: root.stale ? "STALE · RETRYING" : (root.weather ? "UPDATED " + Qt.formatDateTime(new Date(root.weather.updated), "HH:mm") : "WAITING FOR DATA"); color: root.stale ? "#f4ef78" : "#817698"; font.family: "monospace"; font.pixelSize: 9; Layout.fillWidth: true }
          Text { text: "OPEN-METEO ↗"; color: "#817698"; font.family: "monospace"; font.pixelSize: 9
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://open-meteo.com/") }
          }
        }
      }
    }

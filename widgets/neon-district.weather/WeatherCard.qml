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
  WidgetTypography { id: typography }

  Column {
    anchors.fill: parent
    spacing: 13
    RowLayout {
      width: parent.width
      height: 25
      Text {
        text: root.sample ? "WEATHER / SAMPLE" : "WEATHER / 01"
        color: "#36f9f6"
        font { family: typography.labelFamily; pixelSize: 11; letterSpacing: 1.5; weight: Font.DemiBold }
        Layout.fillWidth: true
      }
      Text {
        text: root.fetching ? "···" : "↻"
        color: refreshMouse.containsMouse ? "#36f9f6" : "#a59abb"
        font.pixelSize: 23
        MouseArea { id: refreshMouse; anchors.fill: parent; anchors.margins: -5; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.refreshRequested() }
      }
    }
    Text {
      width: parent.width
      text: root.weather ? root.weather.location.toUpperCase() : "LOCAL WEATHER"
      elide: Text.ElideRight
      color: "#e5def5"
      font { family: typography.labelFamily; pixelSize: 18; letterSpacing: 1; weight: Font.Medium }
    }
    RowLayout {
      width: parent.width
      height: 76
      DigitalReadout {
        value: root.weather ? String(root.weather.temperature) : "--"
        suffix: root.degree
        numberFamily: typography.numberFamily
        labelFamily: typography.labelFamily
        pixelSize: 57
        color: "#e5def5"
        Layout.fillWidth: true
      }
      Text {
        text: root.weather ? Weather.icon(root.weather.code, !root.weather.isDay) : ""
        color: "#ff4f9a"
        font { family: typography.iconFamily; pixelSize: 46 }
      }
    }
    RowLayout {
      width: parent.width
      Text {
        text: root.weather ? Weather.condition(root.weather.code, !root.weather.isDay).toUpperCase() : (root.error || "Loading conditions…")
        elide: Text.ElideRight
        color: "#a59abb"
        font { family: typography.labelFamily; pixelSize: 10 }
        Layout.fillWidth: true
      }
      Text { visible: root.weather !== null; text: "FEELS"; color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 9 } }
      DigitalReadout {
        visible: root.weather !== null
        value: root.weather ? String(root.weather.feels) : "--"
        suffix: root.degree
        numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 14; color: "#a59abb"
      }
    }
    RowLayout {
      width: parent.width
      Row {
        spacing: 7
        Layout.fillWidth: true
        Text { text: "WIND"; anchors.verticalCenter: parent.verticalCenter; color: "#36f9f6"; font { family: typography.labelFamily; pixelSize: 10 } }
        DigitalReadout {
          value: root.weather ? String(root.weather.wind) : "--"
          suffix: root.unit === "imperial" ? "mph" : "km/h"
          numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 17; color: "#36f9f6"
        }
      }
      Row {
        spacing: 7
        Text { text: "HUMIDITY"; anchors.verticalCenter: parent.verticalCenter; color: "#e5def5"; font { family: typography.labelFamily; pixelSize: 10 } }
        DigitalReadout {
          value: root.weather ? String(root.weather.humidity) : "--"
          suffix: "%"
          numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 17
        }
      }
    }
    Rectangle { width: parent.width; height: 1; color: "#383054" }
    Row {
      width: parent.width
      Repeater {
        model: root.weather ? root.weather.days.slice(1, 4) : []
        Column {
          required property var modelData
          width: 110
          spacing: 7
          Text { text: Weather.day(modelData.date); color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 10; letterSpacing: 1 } }
          Row {
            spacing: 8
            Text { text: Weather.icon(modelData.code, false); color: "#e5def5"; font { family: typography.iconFamily; pixelSize: 20 } }
            DigitalReadout { value: String(modelData.high); suffix: "°"; numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 20 }
          }
          DigitalReadout { value: String(modelData.low); suffix: "° LOW"; numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 12; color: "#a59abb" }
        }
      }
    }
    RowLayout {
      width: parent.width
      spacing: 6
      Text {
        text: root.stale ? "STALE · RETRYING" : (root.weather ? "UPDATED" : "WAITING FOR DATA")
        color: root.stale ? "#f4ef78" : "#817698"
        font { family: typography.labelFamily; pixelSize: 8 }
      }
      Text {
        visible: root.weather !== null && !root.stale
        text: root.weather ? Qt.formatDateTime(new Date(root.weather.updated), "HH:mm") : ""
        color: "#a59abb"
        font { family: typography.numberFamily; pixelSize: 10 }
      }
      Item { Layout.fillWidth: true }
      Text {
        text: "OPEN-METEO ↗"; color: "#817698"
        font { family: typography.labelFamily; pixelSize: 8 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally("https://open-meteo.com/") }
      }
    }
  }
}

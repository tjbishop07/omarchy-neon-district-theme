import QtQuick
import QtQuick.Layouts

ChamferFrame {
  id: root
  width: 380
  height: 398
  property var stats: null
  property var cpuHistory: []
  property var memoryHistory: []
  property bool stale: false
  property bool sample: false
  property string error: ""
  property string diskLabel: "HOME DISK"
  WidgetTypography { id: typography }
  function value(n) { return n === null || n === undefined ? "--" : String(Math.round(n)) }
  function speed(n) { return n === null || n === undefined ? "--" : (n >= 1048576 ? (n / 1048576).toFixed(1) : (n / 1024).toFixed(1)) }
  function speedUnit(n) { return n >= 1048576 ? "MiB/s" : "KiB/s" }
  function uptime(n) {
    var hours = Math.floor(n / 3600), minutes = Math.floor(n % 3600 / 60)
    return String(hours) + ":" + (minutes < 10 ? "0" : "") + minutes
  }
  Column {
    anchors.fill: parent
    spacing: 16
    RowLayout {
      width: parent.width
      Text { text: root.sample ? "SYSTEM / SAMPLE" : "SYSTEM / 02"; color: "#36f9f6"; font { family: typography.labelFamily; pixelSize: 11; letterSpacing: 1.5; weight: Font.DemiBold } Layout.fillWidth: true }
      Rectangle { width: 5; height: 5; radius: 2.5; color: root.stale ? "#f4ef78" : "#8cf5b0" }
    }
    Row {
      width: parent.width
      spacing: 20
      Repeater {
        model: [ {name:"CPU", reading: root.stats ? root.stats.cpu : null, history:root.cpuHistory, tint:"#36f9f6"},
                 {name:"MEMORY", reading: root.stats ? root.stats.memoryPercent : null, history:root.memoryHistory, tint:"#ff4f9a"} ]
        Column {
          required property var modelData
          width: 156
          spacing: 9
          Text { text: modelData.name; color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 11; letterSpacing: 1 } }
          DigitalReadout { value: root.value(modelData.reading); suffix: "%"; numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 35; color: modelData.tint }
          Sparkline { width: parent.width; height: 46; samples: modelData.history; lineColor: modelData.tint }
        }
      }
    }
    Text {
      width: parent.width
      text: root.stats ? root.stats.memoryUsedGiB.toFixed(1) + " / " + root.stats.memoryTotalGiB.toFixed(1) + " GiB RAM · 80s HISTORY" : "COLLECTING SYSTEM DATA"
      color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 9 }
    }
    Rectangle { width: parent.width; height: 1; color: "#383054" }
    Column {
      width: parent.width
      spacing: 8
      RowLayout {
        width: parent.width
        Text { text: root.diskLabel; color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 10 } Layout.fillWidth: true }
        DigitalReadout { value: root.value(root.stats ? root.stats.diskPercent : null); suffix: "%"; numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 17 }
      }
      Rectangle {
        width: parent.width; height: 3; color: "#383054"
        Rectangle { width: parent.width * (root.stats ? root.stats.diskPercent / 100 : 0); height: parent.height; color: root.stats && root.stats.diskPercent >= 90 ? "#f4ef78" : "#36f9f6" }
      }
      Text { text: root.stats ? root.stats.diskUsedGiB.toFixed(0) + " / " + root.stats.diskTotalGiB.toFixed(0) + " GiB USED" : "—"; color: "#817698"; font { family: typography.labelFamily; pixelSize: 9 } }
    }
    Row {
      width: parent.width
      spacing: 20
      Repeater {
        model: [{name:"DOWNLOAD", rate:root.stats ? root.stats.rxBps : null, tint:"#36f9f6"},
                {name:"UPLOAD", rate:root.stats ? root.stats.txBps : null, tint:"#ff4f9a"}]
        Column {
          required property var modelData
          width: 156; spacing: 8
          Text { text: modelData.name; color: "#a59abb"; font { family: typography.labelFamily; pixelSize: 9; letterSpacing: 1 } }
          DigitalReadout { value: root.speed(modelData.rate); suffix: root.speedUnit(modelData.rate); numberFamily: typography.numberFamily; labelFamily: typography.labelFamily; pixelSize: 20; color: modelData.tint }
        }
      }
    }
    RowLayout {
      width: parent.width
      Text { text: root.stale ? "STALE · RETRYING" : (root.stats && root.stats.interface ? root.stats.interface.toUpperCase() : "NO NETWORK LINK"); elide: Text.ElideRight; color: root.stale ? "#f4ef78" : "#817698"; font { family: typography.labelFamily; pixelSize: 8 } Layout.fillWidth: true }
      Text { text: "UP"; color: "#817698"; font { family: typography.labelFamily; pixelSize: 8 } }
      Text { text: root.stats ? root.uptime(root.stats.uptime) : "--:--"; color: "#a59abb"; font { family: typography.numberFamily; pixelSize: 10 } }
    }
  }
}

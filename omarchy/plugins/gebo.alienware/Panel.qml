import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "gebo.alienware"
  ipcTarget: "gebo.alienware"

  property string profile: "unknown"
  property string cpuTemp: "--"
  property string gpuTemp: "--"
  property string cpuRpm: "--"
  property string gpuRpm: "--"
  property string cpuBoost: "0"
  property string gpuBoost: "0"
  property var anchorItem: null

  function refresh() { if (!stateProc.running) stateProc.running = true }
  function run(args) { actionProc.command = ["omarchy-alienware"].concat(args); actionProc.running = true }

  Component.onCompleted: refresh()
  onOpenedChanged: if (opened) refresh()

  Timer {
    interval: 3000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: stateProc
    command: ["omarchy-alienware", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var p = String(text || "").trim().split("\t")
        if (p.length < 7) return
        root.profile = p[0]
        root.cpuTemp = p[1] + " C"
        root.gpuTemp = p[2] + " C"
        root.cpuRpm = p[3] + " RPM"
        root.gpuRpm = p[4] + " RPM"
        root.cpuBoost = p[5] + "%"
        root.gpuBoost = p[6] + "%"
      }
    }
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    onExited: root.refresh()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(330))
    contentHeight: panel.fittedContentHeight(content.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      Column {
        id: content
        width: parent.width
        spacing: Style.space(12)

        PanelSectionHeader {
          text: "ALIENWARE"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        Text {
          text: "Profile: " + root.profile
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
        }
        Text {
          text: "CPU  " + root.cpuTemp + "  " + root.cpuRpm + "  boost " + root.cpuBoost
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
        }
        Text {
          text: "GPU  " + root.gpuTemp + "  " + root.gpuRpm + "  boost " + root.gpuBoost
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
        }

        PanelSeparator { foreground: root.bar.foreground }

        Text {
          text: "THERMAL PROFILE"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Flow {
          width: parent.width
          spacing: Style.space(6)
          Repeater {
            model: ["quiet", "cool", "balanced", "balanced-performance", "performance", "custom"]
            Button {
              required property string modelData
              text: modelData
              onClicked: root.run(["profile", modelData])
            }
          }
        }

        Button {
          text: "Return to firmware profile"
          onClicked: root.run(["normal"])
        }

        PanelSeparator { foreground: root.bar.foreground }

        Text {
          text: "ADDITIVE FAN BOOST"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Row {
          spacing: Style.space(6)
          Button { text: "CPU +25%"; onClicked: root.run(["boost", "cpu", "25"]) }
          Button { text: "GPU +25%"; onClicked: root.run(["boost", "gpu", "25"]) }
          Button { text: "Clear"; onClicked: root.run(["clear"]) }
        }

        PanelSeparator { foreground: root.bar.foreground }

        Text {
          text: "ALIENFX LIGHTING"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Row {
          spacing: Style.space(6)
          Button { text: "Blue"; onClicked: root.run(["light", "blue"]) }
          Button { text: "Purple"; onClicked: root.run(["light", "purple"]) }
          Button { text: "White"; onClicked: root.run(["light", "white"]) }
          Button { text: "Off"; onClicked: root.run(["light", "off"]) }
        }
      }
    }
  }
}

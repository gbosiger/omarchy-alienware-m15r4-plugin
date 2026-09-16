import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "gebo.alienware"

  property string profile: "..."
  property string temperature: "--"

  function refresh() {
    if (!stateProc.running) stateProc.running = true
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
  }

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  Component.onCompleted: refresh()

  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  Process {
    id: stateProc
    command: ["omarchy-alienware", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var p = String(text || "").trim().split("\t")
        if (p.length >= 2) {
          root.profile = p[0]
          root.temperature = p[1] + "°"
        }
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.temperature
    labelVisible: true
    fixedWidth: -1
    fontSize: Style.font.body
    horizontalMargin: Style.space(8)
    tooltipText: "Alienware: " + root.profile + " / CPU " + root.temperature
    onPressed: root.togglePanel()
  }

  onBarChanged: injectPanel()
}

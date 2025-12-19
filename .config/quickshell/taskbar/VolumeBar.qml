import Quickshell
import Quickshell.I3
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import ".."

RowLayout {
  id: volumebar
  spacing: 1
  anchors.left: parent.left
  anchors.verticalCenter: parent.verticalCenter

  Repeater {
    model: 20
    Button: {
      id: control
      anchors.centerIn: parent.centerIn
      contentItem: Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          width: 10
          height: 10
          color: Config.colors.text
      }
      onPressed: event => {
        command: ["sh","-c", "wpctl set-volume", parse_string({5 * modelData.number})]
        event.accepted = true;
      }
      background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: Config.colors.outline
                width: 22
                height: 22
                color: Config.colors.base 
      }
    }
  }

}


import QtQuick
import Quickshell
import Quickshell.WindowManager
import Quickshell.Io

Row {
    id: root
    spacing: 4
    Repeater {
        model: WindowManager.windowsets

        delegate: Rectangle {
            id: btn

            color: modelData.urgent ? "#f38ba8" : "transparent"
            implicitHeight: 28
            implicitWidth: label.implicitWidth + 12

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.name !== "" ? modelData.name : modelData.id
                color: "#cdd6f4"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 12
            }

            Rectangle {
                id: underline
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                color: modelData.active ? "#cba6f7" : "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: underline.color = "#cdd6f4"
                onExited: underline.color = modelData.active ? "#cba6f7" : "transparent"

                onClicked: {
                    modelData.activate()
                }
            }
        }
    }
}

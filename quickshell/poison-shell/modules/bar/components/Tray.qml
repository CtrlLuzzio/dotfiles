import Quickshell
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: root
    spacing: 10

    Repeater {
        model: SystemTray.items

        delegate: IconImage {
            id: trayIcon
            width: 16
            height: 16

            source: modelData.icon

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu
                anchor.item: trayIcon
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate()
                    }
                    else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu) {
                            menuAnchor.open()
                        }
                    }
                }
            }
        }
    }
}

import Quickshell
import "components"

import "../../config.js" as Config

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: Config.colors.bg

            anchors {
                top: true
                left: true
                right: true
	    }

	    margins {
		top: 10
		right: 10
		left: 10
	    }

	    implicitHeight: 28

            Clock {
                anchors.centerIn: parent
            }

            Workspaces {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 4
                }
            }

            Tray {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 12
                }
            }
        }
    }
}

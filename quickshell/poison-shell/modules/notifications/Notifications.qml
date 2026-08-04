import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import "../../config.js" as Config

Scope {
    id: root
    property bool centerOpen: false
    ListModel {
        id: history
    }
    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            n.tracked = true;
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.centerOpen = !root.centerOpen }
        function show(): void { root.centerOpen = true }
        function close(): void { root.centerOpen = false }
    }

    // Notification Server

    PanelWindow {
        visible: root.centerOpen
        anchors {
            top: true
            right: true
        }
        margins {
            top: 12
            right: 12
        }

        implicitHeight: 380
        implicitWidth: centerCol.implicitHeight + 24
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            color: Config.colors.bg
            border.width: 2
            border.color: Config.colors.purple

            ColumnLayout {
                id: centerCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Config.colors.cyan
                        font.family: Config.bar.fontFamily
                    }

                    Text {
                        text: "Clear"
                        visible: history.count > 0
                        color: Config.colors.red
                        font.family: Config.bar.fontFamily
                        MouseArea {
                            anchors.fill: parent
                            onClicked: history.clear()
                        }
                    }
                }
            }
        }
    }

    // Notification Cards

    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 12
            right: 12
        }

        implicitHeight: 380
        implicitWidth: Math.max(1, column.implicitHeight)
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: true
                        interval: Config.notifications.timeout
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 20
                    color: Config.colors.bg
                    border.width: 2
                    border.color: modelData.urgency == NotificationUrgency.Critical ? Config.colors.red : Config.colors.purple

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Config.colors.cyan
                                font.family: Config.bar.fontFamily
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Config.colors.fg
                                font.family: Config.bar.fontFamily
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }
}

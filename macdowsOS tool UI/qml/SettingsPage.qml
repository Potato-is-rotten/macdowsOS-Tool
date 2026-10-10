import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Backend 1.0

Item {
    id: root

    function statusTitle() {
        switch (Backend.updateChecker.updateState) {
        case "checking": return "正在检查更新"
        case "available": return "发现新版本"
        case "up-to-date": return "已是最新版本"
        case "error": return "检查失败"
        default: return "检查应用更新"
        }
    }

    function statusColor() {
        switch (Backend.updateChecker.updateState) {
        case "checking": return "#007AFF"
        case "available": return "#FF9500"
        case "up-to-date": return "#34C759"
        case "error": return "#FF3B30"
        default: return "#8E8E93"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: "设置"
                color: "#1D1D1F"
                font { pixelSize: 25; weight: Font.DemiBold }
            }

            Label {
                text: "应用信息与更新偏好。"
                color: "#6E6E73"
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 680
            Layout.preferredHeight: 96
            radius: 14
            color: "#FFFFFF"
            border.color: "#E5E5EA"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 12
                    color: "#EAF2FF"

                    Label {
                        anchors.centerIn: parent
                        text: "⌁"
                        color: "#007AFF"
                        font { pixelSize: 24; weight: Font.DemiBold }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: "macdowsOS Tool UI"
                        color: "#1D1D1F"
                        font { pixelSize: 14; weight: Font.DemiBold }
                    }

                    Label {
                        text: "雾蓝回针 MistBlueSt"
                        color: "#6E6E73"
                        font.pixelSize: 12
                    }

                    Label {
                        text: "当前版本  " + Backend.updateChecker.currentVersion
                        color: "#86868B"
                        font.pixelSize: 11
                    }

                    Label {
                        text: "版本号  " + Backend.updateChecker.currentTag
                        color: "#A1A1A6"
                        font.pixelSize: 10
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 680
            Layout.preferredHeight: 160
            radius: 14
            color: "#FFFFFF"
            border.color: Backend.updateChecker.updateState === "available" ? "#FFD59A" : "#E5E5EA"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: root.statusColor()

                        RotationAnimator on rotation {
                            running: Backend.updateChecker.updateState === "checking"
                            from: 0; to: 360; duration: 900; loops: Animation.Infinite
                        }
                    }

                    Label {
                        text: root.statusTitle()
                        color: "#1D1D1F"
                        font { pixelSize: 15; weight: Font.DemiBold }
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        visible: Backend.updateChecker.latestVersion !== ""
                        text: "远程版本  " + Backend.updateChecker.latestVersion
                        color: Backend.updateChecker.updateState === "available" ? "#B76500" : "#6E6E73"
                        font { pixelSize: 12; weight: Font.DemiBold }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: Backend.updateChecker.updateMessage
                    color: "#6E6E73"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        id: checkButton
                        text: Backend.updateChecker.updateState === "checking" ? "检查中…" : "检查更新"
                        enabled: Backend.updateChecker.updateState !== "checking"
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 100
                        contentItem: Label {
                            text: checkButton.text
                            color: checkButton.enabled ? "#FFFFFF" : "#A7C9F5"
                            font { pixelSize: 12; weight: Font.DemiBold }
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 9
                            color: checkButton.enabled ? "#007AFF" : "#D6E7FC"
                        }
                        onClicked: Backend.updateChecker.checkForUpdates()
                    }

                    Button {
                        id: releaseButton
                        visible: Backend.updateChecker.updateAvailable
                        text: "查看发布页"
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 96
                        contentItem: Label {
                            text: releaseButton.text
                            color: "#007AFF"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 9
                            color: releaseButton.hovered ? "#EAF2FF" : "transparent"
                            border.color: "#B8D6FF"
                            border.width: 1
                        }
                        onClicked: Qt.openUrlExternally(Backend.updateChecker.releaseUrl)
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        visible: Backend.updateChecker.lastCheckedText !== ""
                        text: "上次检查  " + Backend.updateChecker.lastCheckedText
                        color: "#A1A1A6"
                        font.pixelSize: 11
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 680
            Layout.preferredHeight: 60
            radius: 14
            color: "#FFFFFF"
            border.color: "#E5E5EA"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Label {
                        text: "官方发布渠道"
                        color: "#1D1D1F"
                    font { pixelSize: 13; weight: Font.DemiBold }
                    }

                    Label {
                        text: "更新包仅通过 GitHub Releases 发布"
                        color: "#6E6E73"
                        font.pixelSize: 11
                    }
                }

                Button {
                    id: githubButton
                    text: "打开 GitHub"
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 96
                    contentItem: Label {
                        text: githubButton.text
                        color: "#007AFF"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 9
                        color: githubButton.hovered ? "#EAF2FF" : "transparent"
                        border.color: "#B8D6FF"
                        border.width: 1
                    }
                    onClicked: Qt.openUrlExternally("https://github.com/aiboqiao6/macdowsOS-Tool/releases")
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

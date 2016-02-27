import QtQuick 2.5
import QtQuick.Layouts 1.1

ListView {
    id: detailsView

    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem
    focus: true
    highlightRangeMode: ListView.StrictlyEnforceRange
    currentIndex: rootWindow.currentIndex

    model: PhotosModel

    onCurrentIndexChanged: {
        rootWindow.currentIndex = currentIndex;
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Back && detailsView.currentIndex != -1) {
            rootWindow.currentIndex = -1;
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            rootWindow.currentIndex = -1;
        }
    }

    delegate: Rectangle {
        id: detailsItem
        width: detailsView.width
        height: detailsView.height
        color: "black"

        ColumnLayout {
            anchors.fill: parent
            anchors.bottomMargin: 9 * scaleUnit

            Image {
                id: bigPhoto
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 16

                source: model.fullSizeImageUrl
                fillMode: Image.PreserveAspectFit
                opacity: 0

                OpacityAnimator {
                    target: bigPhoto
                    duration: 300
                    from: 0
                    to: 1
                    running: bigPhoto.status == Image.Ready
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 24 * scaleUnit
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: 16

                Rectangle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    height: detailsColumn.height
                    width: height

                    Image {
                        id: userPic
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: model.userpicUrl
                    }
                }

                ColumnLayout {
                    id: detailsColumn
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        color: "#fff"
                        text: model.name
                        elide: Text.ElideRight

                        Component.onCompleted: {
                            font.pointSize = 1.2 * font.pointSize;
                        }
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        color: "#fff"
                        text: model.userFullname
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }


    }

}


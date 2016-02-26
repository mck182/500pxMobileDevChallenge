import QtQuick 2.5
import QtQuick.Layouts 1.1

ListView {
    id: detailsView

    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem

    model: PhotosModel

    currentIndex: rootWindow.currentIndex

    onCurrentIndexChanged: {
        rootWindow.currentIndex = currentIndex;
    }

    highlightRangeMode: ListView.StrictlyEnforceRange

    delegate: Rectangle {
        id: detailsItem
        width: detailsView.width
        height: detailsView.height
        color: "black"

        ColumnLayout {
            anchors.fill: parent
            anchors.bottomMargin: 9 * scaleUnit

            Image {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 16

                source: model.fullSizeImageUrl
                fillMode: Image.PreserveAspectFit
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 24 * scaleUnit
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: 16

                Rectangle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    height: 64
                    width: 64

                    Image {
                        id: userPic
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: model.userpicUrl
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        color: "#fff"
                        text: model.name
                        font.pointSize: 1.4 * font.pointSize
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        color: "#fff"
                        text: model.userFullname
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }


    }

}


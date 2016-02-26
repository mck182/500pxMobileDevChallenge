import QtQuick 2.5
import QtQuick.Layouts 1.1

ListView {
    id: detailsView

    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem

    model: PhotosModel

    delegate: Rectangle {
        id: detailsItem
        width: detailsView.width
        height: detailsView.height
        color: "black"

        ColumnLayout {
            anchors.fill: parent
            anchors.bottomMargin: 32

            Image {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 16

                source: model.imageUrl
                fillMode: Image.PreserveAspectFit
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 64
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: 16

                Rectangle {
//                    Layout.fillHeight: true
//                    Layout.maximumWidth: 64
//                    Layout.maximumHeight: 64
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


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

            Image {
                Layout.fillHeight: true
                Layout.fillWidth: true

                source: model.imageUrl
//                width: detailsView.width
//                height: detailsView.height
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.fillWidth: true
                color: "#fff"
                text: model.name
            }
        }


    }

}


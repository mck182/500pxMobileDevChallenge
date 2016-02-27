/*
 * Copyright 2016 (c) Martin Klapetek <mklapetek@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

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


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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ApplicationWindow {
    id: rootWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("500px Mobile Dev Challenge")
    color: "#5a5a5a"

    property int currentIndex: -1

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent

            ToolButton {
                id: backButton
                Layout.fillHeight: true
                Layout.leftMargin: 2 * scaleUnit
                Layout.rightMargin: 4 * scaleUnit

                visible: rootWindow.currentIndex > -1

                // This is a workaround for the icon breaking
                // the layout if it's too big
                Image {
                    anchors.fill: parent
                    anchors.margins: 10 * scaleUnit
                    anchors.leftMargin: 2 * scaleUnit
                    source: "qrc:/icons/fa-arrow-left.png"
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    rootWindow.currentIndex = -1;
                }
            }
        }
    }

    FontMetrics {
        id: fontMetrics
    }

    MainView {
        id: mainView
        anchors.fill: parent
    }

    DetailsView {
        id: detailsView
        anchors.fill: parent
        z: 10
        opacity: rootWindow.currentIndex > -1 ? 1 : 0
        visible: rootWindow.currentIndex > -1 || opacity > 0
        currentIndex: rootWindow.currentIndex

        Behavior on opacity {
            OpacityAnimator {
                target: detailsView
            }
        }
    }
}


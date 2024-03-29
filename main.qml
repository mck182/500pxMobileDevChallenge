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
    height: 960
    title: qsTr("500px Mobile Dev Challenge")
    color: "#555"

    property int currentIndex: -1

    toolBar: ToolBar {
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right

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

            ExclusiveGroup {
                id: tabGroup
            }

            ToolButton {
                id: popularCategory
                Layout.fillHeight: true
                Layout.leftMargin: 2 * scaleUnit
                Layout.rightMargin: 2 * scaleUnit

                property string feature: "popular"

                text: "Popular"
                checkable: true
                checked: true
                exclusiveGroup: tabGroup
                visible: rootWindow.currentIndex == -1

                Rectangle {
                    anchors.fill: parent
                    color: "steelblue"
                    opacity: 0.3
                    visible: parent.checked
                }
            }

            ToolButton {
                id: editorsCategory
                Layout.fillHeight: true
                Layout.leftMargin: 2 * scaleUnit
                Layout.rightMargin: 2 * scaleUnit

                property string feature: "editors"

                text: "Editor's"
                checkable: true
                exclusiveGroup: tabGroup
                visible: rootWindow.currentIndex == -1

                Rectangle {
                    anchors.fill: parent
                    color: "steelblue"
                    opacity: 0.3
                    visible: parent.checked
                }
            }

            ToolButton {
                id: upcomingCategory
                Layout.fillHeight: true
                Layout.leftMargin: 2 * scaleUnit
                Layout.rightMargin: 2 * scaleUnit

                property string feature: "upcoming"

                text: "Upcoming"
                checkable: true
                exclusiveGroup: tabGroup
                visible: rootWindow.currentIndex == -1

                Rectangle {
                    anchors.fill: parent
                    color: "steelblue"
                    opacity: 0.3
                    visible: parent.checked
                }
            }

            ToolButton {
                id: freshCategory
                Layout.fillHeight: true
                Layout.leftMargin: 2 * scaleUnit
                Layout.rightMargin: 2 * scaleUnit

                property string feature: "fresh_today"

                text: "Fresh"
                checkable: true
                exclusiveGroup: tabGroup
                visible: rootWindow.currentIndex == -1

                Rectangle {
                    anchors.fill: parent
                    color: "steelblue"
                    opacity: 0.3
                    visible: parent.checked
                }
            }
        }
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

        Behavior on opacity {
            OpacityAnimator {
                target: detailsView
            }
        }
    }
}


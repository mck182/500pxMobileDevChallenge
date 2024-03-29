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

Flickable {
    id: flickable
    anchors.fill: parent
    contentWidth: width
    contentHeight: photoGrid.height + (busyThrobber.visible ? busyThrobber.height : 0)
                                    + (errorColumn.visible ? errorColumn.height + 4 * scaleUnit : 0)
    flickableDirection: Flickable.VerticalFlick

    property int lastIndex: -1

    onWidthChanged: {
        relayoutTimer.restart();
    }

    onAtYEndChanged: {
        if (photoGrid.model.canFetchMore()) {
            photoGrid.model.fetchMore();
        }
    }

    // Events compression timer
    Timer {
        id: relayoutTimer
        interval: 100
        repeat: false
        running: false

        onTriggered: {
            photoGrid.currentY = 0;
            photoGrid.currentRowHeight = 5;
            for (var i = 0; i < photoGrid.count; i++) {
                photoGrid.onItemAdded(i, photoGrid.itemAt(i));
            }
        }
    }

    Connections {
        target: rootWindow
        onCurrentIndexChanged: {
            if (rootWindow.currentIndex == -1) {
                scaleAnimation.target = photoGrid.itemAt(flickable.lastIndex)
                scaleAnimation.running = true;
                flickable.lastIndex = -1
                return;
            }

            // Check if the currently zoomed photo is in the view
            // range, if not, scroll the grid view to contain the item
            var currentItemY = photoGrid.itemAt(rootWindow.currentIndex).y;
            var currentItemHeight = photoGrid.itemAt(rootWindow.currentIndex).height;

            if (currentItemY < flickable.contentY) {
                contentY = currentItemY;
            } else if (currentItemY + currentItemHeight > flickable.contentY + flickable.height) {
                contentY = currentItemY - currentItemHeight;
            }

            lastIndex = rootWindow.currentIndex;
        }
    }

    Connections {
        target: tabGroup
        onCurrentChanged: {
            // Reset the positioning properties
            photoGrid.currentY = 0;
            photoGrid.currentRowHeight = 5;

            // Set the feature to the model
            photoGrid.model.feature = tabGroup.current.feature;
        }
    }

    Repeater {
        id: photoGrid

        width: parent.width

        property int currentX: 0
        property int currentY: 0
        property int currentRowHeight: 5
        property var aheadPositions: []
        property var waitingItems: []
        property int needsToWait: 0

        model: PhotosModel

        Component.onCompleted: {
            photoGrid.model.feature = tabGroup.current.feature;
        }

        // This is the way the layout works:
        // * when an item is inserted, it is scaled to a pre-set row height
        // * the view "peeks" at following photos, scaling them by the same ratio
        //   and checking how many following photos will fit the current row
        // * positions for the whole row are calculated
        // * the remaining horizontal space (not covered by photos) is calculated
        //   and distrubuted to the computed geometries
        // * the row's height itself gets scaled so that it can fit the re-scaled
        //   images (after the remaining width distrubition)
        // * in case the images wouldn't fill a whole row, they are hidden instead
        //   and the algorithm waits till there are more images, that way the bottom
        //   edge of the grid is always straight line

        onItemAdded: {
            // If there are items that need to wait,
            // add them to the waiting list, decrease
            // the ahead-waiting-counter and return
            if (needsToWait > 0) {
                waitingItems.push(item)
                needsToWait--;
                return;
            }

            // If any ahead-computed positions exist,
            // simply place the item to the already
            // computed position
            if (aheadPositions.length > 1) {
                // Take the first item and add 5 pixels spacing
                item.x = aheadPositions.shift() + 5;
                item.y = currentY;
                item.height = photoGrid.currentRowHeight
                item.visible = true;

                // With the last item it needs to subtract
                // from the screen width as there is no other
                // aheadPosition to subtract from (it itself
                // is the last one)
                if (aheadPositions.length >= 1) {
                    item.width = aheadPositions[0] - item.x;
                } else {
                    item.width = photoGrid.width - item.x
                }
            } else {
                photoGrid.aheadPositions = [];
                photoGrid.currentX = 0;
                photoGrid.currentY += photoGrid.currentRowHeight + 5;
                item.x = currentX;
                item.y = currentY;
                item.visible = true;

                // Set default height for the row
                photoGrid.currentRowHeight = 60 * scaleUnit;

                var cumulativeWidth = item.size.width * item.ratio;

                if (cumulativeWidth < photoGrid.width) {
                    aheadPositions.push(cumulativeWidth);
                } else {
                    return;
                }

                var innerIndex = index;
                var keepLooking = true;
                var hideRow = false;

                while (keepLooking) {
                    // Get the next item's size from the model
                    var nextPhotoSize = model.sizeForIndex(++innerIndex);

                    // The model does not have enough images to fill this row
                    // so set hideRow to true and bail out
                    if (nextPhotoSize.width === -1) {
                        hideRow = true;
                        break;
                    }

                    // Calculate the ratio for the next photo
                    // with which it needs to be scaled
                    var nextPhotoRatio = photoGrid.currentRowHeight / nextPhotoSize.height;

                    // Check if the next photo would fit in the current row
                    if (cumulativeWidth + (nextPhotoSize.width * nextPhotoRatio) < photoGrid.width) {
                        cumulativeWidth += (nextPhotoSize.width * nextPhotoRatio) + 5;

                        aheadPositions.push(cumulativeWidth);
                    } else {
                        // We cannot place anymore photos in this row
                        keepLooking = false;
                    }
                }

                // If there are not enough photos to fill the whole row,
                // hide the current row until the model gives us more data
                if (hideRow) {
                    // Hide the current item
                    item.visible = false;

                    // How many next added items need to wait; this is a value
                    // of how many photos the model has for the current row
                    needsToWait = aheadPositions.length - 1;

                    // Add the current item to the waiting list
                    waitingItems.push(item);
                    aheadPositions = [];

                    // Return the next-y-position back one row so that the
                    // next row will start where it should
                    photoGrid.currentY -= photoGrid.currentRowHeight + 5;
                    return;
                }

                // Now scale the row height so that the photos fill its width 100%
                var difference = photoGrid.width - cumulativeWidth;

                var newPositions = [];
                for (var i = 0; i < aheadPositions.length; i++) {
                    if (i == 0) {
                        // The first one
                        newPositions[i] = aheadPositions[i] +  difference * (aheadPositions[i] / cumulativeWidth);
                    } else {
                        // First we need to compensate for the previous item's growth
                        var differenceFromPrevious = newPositions[i - 1] - aheadPositions[i - 1];
                        // Then get the proportion of the current image to the cumulative width
                        var relativeDifference = difference * ((aheadPositions[i] - aheadPositions[i - 1]) / cumulativeWidth);

                        newPositions[i] = differenceFromPrevious + aheadPositions[i] + relativeDifference;
                    }
                }

                // Set these newly computed geometries into aheadPositions
                aheadPositions = newPositions;

                // Now scale the row value itself
                var rowRatio = currentRowHeight / cumulativeWidth;
                currentRowHeight = rowRatio * parent.width;

                // Finally set the current item's width and height
                item.height = photoGrid.currentRowHeight;
                item.width = item.size.width * item.ratio;

                photoGrid.height = currentY + currentRowHeight;
            }
        }

        delegate: Item {
            id: photoItem

            property size size: model.size
            property real ratio: photoGrid.currentRowHeight / size.height

            Image {
                id: photoThumbnail
                x: 0
                y: 0
                width: parent.width
                height: parent.height //photoGrid.maxHeight
                fillMode: Image.PreserveAspectFit
                source: width < 400 ? model.imageUrl : model.fullSizeImageUrl
                asynchronous: true
                opacity: 0
                z: flickable.lastIndex == index ? 100 : 1

                OpacityAnimator {
                    target: photoThumbnail
                    duration: 300
                    from: 0
                    to: 1
                    running: photoThumbnail.status == Image.Ready
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    rootWindow.currentIndex = index;
                    zoomEffectImage.source = photoThumbnail.source;
                    zoomEffectRect.x = photoItem.x;
                    zoomEffectRect.y = photoItem.y;
                    zoomEffectRect.width = photoItem.width;
                    zoomEffectRect.height = photoItem.height;
                    zoomEffectRect.visible = true;

                    zoomEffect.start();
                }
            }
        }
    }

    Rectangle {
        id: zoomEffectRect
        border.width: 1
        border.color: "#000"
        color: "#000"
        visible: false

        Image {
            id: zoomEffectImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
        }

        ParallelAnimation {
            id: zoomEffect
            running: false

            PropertyAnimation {
                target: zoomEffectRect
                properties: "y"
                to: flickable.contentY
            }

            PropertyAnimation {
                target: zoomEffectRect
                properties: "x"
                to: flickable.contentX
            }

            NumberAnimation {
                target: zoomEffectRect
                property: "width"
                to: rootWindow.width
            }

            NumberAnimation {
                target: zoomEffectRect
                property: "height"
                to: rootWindow.height
            }

            OpacityAnimator {
                target: zoomEffectRect
                from: 1
                to: 0
            }
        }
    }

    BusyIndicator {
        id: busyThrobber
        anchors.top: photoGrid.bottom
        anchors.horizontalCenter: photoGrid.horizontalCenter
        width: 64
        height: 64
        running: photoGrid.model.hasActiveRequest
        visible: running // Hide it when not running
    }

    ColumnLayout {
        id: errorColumn
        anchors.top: photoGrid.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right

        visible: photoGrid.model.connectionError !== ""

        Text {
            Layout.fillWidth: true
            color: "#fff"
            text: photoGrid.model.connectionError
            horizontalAlignment: Text.AlignHCenter

            // This is to avoid binding loop errors
            Component.onCompleted: {
                font.pointSize = 1.4 * font.pointSize;
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "Retry"
            onClicked: photoGrid.model.retryFetch();
        }
    }

    ScaleAnimator {
        id: scaleAnimation
        from: 1.4
        to: 1
        easing.type: Easing.OutBack
        duration: 600
    }
}

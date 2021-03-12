import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import Qt.labs.settings 1.0

Item{
    id: root
    anchors.fill: parent

    property bool isOpened: false

    /* the index of the currently selected property by which the tasks are sorted:
        0 - Deadline
        1 - Name
        2 - Priority
    */
    property int index: 0

    function open(){
        if (!isOpened) PopupUtils.open(component, header)
    }

    Settings{
        id: settings
        category: "SortMode"
        property alias index: root.index
    }

    Component{
        id: component
        Popover{
            id: popover
            width: 0.8*root.width
            Rectangle{
                id: back
                anchors{
                    top: label.top
                    bottom: selector.bottom
                    bottomMargin: -units.gu(1)
                }
                width: parent.width
                color: colors.currentHeader
                Rectangle{
                    anchors.fill: parent
                    color: colors.currentBackground
                    opacity: 0.1
                }
                Rectangle{
                    anchors.fill: parent
                    color: "#00000000"
                    radius: units.gu(1)
                    border{
                        width: units.gu(0.25)
                        color: colors.currentHeader
                    }
                }
            }
            Label{
                id: label
                anchors.horizontalCenter: parent.horizontalCenter
                height: units.gu(4)
                verticalAlignment: Label.AlignVCenter
                text: i18n.tr("Sort tasks by")
            }

            OptionSelector{
                id: selector
                anchors{
                    top: label.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                expanded: true
                model: [i18n.tr("Deadline"),i18n.tr("Name"),i18n.tr("Priority")]
                onSelectedIndexChanged: root.index = selectedIndex
                Component.onCompleted: selectedIndex = root.index
            }
            onVisibleChanged: root.isOpened = visible
        }
    }
}


import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Qt.labs.settings 1.0

Item {
    id: root

    property bool expanded: false
    anchors{
        top: parent.top
        left: parent.left
        right: parent.right
    }
    enabled: expanded

    states: [
        State{
            name: "collapsed"
            when: !expanded
            PropertyChanges {
                target: root
                height: divider.height
            }
        },
        State{
            name: "expanded"
            when: expanded
            PropertyChanges {
                target: root
                height: selector.itemHeight + units.gu(2) + divider.height
            }
        }

    ]

    transitions: Transition {
        from: "collapsed"
        to: "expanded"
        reversible: true
        PropertyAnimation{
            target: root
            property: "height"
            duration: 400
        }
    }

    /* the index of the currently selected property by which the tasks are sorted:
        0 - Deadline
        1 - Name
        2 - Priority
    */
    property int index: 0

    property var ascending: [true,true,false]

    Settings{
        id: settings
        category: "SortMode"
        property alias index: root.index
    }

    Rectangle{
        id: back
        anchors.fill: parent
        color: colors.currentHeader
        opacity: 0.8
    }

    Divider{
        id: divider
        anchors.bottom: parent.bottom
    }

    Label{
        id: label
        anchors{
            left: parent.left
            bottom: divider.top
            leftMargin: units.gu(2)
        }
        height: selector.itemHeight + units.gu(2)
        verticalAlignment: Label.AlignVCenter
        text: i18n.tr("Sort tasks by")
    }

    OptionSelector{
        id: selector
        anchors{
            top: divider.top
            left: label.right
            right: btAscending.left
            margins: units.gu(2)
            topMargin: - (itemHeight + units.gu(1))
        }
        y: units.gu(1)
        containerHeight: 3*itemHeight
        model: [i18n.tr("Deadline"),i18n.tr("Name"),i18n.tr("Priority")]
        onSelectedIndexChanged: root.index = selectedIndex
        Component.onCompleted: selectedIndex = root.index
        onFocusChanged: if (!focus) currentlyExpanded = false
        onEnabledChanged: if (!enabled) currentlyExpanded = false
        delegate: OptionSelectorDelegate{
            Rectangle{
                anchors.fill: parent
                color: colors.currentHeader
                opacity: 0.5
            }
            text: " "
            Label{
                anchors{
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(1)
                }
                text: modelData
            }
        }
    }

    Button{
        id: btAscending
        anchors{
            right: parent.right
            bottom: divider.top
            rightMargin: units.gu(2)
            bottomMargin: units.gu(1)
        }
        width: units.gu(5)
        height: selector.itemHeight
        y: units.gu(1)
        Rectangle{
            anchors.fill: parent
            color: colors.currentHeader
            opacity: 0.5
        }

        Icon{
            anchors.centerIn: parent
            height: 0.8*parent.width
            source: ascending[index] ? "../../assets/ascending.svg" : "../../assets/descending.svg"
            color: theme.palette.normal.baseText
        }
        onClicked: {
            ascending[index] = !ascending[index]
            ascendingChanged()
        }
    }

}

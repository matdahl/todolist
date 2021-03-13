import QtQuick 2.7
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0

Item {
    id: root

    /* the index of the currently selected property by which the tasks are sorted:
        0 - Deadline
        1 - Name
        2 - Priority
    */
    property int index: 0

    property var ascending: [true,true,false]

    anchors{
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: units.gu(6)

    Label{
        id: label
        anchors{
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }
        text: i18n.tr("Sort tasks by:")
    }

    OptionSelector{
        id: selector
        anchors{
            left: label.right
            right: btAscending.left
            margins: units.gu(1)
        }
        y: units.gu(1)
        containerHeight: 3*itemHeight
        model: [i18n.tr("Deadline"),i18n.tr("Name"),i18n.tr("Priority")]
        onSelectedIndexChanged: root.index = selectedIndex
        Component.onCompleted: selectedIndex = root.index
    }

    Button{
        id: btAscending
        anchors{
            right: parent.right
            margins: units.gu(1)
        }
        width: units.gu(4)
        height: selector.itemHeight
        y: units.gu(1)
        Icon{
            anchors.centerIn: parent
            height: 0.8*parent.width
            source: ascending[index] ? "../../assets/ascending.svg" : "../../assets/descending.svg"
            color: theme.palette.normal.baseText
        }
        onClicked: {
            print("click")
            print(ascending[index])
            ascending[index] = !ascending[index]
            print(ascending[index])
            ascendingChanged()
        }
    }

    Settings{
        id: settings
        category: "SortMode"
        property alias index: root.index
    }
}

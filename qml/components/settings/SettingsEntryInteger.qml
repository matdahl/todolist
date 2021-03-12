import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

import ".."

/*
 * An item for the settings list which pushs a new subpage to the stack if clicked on
 */
ListItem{
    id: root

    // the text to display on the item
    property string text: ""

    // states whether the switcher was checked
    property alias value: manipulate.value
    property alias minvalue: manipulate.minvalue
    property alias maxvalue: manipulate.maxvalue

    Label{
        id: label
        anchors{
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            margins: units.gu(2)
        }
        text: root.text
    }

    IntegerManipulate{
        id: manipulate
        anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
            margins: units.gu(2)
        }
    }

}

import QtQuick 2.7
import Ubuntu.Components 1.3

Row{
    id: root
    height: units.gu(4)

    property int value: 0
    property int minvalue: 0
    property int maxvalue: 10

    Button{
        id: btDecPhase
        height: parent.height
        width: height
        text: "-"
        color: UbuntuColors.red
        enabled: value>minvalue
        onClicked: value -= 1
    }
    TextField{
        id: textField
        height: parent.height
        width: root.width-btIncPhase.width-btDecPhase.width
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        readOnly: true
        text: value
    }
    Button{
        id: btIncPhase
        height: parent.height
        width: height
        text: "+"
        color: UbuntuColors.green
        enabled: value<maxvalue
        onClicked: value += 1
    }
}

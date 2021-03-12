import QtQuick 2.7
import Ubuntu.Components 1.3

Rectangle{
    id: root
    height: units.gu(3)
    width:  units.gu(12)

    radius: units.gu(1)

    property int value: 0
    property int minvalue: 0
    property int maxvalue: 10

    /* ----- background ---- */
    Rectangle{
        anchors{
            top: parent.top
            left: parent.left
            right: parent.horizontalCenter
            bottom: parent.bottom
        }
        radius: units.gu(1)
        color: enabled ? theme.palette.normal.negative : theme.palette.disabled.negative
        enabled: value > minvalue
        Label{
            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
                margins: units.gu(1)
            }
            text: "-"
            color: enabled ? theme.palette.normal.negativeText : theme.palette.disabled.negativeText
        }
        MouseArea{
            id: mouseDec
            anchors.fill: parent
            onClicked: value -= 1
        }
        Rectangle{
            anchors.verticalCenter: parent.verticalCenter
            x: (height-width)/2
            height: parent.width
            width:  parent.height
            rotation: 90
            radius: units.gu(1)
            opacity: 0.6
            visible: mouseDec.pressed
            gradient: Gradient{
                GradientStop{
                    position: 1
                    color: theme.palette.normal.base
                }
                GradientStop{
                    position: 0
                    color: "#00000000"
                }
            }
        }
    }
    Rectangle{
        anchors{
            top: parent.top
            left: parent.horizontalCenter
            right: parent.right
            bottom: parent.bottom
        }
        radius: units.gu(1)
        color: enabled ? theme.palette.normal.positive : theme.palette.disabled.positive
        enabled: value < maxvalue
        Label{
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                margins: units.gu(1)
            }
            text: "+"
            color: enabled ? theme.palette.normal.positiveText : theme.palette.disabled.positiveText
        }
        MouseArea{
            id: mouseInc
            anchors.fill: parent
            onClicked: value += 1
        }
        Rectangle{
            anchors.verticalCenter: parent.verticalCenter
            x: (height-width)/2
            height: parent.width
            width:  parent.height
            rotation: 90
            radius: units.gu(1)
            opacity: 0.6
            visible: mouseInc.pressed
            gradient: Gradient{
                GradientStop{
                    position: 0
                    color: theme.palette.normal.base
                }
                GradientStop{
                    position: 1
                    color: "#00000000"
                }
            }
        }
    }

    /* ----- value view ----- */
    Rectangle{
        anchors{
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: units.gu(7)
        radius: units.gu(1)
        color: theme.palette.normal.background
        border{
            width: units.gu(0.25)
            color: theme.palette.normal.base
        }

        Label{
            anchors.centerIn: parent
            text: root.value
        }
    }

    /*Button{
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
    }*/
}

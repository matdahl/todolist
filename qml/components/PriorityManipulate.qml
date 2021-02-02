import QtQuick 2.7
import Ubuntu.Components 1.3

Item{
    id: root

    property int maximalPriority: 6
    onMaximalPriorityChanged: if (maximalPriority<1) maximalPriority = 1

    property color color
    property int value: maximalPriority/2
    onValueChanged: {
        var half = (maximalPriority+1)/2
        if (value<2){
            color = Qt.rgba(1,0,0,1)
        } else if (value <= half){
            color = Qt.rgba(1,value/half,0,1)
        } else {
            color = Qt.rgba(2-value/half,1,0,1)
        }
    }

    property int spacing: units.gu(0.25)


    Rectangle{
        id: back
        anchors{
            fill: parent
            topMargin: units.gu(0.5)
            bottomMargin: units.gu(0.5)
        }
        radius: height/2
        color: theme.palette.normal.foreground

        Label{
            text: "+"
            font.bold: true
            color: value<maximalPriority ? theme.palette.normal.foregroundText : theme.palette.disabled.foregroundText
            anchors{
                right: back.right
                verticalCenter: back.verticalCenter
            }
            width: back.radius
            horizontalAlignment: Label.AlignHCenter
        }
        Label{
            text: "-"
            font.bold: true
            color: value>0 ? theme.palette.normal.foregroundText : theme.palette.disabled.foregroundText
            anchors{
                left: back.left
                verticalCenter: back.verticalCenter
            }
            width: back.radius
            horizontalAlignment: Label.AlignHCenter
        }
    }

    Rectangle{
        id: inner
        anchors{
            centerIn: parent
        }
        height: 0.75*back.height
        width: back.width - 2*back.radius
        color: theme.palette.normal.base
        Row{
            padding: root.spacing
            spacing: root.spacing
            Repeater{
                model: value
                Rectangle{
                    height:  inner.height - 2*root.spacing
                    width: (inner.width - (maximalPriority+1)*root.spacing)/maximalPriority
                    color: root.color
                }
            }
        }
    }

    MouseArea{
        id: mouseInc
        anchors{
            top: parent.top
            left: parent.horizontalCenter
            right: parent.right
            bottom: parent.bottom
        }
        onClicked: if (value<maximalPriority) value += 1
    }

    MouseArea{
        id: mouseDec
        anchors{
            top: parent.top
            left: parent.left
            right: parent.horizontalCenter
            bottom: parent.bottom
        }
        onClicked: if (value>0) value -= 1
    }
}

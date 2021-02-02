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

    property int spacing: 2


    Rectangle{
        id: back
        anchors.fill: parent
        radius: width/2
        color: theme.palette.normal.foreground

        Rectangle{
            id: inner
            anchors{
                fill: parent
                margins: 0.125*width
                topMargin:  back.radius
                bottomMargin: back.radius
            }
            color: theme.palette.normal.base
            Column{
                anchors.bottom: inner.bottom
                padding: root.spacing
                spacing: root.spacing
                Repeater{
                    model: value
                    Rectangle{
                        width:  inner.width - 2*root.spacing
                        height: (inner.height - (maximalPriority+1)*root.spacing)/maximalPriority
                        color: root.color
                    }
                }
            }
        }
        Label{
            text: "+"
            font.bold: true
            color: theme.palette.normal.foregroundText
            anchors{
                top: back.top
                horizontalCenter: back.horizontalCenter
            }
            height: back.radius
            verticalAlignment: Label.AlignVCenter
        }
        Label{
            text: "-"
            font.bold: true
            color: theme.palette.normal.foregroundText
            anchors{
                bottom: back.bottom
                horizontalCenter: back.horizontalCenter
            }
            height: back.radius
            verticalAlignment: Label.AlignVCenter
        }
    }


    MouseArea{
        id: mouseInc
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.verticalCenter
        }
        onClicked: if (value<maximalPriority) value += 1
    }

    MouseArea{
        id: mouseDec
        anchors{
            top: parent.verticalCenter
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onClicked: if (value>0) value -= 1
    }
}

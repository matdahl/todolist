import QtQuick 2.7
import Ubuntu.Components 1.3

Item{
    id: root

    property int   maxValue: 3
    property int   value: 0
    property color barColor: "#00ff00"

    onMaxValueChanged: calcColor()
    onValueChanged:    calcColor()

    function calcColor(){
        var half = (maxValue+1)/2
        if (maxValue<=1 || maxValue===value){
            barColor = Qt.rgba(0,1,0,1)
        } else {
            if (value<2){
                barColor = Qt.rgba(1,0,0,1)
            } else if (value <= half){
                barColor = Qt.rgba(1,value/half,0,1)
            } else {
                barColor = Qt.rgba(2-value/half,1,0,1)
            }
        }
    }

    /* ----- geometry parameters ----- */
    height: units.gu(6)
    width: 0.5*height

    property real totalHeight: 0.8   * height
    property real totalWidth:  0.25  * height
    property real totalRadius: 0.125 * height
    property real borderWidth: 0.2   * totalWidth
    property real barSpacing:  (0.2 * borderWidth>2) ? 0.2 * borderWidth : 2
    property real barHeight:   (totalHeight-2*borderWidth-(maxValue-1)*barSpacing)/maxValue
    property real barWidth:    totalWidth - 2*borderWidth
    property real barRadius:   totalRadius - borderWidth

    Rectangle{
        id: back
        color: UbuntuColors.ash
        anchors.centerIn: parent
        height: totalHeight
        width:  totalWidth
        radius: totalRadius
    }

    Rectangle{
        id: lowestBar
        visible: value>0
        height: barHeight
        width:  barWidth
        anchors{
            bottom: back.bottom
            margins: borderWidth
            horizontalCenter: parent.horizontalCenter
        }
        radius: barRadius
        color: barColor
        Rectangle{
            anchors{
                left:  parent.left
                right: parent.right
                top:   parent.top
            }
            height: 0.5*parent.height
            color: parent.color
        }
    }

    Column{
        anchors{
            left: back.left
            bottom: lowestBar.top
            leftMargin: borderWidth
            bottomMargin: barSpacing
        }

        spacing: barSpacing
        Repeater{
            model: value<1 ? 0 : value>maxValue-2 ? maxValue-2 : value-1
            Rectangle{
                height: barHeight
                width:  barWidth
                color:  barColor
            }
        }
    }

    Rectangle{
        id: highestBar
        visible: value >= maxValue
        height: barHeight
        width:  barWidth
        anchors{
            top: back.top
            margins: borderWidth
            horizontalCenter: parent.horizontalCenter
        }
        radius: barRadius
        color: barColor
        Rectangle{
            anchors{
                left:  parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: parent.height - parent.radius
            color: parent.color
        }
    }


    Rectangle{
        id: border
        color: "#00000000"
        anchors.fill: back
        radius: back.radius
        border{
            width: borderWidth
            color: UbuntuColors.graphite
        }
    }
}

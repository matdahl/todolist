import QtQuick 2.7
import Ubuntu.Components 1.3

Item{
    id: root

    width: 0.5*height
    property int score: 0
    property color barColor: "#00ff00"
    onScoreChanged: {
        if (score<0){
            score = 0
        } else if (score > 3){
            score = 3
        }
        barColor = (score==1) ? "#ff0000" : (score==2) ? "#ffff00" : "#00ff00"
    }

    Rectangle{
        id: back
        color: UbuntuColors.ash
        anchors.centerIn: parent
        height: 0.8*parent.height
        width:  0.5*parent.width
        radius: 0.2*height
    }

    Rectangle{
        id: bar1
        visible: root.score>0
        height: 0.3*(back.height - 2.4*back.border.width)
        width:  back.width - 2.4*back.border.width
        x: back.x + 1.2*back.border.width
        y: back.y + 1.2*back.border.width + 0.7*(back.height - 2.4*back.border.width)
        radius: back.radius - 1.2*back.border.width
        color: root.barColor
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

    Rectangle{
        id: bar2
        visible: root.score>1
        height: 0.3*(back.height - 2.4*back.border.width)
        width:  back.width - 2.4*back.border.width
        x: back.x + 1.2*back.border.width
        y: back.y + 1.2*back.border.width + 0.35*(back.height - 2.4*back.border.width)
        color: root.barColor
    }

    Rectangle{
        id: bar3
        visible: root.score>2
        height: 0.3*(back.height - 2.4*back.border.width)
        width:  back.width - 2.4*back.border.width
        x: back.x + 1.2*back.border.width
        y: back.y + 1.2*back.border.width
        radius: back.radius - 1.2*back.border.width
        color: root.barColor
        Rectangle{
            anchors{
                left:   parent.left
                right:  parent.right
                bottom: parent.bottom
            }
            height: 0.5*parent.height
            color: parent.color
        }
    }
    Rectangle{
        id: border
        color: "#00000000"
        anchors.fill: back
        radius: back.radius
        border{
            width: 0.1*root.width
            color: UbuntuColors.graphite
        }
    }
}

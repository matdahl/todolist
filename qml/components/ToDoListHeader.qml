import QtQuick 2.7
import Ubuntu.Components 1.3

Item{
    id: root
    width: parent.width
    height: units.gu(4)

    state: "priority"
    states: [
        State{
            name: "priority"
            PropertyChanges {target: rectSelected; x: lbPriority.x}
        },
        State{
            name: "title"
            PropertyChanges {target: rectSelected; x: lbTitle.x}
        },
        State{
            name: "due"
            PropertyChanges {target: rectSelected; x: lbDue.x}
        }
    ]
    transitions: [
        Transition {
            from: "due"
            to: "title"
            reversible: true
            PropertyAnimation{
                target: rectSelected
                property: "x"
                duration: 300
            }
        },
        Transition {
            from: "priority"
            to: "title"
            reversible: true
            PropertyAnimation{
                target: rectSelected
                property: "x"
                duration: 300
            }
        },
        Transition {
            from: "due"
            to: "priority"
            reversible: true
            PropertyAnimation{
                target: rectSelected
                property: "x"
                duration: 600
            }
        }
    ]

    /* --- titles --- */

    Label{
        id: lbDue
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        width: parent.width/3
        horizontalAlignment: Label.AlignHCenter
        text: i18n.tr("due")
        MouseArea{
            anchors.fill: parent
            onClicked: root.state = "due"
        }
    }
    Rectangle{
        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: lbDue.right
        }
        height: parent.height - units.gu(2)
        width: units.gu(0.25)
        color: theme.palette.normal.base
    }
    Label{
        id: lbTitle
        anchors{
            verticalCenter: parent.verticalCenter
            left: lbDue.right
            right: lbPriority.left
        }
        horizontalAlignment: Label.AlignHCenter
        text: i18n.tr("task")
        MouseArea{
            anchors.fill: parent
            onClicked: root.state = "title"
        }
    }
    Rectangle{
        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: lbPriority.left
        }
        height: parent.height - units.gu(2)
        width: units.gu(0.25)
        color: theme.palette.normal.base
    }
    Label{
        id: lbPriority
        anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        width: parent.width/3
        horizontalAlignment: Label.AlignHCenter
        text: i18n.tr("priority")
        MouseArea{
            anchors.fill: parent
            onClicked: root.state = "priority"
        }
    }

    Rectangle{
        id: rectSelected
        color: "#00000000"
        height: parent.height
        width: 0.333*parent.width
        border{
            width: units.gu(0.25)
            color: theme.palette.normal.focus
        }
        Rectangle{
            anchors.fill: parent
            opacity: 0.2
            color: parent.border.color
        }
    }
}

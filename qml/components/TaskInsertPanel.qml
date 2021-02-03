import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3

Item{
    id: root
    anchors{
        left: parent.left
        right: parent.right
    }
    clip: true
    property int headerHeight: units.gu(4)
    property int contentHeight: body.height
    property bool expanded: false
    property bool enabled: false
    onEnabledChanged: if (!enabled) expanded = false

    property int spacing: units.gu(1)
    property int padding: units.gu(1)

    signal add()

    // the current date of the task
    property alias title: inputTitle.text
    property alias priority: inputPriority.value
    property alias hasDue: switchDue.checked
    property alias due: btDate.due


    states: [
        State{
            name: "expanded"
            when: enabled && expanded
            PropertyChanges {
                target: root
                height: headerHeight + contentHeight
            }
        },
        State{
            name: "collapsed"
            when: enabled && !expanded
            PropertyChanges {
                target: root
                height: headerHeight
            }
        },
        State{
            name: "disabled"
            when: !enabled
            PropertyChanges {
                target: root
                height: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "expanded"
            to: "collapsed"
            reversible: true
            PropertyAnimation{
                property: "height"
                duration: 400
            }
        },
        Transition {
            from: "disabled"
            to: "*"
            reversible: true
            PropertyAnimation{
                property: "height"
                duration: 200
            }
        }
    ]

    /* ---- body ---- */
    Rectangle{
        id: body
        anchors{
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: units.gu(2*4 + 2 + 4 )
        color: colors.currentBackground
        Rectangle{
            anchors.fill: parent
            color: theme.palette.normal.positive
            opacity: 0.1
        }
        Rectangle{
            anchors{
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: units.gu(0.25)

            color: theme.palette.normal.positive
            opacity: 0.8
        }

        TextField{
            id: inputTitle
            anchors{
                top: parent.top
                left: parent.left
                right: btInsert.left
                margins: root.spacing
                leftMargin: root.padding
            }

            placeholderText: i18n.tr("insert title") + " ..."
        }

        Label{
            id: lbDeadline
            anchors{
                top: inputTitle.bottom
                left: btDate.left
                margins: spacing
                topMargin: root.spacing
            }
            text: i18n.tr("Deadline")+":"
        }

        Switch{
            id: switchDue
            anchors{
                verticalCenter: lbDeadline.verticalCenter
                right: btDate.right
            }
        }

        Label{
            anchors{
                top: inputTitle.bottom
                left: inputPriority.left
                topMargin: root.spacing
            }
            text: i18n.tr("Priority")+":"
        }


        Button{
            id: btDate
            property date due: new Date()
            anchors{
                top: inputTitle.bottom
                left: parent.left
                right: inputPriority.left
                topMargin: spacing + units.gu(3)
                leftMargin: padding
                rightMargin: spacing
            }
            enabled: hasDue
            text: hasDue ? Qt.formatDate(due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
            onClicked: PickerPanel.openDatePicker(btDate,"due","Days|Months|Years")
        }

        PriorityManipulate{
            id: inputPriority
            anchors{
                top: btDate.top
                right: inputTitle.right
                bottom: btDate.bottom
            }
            maximalPriority: 3
            width: units.gu(12)
        }

        Button{
            id: btInsert
            anchors{
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                margins: root.spacing
                rightMargin: root.padding
            }
            enabled: title.length>0
            color: UbuntuColors.orange
            width: lbInsert.width> units.gu(6) ? lbInsert.width + units.gu(2) : units.gu(8)
            Label{
                id: lbInsert
                anchors.centerIn: parent
                text: i18n.tr("Insert")
            }
            onClicked: {
                add()
                title = ""
            }
        }
    }

    /* ---- header ---- */
    Rectangle{
        id: header
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: headerHeight
        color: colors.currentBackground
        Rectangle{
            anchors.fill: parent
            color: theme.palette.normal.positive
            opacity: 0.5
        }
        Icon{
            anchors{
                verticalCenter: parent.verticalCenter
                right: lbHeader.left
            }
            name: "add"
            height: 0.5* parent.height
            color: theme.palette.normal.backgroundText
        }
        Label{
            id: lbHeader
            anchors.centerIn: parent
            text: " "+i18n.tr("new task")
        }

        Icon{
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(2)
            }
            height: units.gu(3)
            name: expanded ? "up" : "down"
            color: theme.palette.normal.backgroundText
        }

        MouseArea{
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }
}

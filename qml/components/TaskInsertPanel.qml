import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3

Item{
    id: root
    anchors{
        left: parent.left
        right: parent.right
    }
    height: headerHeight + contentHeight
    property int headerHeight: units.gu(4)
    property int contentHeight: body.height
    property bool expanded: false

    property int spacing: units.gu(2)

    signal add()

    // the current date of the task
    property alias title: inputTitle.text
    property alias priority: inputPriority.value
    property alias hasDue: switchDue.checked
    property alias due: btDate.due


    states: [
        State{
            name: "expanded"
            when: expanded
            PropertyChanges {
                target: root
                y: parent.height - height
            }
        },
        State{
            name: "collapsed"
            when: !expanded
            PropertyChanges {
                target: root
                y: parent.height - headerHeight
            }
        }
    ]
    transitions: Transition {
        from: "expanded"
        to: "collapsed"
        reversible: true
        PropertyAnimation{
            property: "y"
            duration: 400
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
        color: colors.currentHeader
        Rectangle{
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 1
            color: theme.palette.normal.base
        }
        Label{
            anchors.centerIn: parent
            text: i18n.tr("New task")
            font.bold: true
        }

        Icon{
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(2)
            }
            height: units.gu(3)
            name: expanded ? "down" : "up"
            color: theme.palette.normal.backgroundText
        }

        MouseArea{
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    /* ---- body ---- */
    Rectangle{
        id: body
        anchors{
            top: header.bottom
            left: parent.left
            right: parent.right
        }

        height: units.gu(3*4 + 2 + 5*2 )
        color: colors.currentBackground
        Rectangle{
            anchors.fill: parent
            color: colors.currentHeader
            opacity: 0.2
        }

        TextField{
            id: inputTitle
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
                margins: root.spacing
            }

            placeholderText: i18n.tr("insert title") + " ..."
        }

        Label{
            anchors{
                top: inputTitle.bottom
                left: parent.left
                right: inputPriority.right
                margins: root.spacing
            }
            text: i18n.tr("Priority")+":"
        }

        Label{
            id: lbDeadline
            anchors{
                top: inputTitle.bottom
                left: inputPriority.right
                right: inputPriority.right
                margins: spacing
            }
            text: i18n.tr("Deadline")+":"
        }

        Switch{
            id: switchDue
            anchors{
                verticalCenter: lbDeadline.verticalCenter
                right: parent.right
                margins: spacing
            }
        }


        PriorityManipulate{
            id: inputPriority
            anchors{
                top: btDate.top
                left: parent.left
                bottom: btDate.bottom
                leftMargin: root.spacing
            }
            maximalPriority: 3
            width: units.gu(16)
        }

        Button{
            id: btDate
            property date due: new Date()
            anchors{
                top: inputTitle.bottom
                left: inputPriority.right
                right: parent.right
                margins: spacing
                topMargin: 2*spacing + units.gu(2)
            }
            enabled: hasDue
            text: hasDue ? Qt.formatDate(due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
            onClicked: PickerPanel.openDatePicker(btDate,"due","Days|Months|Years")
        }

        Button{
            id: btInsert
            anchors{
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(2)
            }
            enabled: title.length>0 && sections.selectedIndex>0
            height: body.lineHeight
            text: i18n.tr("Insert")
            color: UbuntuColors.orange
            onClicked: add()
        }
    }
}

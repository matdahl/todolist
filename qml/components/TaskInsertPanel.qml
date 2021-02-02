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
    property int contentHeight: units.gu(11)
    property bool expanded: false


    property alias hasDue: switchDue.checked
    property date  due: new Date()


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
            text: i18n.tr("Insert task")
            font.bold: true
            Icon{
                anchors{
                    top: parent.top
                    right: parent.left
                    bottom: parent.bottom
                    rightMargin: units.gu(1)
                }
                name: "add"
                color: theme.palette.normal.backgroundText
            }
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
            bottom: parent.bottom
        }
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
                right: inputPriority.left
                margins: units.gu(1)
            }

            placeholderText: i18n.tr("insert title") + " ..."
        }

        Label{
            id: lbDue
            anchors{
                verticalCenter: btDate.verticalCenter
                left: parent.left
                leftMargin: units.gu(2)
            }
            text: i18n.tr("due") +":"
        }

        Switch{
            id: switchDue
            anchors{
                verticalCenter: btDate.verticalCenter
                left: lbDue.right
                leftMargin: units.gu(1)
            }
        }

        Button{
            id: btDate
            property alias due: root.due
            anchors{
                top: inputTitle.bottom
                left: switchDue.right
                right: inputPriority.left
                margins: units.gu(1)
            }
            enabled: hasDue
            text: hasDue ? Qt.formatDate(due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
            onClicked: PickerPanel.openDatePicker(btDate,"due","Days|Months|Years")
        }

        PriorityManipulate{
            id: inputPriority
            anchors{
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(1)
            }
            width: units.gu(4)
        }
    }
}

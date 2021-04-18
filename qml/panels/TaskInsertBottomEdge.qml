import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Pickers 1.3

import "../components"

BottomEdge{
    id: bottomEdge
    hint.status: BottomEdgeHint.Active
    hint.text: i18n.tr("new task")
    hint.iconName: "add"
    onCollapseStarted: hint.status = BottomEdgeHint.Active

    property string title: ""
    property string category: "NONE"
    property int    priority: settings.defaultPriority
    property bool   hasDue:   settings.hasDueByDefault
    property bool   hasRepetition: settings.hasRepetitionByDefault
    property string repetitionUnit: settings.defaultRepetitionUnit
    property int    repetitionCount: settings.defaultRepetitionCount
    property date   due

    function insert(){
        models.newTodo({
                         itemid: -1,
                         title: title,
                         category: category,
                         priority: priority,
                         due: hasDue ? due.setHours(0,0,0,0) : 0,
                         repetition: hasRepetition ? repetitionUnit : "-",
                         repetitionCount: repetitionCount
        })
    }

    contentComponent: Rectangle {
        height: root.height - header.height
        width:  root.width
        color: colors.currentBackground
        Component.onCompleted: {
            reset()
            bottomEdge.commitStarted.connect(reset)
        }

        function reset(){
            // reset variables in bottomEdge
            bottomEdge.title = ""
            bottomEdge.category = listPanel.selectedCategory
            bottomEdge.priority = settings.defaultPriority
            bottomEdge.hasDue = settings.hasDueByDefault
            var d = new Date()
            bottomEdge.due = new Date(d.setDate(d.getDate()+settings.defaultDueOffset))

            bottomEdge.hasRepetition   = settings.hasRepetitionByDefault
            bottomEdge.repetitionUnit  = settings.defaultRepetitionUnit
            bottomEdge.repetitionCount = settings.defaultRepetitionCount

            // reset values in components
            inputTitle.text = bottomEdge.title
            inputPriority.maximalPriority = settings.maximalPriority
            inputPriority.value           = bottomEdge.priority
            switchDue.checked = bottomEdge.hasDue
            catSelect.currentlyExpanded = false
            var i=0
            for (i=0;i<catSelect.model.length-1;i++)
                if (catSelect.model[i]=== bottomEdge.category)
                    break
            catSelect.selectedIndex = i
            switchRepetition.checked = bottomEdge.hasRepetition

            btRepetition.interval = bottomEdge.repetitionUnit
            btRepetition.intervalCount = bottomEdge.repetitionCount

        }

        PageHeader{
            id: header
            title: i18n.tr("New Task")
            StyleHints{backgroundColor:colors.currentHeader}
            MouseArea{
                anchors.fill: parent
                onClicked: bottomEdge.collapse()
            }
        }
        ScrollView{
            id: scroll
            property int margin: units.gu(4)
            anchors{
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            Column{
                id: col
                width: scroll.width
                spacing: units.gu(2)
                padding: scroll.margin

                Label{
                    text: i18n.tr("Category") +":"
                }
                OptionSelector{
                    id: catSelect
                    width: col.width - 2*col.padding
                    model: models.unmutedCategoriesNameList.concat(models.catNameOther)
                    containerHeight: 4*itemHeight
                    onSelectedIndexChanged: bottomEdge.category = model[selectedIndex]
                }
                Label{
                    text: i18n.tr("Task name") +":"
                }
                TextField{
                    id: inputTitle
                    width: col.width - 2*col.padding
                    placeholderText: i18n.tr("insert task name") + " ..."
                    onTextChanged: bottomEdge.title = text
                }
                Label{
                    text: i18n.tr("Priority") +":"
                }
                PriorityManipulate{
                    id: inputPriority
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(8)
                    height: units.gu(4)
                    Component.onCompleted: value = settings.defaultPriority
                    onValueChanged: bottomEdge.priority = value
                }
                Label{
                    text: i18n.tr("Deadline") +":"
                }
                Row{
                    width: col.width - 2*col.padding
                    spacing: units.gu(4)
                    Switch{
                        id: switchDue
                        anchors.verticalCenter: btDue.verticalCenter
                        onCheckedChanged: bottomEdge.hasDue = checked
                    }
                    Button{
                        id: btDue
                        width: parent.width - switchDue.width - 2*parent.spacing
                        enabled: bottomEdge.hasDue
                        text: enabled ? Qt.formatDate(bottomEdge.due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
                        onClicked: PickerPanel.openDatePicker(bottomEdge,"due","Days|Months|Years")
                    }
                }
                Label{
                    text: i18n.tr("Repetition") +":"
                }
                Row{
                    width: col.width - 2*col.padding
                    spacing: units.gu(4)
                    Switch{
                        id: switchRepetition
                        anchors.verticalCenter: btRepetition.verticalCenter
                        onCheckedChanged: bottomEdge.hasRepetition = checked
                    }
                    RepetitionIntervalButton{
                        id: btRepetition
                        width: parent.width - switchRepetition.width - 2*parent.spacing
                        enabled: bottomEdge.hasRepetition
                        onIntervalChanged: bottomEdge.repetitionUnit = interval
                        onIntervalCountChanged: bottomEdge.repetitionCount = intervalCount
                    }
                }


                Divider{
                    anchors{
                        left: parent.left
                        right: parent.right
                        margins: col.padding
                    }
                }

                Row{
                    spacing: units.gu(2)
                    width: col.width - 2*col.padding
                    Button{
                        width: parent.width/2 - units.gu(1)
                        text: i18n.tr("Cancel")
                        onClicked: bottomEdge.collapse()
                    }
                    Button{
                        width: parent.width/2 - units.gu(1)
                        text: i18n.tr("Insert")
                        color: UbuntuColors.orange
                        onClicked: {
                            bottomEdge.insert()
                            bottomEdge.collapse()
                        }
                    }
                }
            }
        }
    }
}

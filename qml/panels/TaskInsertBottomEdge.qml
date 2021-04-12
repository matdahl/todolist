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

    property string selectedCategory: listPanel.selectedCategoryIndex>0 ? listPanel.selectedCategory : i18n.tr("other")

    property string title: ""
    property string category: "NONE"
    property int    priority: settings.defaultPriority
    property bool   hasDue:   settings.hasDueByDefault
    property bool   hasRepetition: false
    property string repetitionUnit: "d"
    property int    repetitionCount: 7
    property date   due

    function insert(){
        dbtodos.insertOpenTodo({ title: title,
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
            bottomEdge.category = bottomEdge.selectedCategory
            bottomEdge.priority = settings.defaultPriority
            bottomEdge.hasDue = settings.hasDueByDefault
            var d = new Date()
            bottomEdge.due = new Date(d.setDate(d.getDate()+settings.defaultDueOffset))
            // reset values in components
            inputTitle.text = bottomEdge.title
            inputPriority.maximalPriority = settings.maximalPriority
            inputPriority.value           = bottomEdge.priority
            switchDue.checked = bottomEdge.hasDue
            catSelect.currentlyExpanded = false
            var i=0
            for (i=0;i<catSelect.model.length-1;i++){
                if (catSelect.model[i]=== bottomEdge.category){
                    break
                }
            }
            catSelect.selectedIndex = i

            switchRepetition.checked = bottomEdge.hasRepetition
        }

        PageHeader{
            id: header
            title: i18n.tr("New Task")
            StyleHints{backgroundColor:colors.currentHeader}
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
                    model: dbtodos.categoriesNameList.concat(i18n.tr("other"))
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
                    Button{
                        id: btRepetition
                        width: parent.width - switchRepetition.width - 2*parent.spacing
                        enabled: bottomEdge.hasRepetition
                        text: enabled ? interval==="m" ? i18n.tr("monthly","every %1 months",intervalCount).arg(intervalCount)
                                                       : interval==="w" ? i18n.tr("weekly","every %1 weeks",intervalCount).arg(intervalCount)
                                                                        : i18n.tr("daily","every %1 days",intervalCount).arg(intervalCount)
                                      : i18n.tr("no repetition")
                        onClicked: repetitionSelectPopover.open(btRepetition)
                        property string interval: "w"
                        property int    intervalCount: 1
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

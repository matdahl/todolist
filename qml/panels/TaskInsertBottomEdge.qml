import QtQuick 2.7
import Ubuntu.Components 1.3
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
    property date   due

    function insert(){
        dbtodos.insertOpenTodo({ title: title,
                                 category: category,
                                 priority: priority,
                                 due: hasDue ? due.getTime() : 0
                               })
    }

    contentComponent: Rectangle {
        height: root.height
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

        }

        PageHeader{
            id: header
            title: i18n.tr("New Task")
            StyleHints{backgroundColor:colors.currentHeader}
        }
        Column{
            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
                margins: units.gu(4)
            }
            spacing: units.gu(2)

            Label{
                text: i18n.tr("Category") +":"
            }
            OptionSelector{
                id: catSelect
                model: dbtodos.categoriesNameList.concat(i18n.tr("other"))
                containerHeight: 4*itemHeight
                onSelectedIndexChanged: bottomEdge.category = model[selectedIndex]
            }
            Label{
                text: i18n.tr("Task name") +":"
            }
            TextField{
                id: inputTitle
                width: parent.width
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
                width: parent.width
                spacing: units.gu(2)
                Switch{
                    id: switchDue
                    anchors.verticalCenter: btDue.verticalCenter
                    onCheckedChanged: bottomEdge.hasDue = checked
                }
                Button{
                    id: btDue
                    width: parent.width - switchDue.width - parent.spacing
                    enabled: bottomEdge.hasDue
                    text: enabled ? Qt.formatDate(bottomEdge.due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
                    onClicked: PickerPanel.openDatePicker(bottomEdge,"due","Days|Months|Years")
                }
            }

            Rectangle{
                height: units.gu(0.125)
                width: parent.width
                color: theme.palette.normal.base
            }
            Row{
                spacing: units.gu(2)
                width: parent.width
                Button{
                    width: parent.width/2 - units.gu(1)
                    text: i18n.tr("cancel")
                    onClicked: bottomEdge.collapse()
                }
                Button{
                    width: parent.width/2 - units.gu(1)
                    text: i18n.tr("insert")
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

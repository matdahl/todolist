import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import "../components"

Item{
    id: root

    signal apply(var task)

    function accepted(){
        apply({
                  itemid: itemid,
                  title:  title,
                  category: category,
                  priority: priority,
                  due: hasDue? due.getTime() : 0
              })
    }

    property int    itemid: -1
    property string title: ""
    property string category: "NONE"
    property int    priority: 0
    property date   due: new Date()
    property bool   hasDue: false

    property int    maximalPriority: 6
    property var    categoryList

    function open(task){
        itemid   = task.itemid
        title    = task.title
        category = task.category
        priority = task.priority
       // print(root.priority)
        hasDue   = task.due
       // print(root.priority)
        due      = hasDue ? new Date(task.due) : new Date()
        PopupUtils.open(dialogComponent)
    }

    Component{
        id: dialogComponent
        Dialog{
            id: dialog
            OptionSelector{
                model: root.categoryList.concat(i18n.tr("other"))
                containerHeight: 4*itemHeight
                Component.onCompleted: {
                    var i
                    for (i=0;i<model.length-1;i++){
                        if (model[i]=== root.category){
                            break
                        }
                    }
                    selectedIndex = i
                }
                onSelectedIndexChanged: root.category = model[selectedIndex]
            }

            TextField{
                id: editTitle
                Component.onCompleted: text = root.title
                onTextChanged: root.title = text
            }
            PriorityManipulate{
                height: units.gu(4)
                maximalPriority: root.maximalPriority
                Component.onCompleted: {
                    value = root.priority
                    initialised = true
                }
                onValueChanged: if (initialised) root.priority = value
            }
            Row{
                width: parent.width
                spacing: units.gu(2)
                Switch{
                    id: switchDue
                    anchors.verticalCenter: btDue.verticalCenter
                    Component.onCompleted: checked = root.hasDue
                    onCheckedChanged: root.hasDue = checked
                }
                Button{
                    id: btDue
                    width: parent.width - switchDue.width - parent.spacing
                    enabled: root.hasDue
                    text: enabled ? Qt.formatDate(root.due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
                    onClicked: PickerPanel.openDatePicker(root,"due","Days|Months|Years")
                }
            }
            Rectangle{
                height: units.gu(0.125)
                color: theme.palette.normal.base
            }

            Button{
                text: i18n.tr("abort")
                onClicked: PopupUtils.close(dialog)
            }
            Button{
                text: i18n.tr("apply changes")
                color: UbuntuColors.orange
                onClicked: {
                    root.accepted()
                    PopupUtils.close(dialog)
                }
            }
        }
    }
}

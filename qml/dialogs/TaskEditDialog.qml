import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import "../components"

Item{
    id: root

    function accepted(){
        models.updateOpenTodo({
                  itemid: itemid,
                  title:  title,
                  category: category,
                  priority: priority,
                  due: hasDue? due.getTime() : 0,
                  repetition: hasRepetition ? repetitionUnit : "-",
                  repetitionCount: repetitionCount
              })
    }

    property int    itemid: -1
    property string title: ""
    property string category: "NONE"
    property int    priority: 0
    property date   due: new Date()
    property bool   hasDue: false
    property bool   hasRepetition: false
    property string repetitionUnit: "d"
    property int    repetitionCount: 7

    function open(task){
        itemid   = task.itemid
        title    = task.title
        category = task.category
        priority = task.priority
        hasDue   = task.due
        due      = hasDue ? new Date(task.due) : new Date()
        hasRepetition = task.repetition !== "-"
        repetitionUnit = hasRepetition ? task.repetition : "d"
        repetitionCount = task.repetitionCount

        PopupUtils.open(dialogComponent)
    }

    Component{
        id: dialogComponent
        Dialog{
            id: dialog
            OptionSelector{
                model: models.unmutedCategoriesNameList.concat(models.catNameOther)
                containerHeight: 4*itemHeight
                Component.onCompleted: {
                    for (var i=0;i<model.length-1;i++)
                        if (model[i]=== root.category)
                            break
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
                maximalPriority: settings.maximalPriority
                Component.onCompleted: {
                    value = root.priority
                    initialised = true
                }
                onValueChanged: if (initialised) root.priority = value
            }
            Row{
                width: parent.width
                spacing: units.gu(4)
                Switch{
                    id: switchDue
                    anchors.verticalCenter: btDue.verticalCenter
                    Component.onCompleted: checked = root.hasDue
                    onCheckedChanged: root.hasDue = checked
                }
                Button{
                    id: btDue
                    width: parent.width - switchDue.width - 2*parent.spacing
                    enabled: root.hasDue
                    text: enabled ? Qt.formatDate(root.due,"ddd dd/MM/yyyy") : i18n.tr("no deadline")
                    onClicked: PickerPanel.openDatePicker(root,"due","Days|Months|Years")
                }
            }
            Row{
                width:parent.width
                spacing: units.gu(4)
                Switch{
                    id: switchRepetition
                    anchors.verticalCenter: btRepetition.verticalCenter
                    Component.onCompleted: checked = root.hasRepetition
                    onCheckedChanged: root.hasRepetition = checked
                }
                Button{
                    id: btRepetition
                    width: parent.width - switchRepetition.width - 2*parent.spacing
                    enabled: root.hasRepetition
                    text: enabled ? interval==="m" ? i18n.tr("monthly","every %1 months",intervalCount).arg(intervalCount)
                                                   : interval==="w" ? i18n.tr("weekly","every %1 weeks",intervalCount).arg(intervalCount)
                                                                    : i18n.tr("daily","every %1 days",intervalCount).arg(intervalCount)
                                  : i18n.tr("no repetition")
                    onClicked: repetitionSelectPopover.open(btRepetition)
                    property string interval
                    property int    intervalCount
                    Component.onCompleted: {
                        interval = root.repetitionUnit
                        intervalCount = root.repetitionCount
                    }
                    onIntervalChanged: root.repetitionUnit = interval
                    onIntervalCountChanged: root.repetitionCount = intervalCount
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

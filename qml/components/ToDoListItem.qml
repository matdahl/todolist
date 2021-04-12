import QtQuick 2.7
import Ubuntu.Components 1.3

ListItem{
    id: root

    // signal to delete this item
    signal remove(int itemid)
    // signal to edit this item
    signal edit(var todo)
    // signal to mark this item as archieved
    signal achieved(int itemid)

    height: units.gu(7)
    leadingActions: ListItemActions{
        actions: [
            Action{
                iconName: "delete"
                onTriggered: remove(itemid)
            }
        ]
    }
    trailingActions: ListItemActions{
        actions: [
            Action{
                iconName: "edit"
                onTriggered: edit({itemid:itemid,title:title,category:category,priority:priority})
            },
            Action{
                iconName: "ok"
                onTriggered: achieved(itemid)
            }
        ]
    }

    TextArea {
        id: labelTitle
        anchors {
            verticalCenter: parent.verticalCenter
            left: labelDeadline.right
            right: priorityBar.left
            margins: units.gu(1)
        }
        readOnly: true
        height: parent.height + units.gu(1.5)
        text: title
        //font.bold: true
        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
    Label{
        id: labelCategory
        anchors{
            left: parent.left
            bottom: parent.bottom
            leftMargin: units.gu(2)
        }
        text: category
        textSize: Label.XSmall
    }
    Rectangle{
        id: labelCategoryBack
        anchors{
            fill: labelDeadline
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
        }
        radius: units.gu(1)
        opacity: 0.2
        visible: due
        color: labelDeadline.color
    }
    Label{
        id: labelDeadline
        anchors{
            top: parent.top
            bottom: labelCategory.top
            left: parent.left
            leftMargin: units.gu(2)
        }
        width: units.gu(8)
        enabled: due
        textSize: Label.Small
        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
        property int nDays: ((new Date(due)).setHours(0,0,0,0)-(new Date()).setHours(0,0,0,0))/(24*3600*1000)
        text: due ? nDays>7 ? i18n.tr("> 1 week")
                  : nDays>1 ? i18n.tr("in %1 days").arg(nDays)
                  : nDays===1 ? i18n.tr("tomorrow")
                  : nDays===0 ? i18n.tr("today")
                  : i18n.tr("overdue")
            : i18n.tr("no deadline")
        color: due ? nDays > 7 ? Qt.hsla(0.333,1,colors.darkMode? 0.65 : 0.35)
                               : nDays>-1 ? Qt.hsla(0.333*(nDays+1)/7,1,colors.darkMode? 0.65 : 0.35)
                                          : Qt.hsla(0,1,colors.darkMode? 0.65 : 0.35)
                   : theme.palette.disabled.backgroundText
        font.bold: due && nDays<1
    }

    Icon{
        anchors{
            top: parent.top
            right: priorityBar.left
        }
        height: root.height/3
        name: "media-playlist-repeat"
        visible: repetition !== "-"
    }

    PriorityBar{
        id: priorityBar
        value: priority
        maxValue: settings.maximalPriority
        anchors{
            right:  parent.right
            top:    parent.top
            bottom: parent.bottom
            rightMargin: units.gu(1)
        }
    }
}

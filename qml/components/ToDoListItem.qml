import QtQuick 2.7
import Ubuntu.Components 1.3

ListItem{
    id: root

    // signal to delete this item
    signal deleteById(int itemid)
    // signal to edit this item
    signal edit(var todo)
    // signal to mark this item as archieved
    signal achieved(int itemid)

    height: units.gu(6)
    leadingActions: ListItemActions{
        actions: [
            Action{
                iconName: "delete"
                onTriggered: deleteById(itemid)
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

    Label {
        id: labelTitle
        anchors {
            top: parent.top
            left: parent.left
            right: priorityBar.left
        }
        height: 0.8*parent.height
        text: title
        //font.bold: true
        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
    Label{
        id: labelCategory
        anchors{
            bottom: parent.bottom
        }
        x: parent.x + units.gu(1)
        text: category
        textSize: Label.XSmall
    }

    PriorityBar{
        id: priorityBar
        score: priority
        anchors{
            right:  parent.right
            top:    parent.top
            bottom: parent.bottom
        }
    }
}

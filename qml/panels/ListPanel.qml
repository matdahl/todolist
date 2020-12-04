import QtQuick 2.7
import Ubuntu.Components 1.3

import "../components"

Item {
    id: root

    // signals for database modifications
    signal deleteItem(int itemid)
    signal editItem(var todo)
    signal achieved(int itemid)
    signal refresh()

    // list of all categories
    property var categories

    // the currently selected category to display
    property string selectedCategory: sections.model[sections.selectedIndex]
    onSelectedCategoryChanged: refresh()

    // the toolbar to select the current category to display
    Sections{
        id: sections
        anchors{
            left: parent.left
            right: parent.right
        }
        height: units.gu(4)
        model: ["All"].concat(categories).concat(["other"])
    }

    // the model containing all books
    property var model: ToDoListModel{}

    // the list view
    UbuntuListView{
        id: listView
        anchors {
            top: sections.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: root.model
        delegate: ToDoListItem{
            onDeleteById: deleteItem(itemid)
            onEdit: editItem(todo)
            onAchieved: root.achieved(itemid)
        }
        spacing: units.gu(0.1)
    }
}

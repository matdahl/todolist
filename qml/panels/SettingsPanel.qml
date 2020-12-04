import QtQuick 2.7
import Ubuntu.Components 1.3
import "../components"

Item{
    id: root

    property var stack

    property var categories
    signal add_category(string name)
    signal delete_category(string name)

    Column{
        id: col
        width: root.width
        SettingsMenuItem{
            text: "Categories"
            stack: root.stack
            subpage: catPanel
        }

        Label{
            id: lbToDo
            text:"to dos:"
            font.bold: true
            textSize: Label.Large
        }
    }
    UbuntuListView{
        width: parent.width
        anchors.top: col.bottom
        anchors.bottom: parent.bottom
        currentIndex: -1
        model:["make done tasks accessible"]
        delegate: ListItem{
            height: units.gu(4)
            Label{
                text: modelData
                anchors.fill: parent
                verticalAlignment: Label.AlignVCenter
            }
        }
    }

    // the panel to manage the book categories
    SettingsCategoriesPanel{
        id: catPanel
        visible: false
        categories: root.categories
        title: "Manage categories"
        onAdd_category:    root.add_category(name)
        onDelete_category: root.delete_category(name)
    }
}

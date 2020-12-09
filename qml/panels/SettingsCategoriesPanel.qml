import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import "../components"

Item{
    id: root

    property var categories
    signal add_category(string name)
    signal delete_category(string name)

    property string title: "Manage Categories"

    Component.onCompleted: refreshList()
    onCategoriesChanged:   refreshList()

    Column{
        id: col
        padding: units.gu(2)
        spacing: units.gu(2)
        width: parent.width
        Label{
            textSize: Label.Large
            font.bold: true
            text: root.title+":"
        }
        Row{
            id: addRow

            spacing: units.gu(2)
            padding: units.gu(1)
            TextField{
                id: inputNewCategory
                placeholderText: "new category"
            }
            Button{
                id: btAddCategory
                width: 2*height
                text: "add"
                color: UbuntuColors.green
                onClicked: {
                    add_category(inputNewCategory.text)
                    inputNewCategory.text = ""
                }
            }
        }
    }

    UbuntuListView{
        id: catListView

        anchors{
            top: col.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        delegate: ListItem{
            Label{
                anchors.fill: parent
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
                text: name
            }
            leadingActions: ListItemActions{
                actions:[
                    Action{
                        iconName: "delete"
                        onTriggered: delete_category(categories[index])
                    }
                ]
            }
        }
        model: ListModel{}
    }

    function refreshList(){
        catListView.model.clear()
        for (var i=0; i<categories.length; i++){
            catListView.model.append({name:categories[i]})
        }
    }
}

import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import "../components"

Item{
    id: root

    property string headerSuffix: i18n.tr("Manage Categories")

    Row{
        id: addRow

        spacing: units.gu(2)
        padding: units.gu(2)
        TextField{
            id: inputNewCategory
            width: root.width - btAddCategory.width - 2*parent.padding - parent.spacing
            placeholderText: i18n.tr("new category") + " ..."
            onAccepted: btAddCategory.clicked()
        }
        Button{
            id: btAddCategory
            width: 2*height
            Icon{
                anchors.centerIn: parent
                height: 0.7*parent.height
                name: "add"
                color: theme.palette.normal.positiveText
            }
            color: theme.palette.normal.positive
            onClicked: {
                if (inputNewCategory.text.length>0){
                    models.newCategory(inputNewCategory.text)
                    inputNewCategory.text = ""
                }
            }
        }
    }

    UbuntuListView{
        id: catListView
        anchors{
            top: addRow.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        model: models.categoriesModel

        delegate: ListItem{
            Label{
                anchors{
                    verticalCenter: parent.verticalCenter
                    left: icUp.right
                    right: swMuted.left
                }
                horizontalAlignment: Label.AlignHCenter
                text: name
            }
            Icon{
                id: icUp
                anchors{
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                    margins: units.gu(1.5)
                }
                name: "up"
                visible: index>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:  models.swapCategories(index,index-1)
                }
            }
            Switch{
                id: swMuted
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: icDown.left
                    margins: units.gu(2)
                }
                checked: muted===0
                onCheckedChanged: {
                    var mutedNew = checked ? 0 : 1
                    if (mutedNew!==muted)
                        models.setCategoryMuted(cid,mutedNew)
                }
            }

            Icon{
                id: icDown
                anchors{
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    margins: units.gu(1.5)
                }
                name: "down"
                visible: index<catListView.model.count-1
                MouseArea{
                    anchors.fill: parent
                    onClicked: models.swapCategories(index,index+1)
                }
            }

            leadingActions: ListItemActions{
                actions:[
                    Action{
                        iconName: "delete"
                        onTriggered: models.removeCategory(cid)
                    }
                ]
            }
        }
    }
}

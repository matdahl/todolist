import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Pickers 1.3
import QtQuick.Layouts 1.3

import "../components"

Item {
    id: root

    // list of all categories
    property var categories

    // the id of the current item in edit mode
    property int currentID: -1

    state: "new"
    states: [
        State{
            name: "new"
        },
        State{
            name: "edit"
        }
    ]

    // exit edit panel and create a new book
    signal added(var todo)

    // exit edit panel and apply changes on current book - to be implemented
    signal edited(var todo)

    // exit edit panel without changes to database
    signal abort()

    function reset(){
        currentID           = -1
        inputTitle.text     = ""
        inputCategory.selectedIndex = 0
        inputPriority.value = 2
        root.state = "new"
    }

    function set(todo,state){
        root.currentID      = todo.itemid
        inputTitle.text     = todo.title
        inputCategory.setText(todo.category)
        inputPriority.value = todo.priority
        root.state = state
    }

    Component.onCompleted: reset()
    Column{
        id: col
        spacing: units.gu(3)
        anchors.centerIn: parent

        Label {
            text: root.state=="new" ? "New To Do" : root.state== "edit" ? "Edit ToDo" : "UNKNOWN STATE"
            textSize: Label.Large
            font.bold: true
        }

        Label {text: "Title:"}

        TextField{
            id: inputTitle
            placeholderText: "title of to do"
        }
        Label {text: "Category:"}
        OptionSelector{
            id: inputCategory
            width: parent.width
            Component.onCompleted: dbtodos.categoriesChanged.connect(refresh)
            model:[i18n.tr("other")]
            readonly property string currentCategory: model[selectedIndex]
            function refresh(){
                model = dbtodos.categoriesNameList.concat([i18n.tr("other")])
            }
            function setText(cat){
                for (var i=0;i<model.length;i++){
                    if (model[i]===cat){
                        selectedIndex = i
                        break
                    }
                }
                selectedIndex = 0
            }
        }

        Label {text: "Priority:"}
        IntegerManipulate{
            id: inputPriority
            width: parent.width
            value: 0
            minvalue: 0
            maxvalue: 3
        }

        Row{
            id: buttonRow
            Layout.alignment: Layout.Center
            spacing: units.gu(6)
            Button{
                id: btOk
                color: UbuntuColors.orange
                text: state=="new"  ? "Add" :
                      state=="edit" ? "Apply" :
                                          "OK"
                onClicked: {
                    if (inputTitle.text !== ""){
                        if (root.state=="new"){
                            added({title:    inputTitle.text,
                                   category: inputCategory.currentCategory,
                                   priority: inputPriority.value
                                  })
                        } else if (root.state=="edit") {
                            edited({itemid:   currentID,
                                    title:    inputTitle.text,
                                    category: inputCategory.currentCategory,
                                    priority: inputPriority.value
                                   })
                        }
                        stack.pop()
                        reset()
                    }
                }
            }

            Button{
                id: btAbort
                text: "Abort"
                onClicked: {
                    abort()
                    stack.pop()
                    reset()
                }
            }
        }
    }
}

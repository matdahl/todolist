import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Pickers 1.3
import QtQuick.Layouts 1.3

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
        inputCategory.text  = "other"
        inputPriority.value = 2
        root.state = "new"
    }

    function set(todo,state){
        root.currentID      = todo.itemid
        inputTitle.text     = todo.title
        inputCategory.text  = todo.category
        inputPriority.value = todo.priority
        root.state = state
    }

    Component.onCompleted: reset()
    Flickable{
        anchors.fill: parent
        contentHeight: col.height
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
            Picker{
                id: inputCategory
                model: categories.concat(["other"])
                width: parent.width
                circular: false
                property string text: model[selectedIndex]
                delegate: PickerDelegate{
                    Label{
                        text: modelData
                        horizontalAlignment: Label.AlignHCenter
                        anchors.fill: parent
                    }
                }
                onSelectedIndexChanged: text = model[selectedIndex]
            }
            Label {text: "Priority:"}
            Picker{
                id: inputPriority
                model: [3,2,1,0]
                circular: false
                width: parent.width
                property int value: model[selectedIndex]
                delegate: PickerDelegate{
                    Label{
                        text: modelData
                        horizontalAlignment: Label.AlignHCenter
                        anchors.fill: parent
                    }
                }
                onSelectedIndexChanged: value = model[selectedIndex]
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
                                       category: inputCategory.text,
                                       priority: inputPriority.value
                                      })
                            } else if (root.state=="edit") {
                                edited({itemid:   currentID,
                                        title:    inputTitle.text,
                                        category: inputCategory.text,
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
}

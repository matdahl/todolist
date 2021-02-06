import QtQuick 2.7
import Ubuntu.Components 1.3

import "../components"

Item {
    id: root
    // the model containing all open todos with appropriate category
    SortFilterModel{
        id: filteredOpenTodos
        model: dbtodos.openTodosModel
        filter.property: "category"
        filter.pattern: RegExp("^"+sections.currentCategory+"$")
    }

    // the model containing all open todos of category "other"
    ListModel{
        id: otherOpenTodos
        Component.onCompleted: {
            refresh()
            dbtodos.openTodosChanged.connect(refresh)
            dbtodos.categoriesChanged.connect(refresh)
        }
        function refresh(){
            clear()
            for (var i=0;i<dbtodos.openTodosModel.count; i++){
                var current = dbtodos.openTodosModel.get(i)
                // keep this entry only if its name is not in list
                var found = false
                for (var j=0;j<dbtodos.categoriesNameList.length;j++){
                    if (dbtodos.categoriesNameList[j]===current.category){
                        found = true
                        break
                    }
                }
                if (!found) append(current)
            }
        }
    }

    /* ------------------------ *
     * ------ Components ------ *
     * ------------------------ */

    // the toolbar to select the current category to display
    Sections{
        id: sections
        anchors{
            left: parent.left
            right: parent.right
        }
        height: units.gu(6)
        model: [i18n.tr("All"),i18n.tr("other")]
        readonly property string currentCategory: model.length>0 ? selectedIndex===0 ? i18n.tr("all")
                                                                                     : selectedIndex===model.length-1 ? i18ntr("other")
                                                                                                                      : dbtodos.categoriesNameList[selectedIndex-1]
                                                                 : ""
        Component.onCompleted: {
            dbtodos.categoriesChanged.connect(refresh)
            dbtodos.openTodosChanged.connect(recount)
        }
        function refresh(){
            model = [i18n.tr("all")].concat(dbtodos.categoriesNameList).concat([i18n.tr("other")])
            recount()
        }
        function recount(){
            if (dbtodos.totalCount>0){
                model[0] = "<b>"+i18n.tr("all")+" ("+dbtodos.totalCount+")</b>"
            } else {
                model[0] = i18n.tr("all")+" (0)"
            }
            var i
            for (i=0;i<dbtodos.categoriesNameList.length;i++){
                if (dbtodos.categoriesCount[i]>0){
                    model[i+1] = "<b>"+dbtodos.categoriesNameList[i]+" ("+dbtodos.categoriesCount[i]+")</b>"
                } else {
                    model[i+1] = dbtodos.categoriesNameList[i]+" (0)"
                }
            }
            if (dbtodos.categoriesCount[i]>0){
                model[i+1] = "<b>"+i18n.tr("other")+" ("+dbtodos.categoriesCount[i]+")</b>"
            } else {
                model[i+1] = i18n.tr("other")+" (0)"
            }
            var index = selectedIndex
            modelChanged()
            selectedIndex = index
        }

        onSelectedIndexChanged: taskInsertPanel.expanded = false
    }

    TaskInsertPanel{
        id: taskInsertPanel
        anchors{
            top: sections.bottom
        }
        enabled: sections.selectedIndex>0
        onAdd: dbtodos.insertOpenTodo({ title: title,
                                        category: sections.currentCategory,
                                        priority: priority,
                                        due: hasDue ? due.getTime() : 0
                                      })
    }

    ToDoListHeader{
        id: listHeader
        anchors.top: taskInsertPanel.bottom
        onStateChanged: dbtodos.openTasksSorting = state
    }

    UbuntuListView{
        id: listView
        anchors {
            top: listHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        model: sections.selectedIndex>0 ? sections.selectedIndex<sections.model.length-1 ? filteredOpenTodos
                                                                                         : otherOpenTodos
                                        : dbtodos.openTodosModel
        delegate: ToDoListItem{
            onRemove: dbtodos.removeOpenTodo(itemid)
            onEdit: {
                editPanel.set(todo,"edit")
                stack.push(editPanel)
            }
            onAchieved: print("achieving not implemented yet :(")
        }
    }
}

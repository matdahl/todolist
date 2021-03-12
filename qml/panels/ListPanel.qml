import QtQuick 2.7
import Ubuntu.Components 1.3

import "../components"
import "../dialogs"

Item {
    id: root

    readonly property alias selectedCategory: sections.currentCategory
    readonly property alias selectedCategoryIndex: sections.selectedIndex

    /* ---------------------------------- *
     * ----------- List models ---------- *
     * ---------------------------------- */

    // the model containing all open todos with currently selected category
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

    // the model containing the filtered and sorted todos which are currently shown in the ListView
    SortFilterModel{
        id: sortedTodosModel
        model: sections.selectedIndex>0 ? sections.selectedIndex<sections.model.length-1 ? filteredOpenTodos
                                                                                         : otherOpenTodos
                                        : dbtodos.openTodosModel
        sort.property: sortModeSelector.index===0 ? "dueSORT" :
                       sortModeSelector.index===1 ? "title" :
                                                    "priority"
        sort.order: sortModeSelector.index===2? Qt.DescendingOrder : Qt.AscendingOrder
    }

    /* ---------------------------------- *
     * ----------- Components ----------- *
     * ---------------------------------- */

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
                                                                                     : selectedIndex===model.length-1 ? i18n.tr("other")
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
    }

    UbuntuListView{
        id: listView
        anchors {
            top: sections.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        model: sortedTodosModel
        delegate: ToDoListItem{
            id: listItem
            onRemove: dbtodos.removeOpenTodo(itemid)
            onEdit: {
                editDialog.open(listView.model.get(index))
            }
            // currently, todos that are achieved are simply deleted. Later, there might be an other handling for done todos
            onAchieved: dbtodos.removeOpenTodo(itemid)
        }
        TaskEditDialog{
            id: editDialog
            maximalPriority: settings.maximalPriority
            categoryList:  dbtodos.categoriesNameList
            onApply: dbtodos.updateOpenTodo(task)
        }
    }
}

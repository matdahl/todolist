import QtQuick 2.7
import Ubuntu.Components 1.3

import "../components"
import "../dialogs"

Item {
    id: root

    //readonly property alias selectedCategory: "sections.currentCategory"
    //readonly property alias selectedCategoryIndex: sections.selectedIndex

    property bool showSortModeSelect

    /* ---------------------------------- *
     * ----------- List models ---------- *
     * ---------------------------------- */

    // the model containing all open todos with currently selected category
    SortFilterModel{
        id: filteredOpenTodos
        model: models.openTodoModel
        filter.property: "category"
        filter.pattern: RegExp("^"+(sections.selectedIndex>0?models.unmutedCategoriesNameList[sections.selectedIndex-1]:"")+"$")
    }

    // the model containing the filtered and sorted todos which are currently shown in the ListView
    SortFilterModel{
        id: sortedTodosModel
        model: sections.selectedIndex>0 ? sections.selectedIndex<sections.model.length-1 ? filteredOpenTodos
                                                                                         : models.openTodoModelOther
                                        : models.openTodoModel
        sort.property: sortModeSelect.index===0 ? "dueSORT" :
                       sortModeSelect.index===1 ? "title" :
                                                  "priority"
        sort.order: sortModeSelect.ascending[sortModeSelect.index] ? Qt.AscendingOrder : Qt.DescendingOrder
        sortCaseSensitivity: Qt.CaseInsensitive
    }

    /* ---------------------------------- *
     * ----------- Components ----------- *
     * ---------------------------------- */

    // the toolbar to select the current category to display
    Sections{
        id: sections
        anchors{
            top: sortModeSelect.bottom
            left: parent.left
            right: parent.right
        }
        height: units.gu(6)
        model: models.sectionTitles
        Component.onCompleted: models.sectionsTitlesChanged.connect(refresh)
        function refresh(){
            var index = selectedIndex
            modelChanged()
            if (index >= model.length)
                index = model.length-1
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
            onEdit: taskEditDialog.open(listView.model.get(index))
        }
    }

    SortModeSelect{
        id: sortModeSelect
        expanded: showSortModeSelect
    }
}

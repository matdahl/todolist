import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: root

    signal sectionsTitlesChanged()

    /* ----- database connector ----- */

    DBconnector{
        id: dbcon
    }

    /* ----- category models ----- */

    property var categoriesModel: ListModel{}
    property var unmutedCategoriesModel: ListModel{}
    property var unmutedCategoriesNameList: []

    readonly property string catNameAll:   i18n.tr("all")
    readonly property string catNameOther: i18n.tr("other")



    /* ----- todo models ----- */

    property var openTodoModel: ListModel{}
    property var openTodoModelOther: ListModel{}



    /* ----- section titles ----- */

    readonly property int todoTotalCount: openTodoModel.count
    readonly property int todoOtherCount: openTodoModelOther.count
    property var todoCounts: []
    property var sectionTitles: []



    /* ----- initialiser ----- */

    Component.onCompleted: {
        var i

        // init categories (insertion sort)
        var cats = dbcon.selectCategories()
        for (i=0;i<cats.length;i++){
            for (var j=0;j<categoriesModel.count;j++)
                if (cats[i].cid<categoriesModel.get(j).cid)
                    break
            categoriesModel.insert(j,cats[i])
            unmutedCategoriesModel.insert(j,cats[i])
            unmutedCategoriesNameList.splice(j,0,cats[i].name)
        }
        for (i=unmutedCategoriesModel.count-1;i>0;i--){
            if (unmutedCategoriesModel.get(i).muted!==0){
                unmutedCategoriesModel.remove(i)
                unmutedCategoriesNameList.splice(i,1)
            }
        }

        // init todos
        var todos = dbcon.selectOpenTodos()
        for (i=0;i<todos.length;i++){
            var todo = todos[i]
            var todo_insert = {
                itemid:   todo.itemid,
                title:    todo.title,
                category: todo.category,
                priority: todo.priority,
                due:      todo.due,
                dueSORT:  todo.due!==0 ? Qt.formatDateTime(new Date(todo.due),"yyyy/MM/dd-hh:mm") : "9999",
                repetition:      todo.repetition,
                repetitionCount: todo.repetitionCount
            }
            openTodoModel.append(todo_insert)
            if (getCategoryIndex(todo.category)===-1)
                openTodoModelOther.append(todo_insert)
        }

        // init counters
        for (i=0;i<unmutedCategoriesModel.count;i++){
            var count = getTodoCount(unmutedCategoriesModel.get(i).name)
            todoCounts.push(count)
        }


        // init section titles
        sectionTitles.push(makeTitle(catNameAll,todoTotalCount))
        for (i=0;i<unmutedCategoriesModel.count;i++){
            sectionTitles.push(makeTitle(unmutedCategoriesModel.get(i).name,todoCounts[i]))
        }
        sectionTitles.push(makeTitle(catNameOther,todoOtherCount))
        sectionsTitlesChanged()
    }

    /* ----- data access functions ----- */

    function getCategoryByCid(cid){
        for (var i=0;i<categoriesModel.count;i++){
            if (categoriesModel.get(i).cid===cid){
                return categoriesModel.get(i)
            }
        }
    }

    function getCategoryIndex(name){
        for (var i=0;i<categoriesModel.count;i++)
            if (categoriesModel.get(i).name===name)
                return i
        return -1
    }

    function getTodoCount(category){
        var count = 0
        print("count '"+category+"'")
        for (var i=0;i<openTodoModel.count;i++){
            print(JSON.stringify(openTodoModel.get(i)))
            if (openTodoModel.get(i).category===category)
                count += 1
            print(count)
        }
        return count
    }

    function incTodoCount(category){
        var index = getCategoryIndex(category)
        sectionTitles[0]   = makeTitle(catNameAll,todoTotalCount)
        if (index===-1){
            sectionTitles[sectionTitles.length-1] = makeTitle(catNameOther,todoOtherCount)
            sectionsTitlesChanged()
        } else {
            todoCounts[index]  += 1
            sectionTitles[index+1] = makeTitle(unmutedCategoriesModel.get(index).name,todoCounts[index])
            return true
        }
        return false
    }
    function decTodoCount(category){
        var index = getCategoryIndex(category)
        sectionTitles[0]   = makeTitle(catNameAll,todoTotalCount)
        if (index===-1){
            sectionTitles[sectionTitles.length-1] = makeTitle(catNameOther,todoOtherCount)
            sectionsTitlesChanged()
        } else {
            todoCounts[index]  -= 1
            sectionTitles[index+1] = makeTitle(unmutedCategoriesModel.get(index).name,todoCounts[index])
            return true
        }
        return false
    }

    function makeTitle(name,count){
        return count>0 ? "<b>" + name + " ("+count+")</b>" : name + " (0)"
    }

    /* ----- categories manipulate ----- */

    function newCategory(name){
        // add to database
        var cid = dbcon.insertCategory(name)
        if (cid===-1)
            return false

        var cat = {
            cid: cid,
            name: name,
            muted: 0
        }

        // add to models
        categoriesModel.append(cat)
        unmutedCategoriesModel.append(cat)
        unmutedCategoriesNameList.push(cat.name)

        // update section titles
        sectionTitles.splice(sectionTitles.length-1,0,makeTitle(cat.name,0))
        sectionsTitlesChanged()
    }
    function removeCategory(cid){
        // remove from database
        if (dbcon.removeCategory(cid)){
            // remove from models
            var muted = getCategoryByCid(cid).muted
            for (var i=0;i<categoriesModel.count;i++){
                if (categoriesModel.get(i).cid===cid){
                    categoriesModel.remove(i)
                    break
                }
            }
            if (muted===0){
                for (var j=0;j<unmutedCategoriesModel.count;j++){
                    if (unmutedCategoriesModel.get(j).cid===cid){
                        unmutedCategoriesModel.remove(j)
                        unmutedCategoriesNameList.splice(j,1)
                        sectionTitles.splice(j+1,1)
                        sectionsTitlesChanged()
                        break
                    }
                }
            }
        }
        return false
    }
    function setCategoryMuted(cid,muted){
        var cat = getCategoryByCid(cid)

        if (cat.muted===muted)
            return

        // update in categoriesModel
        cat.muted = muted

        // update in database
        if (!dbcon.updateCategory(cat))
            return

        if (muted===1){
            // remove from unmutedCategoriesModel
            for (var i=0;i<unmutedCategoriesModel.count;i++){
                if (unmutedCategoriesModel.get(i).cid===cat.cid){
                    unmutedCategoriesModel.remove(i)
                    todoCounts.splice(i+1,1)
                    unmutedCategoriesNameList.splice(i,1)
                    sectionTitles.splice(i+1,1)
                    sectionsTitlesChanged()
                    return
                }
            }
        } else {
            // insert into unmutedCategoriesModel
            var j
            for (j=0;j<unmutedCategoriesModel.count;j++)
                if (unmutedCategoriesModel.get(j).cid>cat.cid)
                    break
            unmutedCategoriesModel.insert(j,cat)
            var count = getTodoCount(cat.cid)
            todoCounts.splice(j,0,count)
            unmutedCategoriesNameList.splice(j,0,cat.name)
            sectionTitles.splice(j+1,0,makeTitle(cat.name,count))
            sectionsTitlesChanged()
        }
    }
    function swapCategories(index1,index2){
        if (index1<0 || index2<0 || index1>categoriesModel.count || index2>categoriesModel.count)
            return false

        var cat1 = categoriesModel.get(index1)
        var cat2 = categoriesModel.get(index2)

        if (!dbcon.swapCategories(cat1.cid,cat2.cid))
            return false

        // swap in categoriesModel
        var temp = cat1.cid
        cat1.cid = cat2.cid
        cat2.cid = temp
        categoriesModel.move(index2,index1,1)

        // swap in unmutedCategoriesModel
        var idx1 = -1
        var idx2 = -1
        for (var i=0; i<unmutedCategoriesModel.count;i++){
            var cid = unmutedCategoriesModel.get(i).cid
            if (cid===cat2.cid)
                idx1 = i
            if (cid===cat1.cid)
                idx2 = i
            if (idx1>-1 && idx2>-1)
                break
        }
        if (idx1>-1)
            unmutedCategoriesModel.get(idx1).cid = cat1.cid
        if (idx2>-1)
            unmutedCategoriesModel.get(idx2).cid = cat2.cid
        if (idx1>-1 && idx2>-1){
            unmutedCategoriesModel.move(idx2,idx1,1)
            unmutedCategoriesNameList[idx2] = cat1.name
            unmutedCategoriesNameList[idx1] = cat2.name
            var countTemp = todoCounts[idx1]
            todoCounts[idx1] = todoCounts[idx2]
            todoCounts[idx2] = countTemp
            sectionTitles[idx1+1] = makeTitle(unmutedCategoriesModel.get(idx1).name,todoCounts[idx1])
            sectionTitles[idx2+1] = makeTitle(unmutedCategoriesModel.get(idx2).name,todoCounts[idx2])
            sectionsTitlesChanged()
        }
    }

    /* ----- todos manipulate ----- */

    function newTodo(todo){
        var itemid = dbcon.insertOpenTodo(todo)
        if (itemid>-1){
            todo.itemid = itemid
            openTodoModel.append(todo)
            if (getCategoryIndex(todo.category)===-1)
                openTodoModelOther.append(todo)
            incTodoCount(todo.category)

            return true
        }
        return false
    }

    function removeOpenTodo(itemid){
        if (dbcon.removeOpenTodo(itemid)){
            for (var i=0;i<openTodoModel.count;i++){
                if (openTodoModel.get(i).itemid===itemid){
                    var category = openTodoModel.get(i).category
                    openTodoModel.remove(i)
                    if (getCategoryIndex(category)===-1){
                        for (var j=0;j<openTodoModelOther.count;j++){
                            if (openTodoModelOther.get(j).itemid===itemid)
                                openTodoModelOther.remove(j)
                        }
                    }
                    decTodoCount(category)
                    return true
                }
            }
        }
        return false
    }

}

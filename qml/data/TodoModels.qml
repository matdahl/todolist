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

    /* ----- todo models ----- */

    property var openTodoModel: ListModel{}

    /* ----- section titles ----- */

    property int todoTotalCount: 0
    property int todoOtherCount: 0
    property var todoCounts: []
    property var sectionTitles: []



    /* ----- initialiser ----- */

    Component.onCompleted: {
        var i

        print("init todo model")

        // init categories
        var cats = dbcon.selectCategories()
        for (i=0;i<cats.length;i++){
            categoriesModel.append(cats[i])
            if (cats[i].muted===0){
                unmutedCategoriesModel.append(cats[i])
                todoCounts.push(0)
            }
        }

        // init todos

        // count todos

        // init section titles
        sectionTitles.push(todoTotalCount>0 ? "<b>"+i18n.tr("all")+" ("+todoTotalCount+")</b>"
                                            : i18n.tr("all") +" (0)")
        for (i=0;i<unmutedCategoriesModel.count;i++){
            sectionTitles.push(todoCounts[i]>0 ? "<b>" + unmutedCategoriesModel.get(i).name + " ("+todoCounts[i]+")</b>"
                                               : unmutedCategoriesModel.get(i).name + " (0)")
        }
        sectionTitles.push(todoOtherCount>0 ? "<b>"+i18n.tr("other")+" ("+todoOtherCount+")</b>"
                                            : i18n.tr("other") +" (0)")
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

    function getTodoCount(cid){
        var count = 0
        for (var i=0;i<openTodoModel.count;i++){
            if (openTodoModel.get(i).cid===cid)
                count += 1
        }
        return count
    }

    /* ----- categories manipulate ----- */

    // add a new, unmuted category
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

        // update section titles
        sectionTitles.splice(sectionTitles.length-1,0,cat.name+" (0)")
        sectionsTitlesChanged()
    }

    // removes a category
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
                        sectionTitles.splice(j,1)
                        sectionsTitlesChanged()
                        break
                    }
                }
            }
        }
        return false
    }

    // update the muted property of a category
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
                    sectionTitles.splice(i+1,1)
                    sectionsTitlesChanged()
                    return
                }
            }
        } else {
            // insert into unmutedCategoriesModel
            var j
            for (j=0;j<unmutedCategoriesModel.count;j++)
                if (unmutedCategoriesModel.cid>cat.cid)
                    break
            unmutedCategoriesModel.insert(j,cat)
            var count = getTodoCount(cat.cid)
            todoCounts.splice(j+1,0,count)
            sectionTitles.splice(j+1,0,count>0 ? "<b>"+cat.name+" ("+count+")</b>" : cat.name+" (0)")
            sectionsTitlesChanged()
        }
    }
}
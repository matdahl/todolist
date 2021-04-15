import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: root

    /* ----- database connector ----- */

    DBconnector{
        id: dbcon
    }

    /* ----- category models ----- */

    property var categoriesModel: ListModel{}
    property var unmutedCategoriesModel: ListModel{}
    property var unmutedCategoriesNameList: []
    property var sectionTitles: []

    /* ----- todo models ----- */


    /* ----- initialiser ----- */

    Component.onCompleted: {
        var i

        // init categories
        var cats = dbcon.selectCategories()
        unmutedCategoriesNameList.push(i18n.tr("all"))
        sectionTitles.push(i18n.tr("all"))
        for (i=0;i<cats.length;i++){
            categoriesModel.append(cats[i])
            if (cats[i].muted===0){
                unmutedCategoriesModel.append(cats[i])
                unmutedCategoriesNameList.push(cats[i].name)
                sectionTitles.push(cats[i].name)
            }
        }
        unmutedCategoriesNameList.push(i18n.tr("other"))
        sectionTitles.push(i18n.tr("other"))

        // init todos

        // count todos
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
        unmutedCategoriesNameList.append(name)

        // update section titles

    }
}

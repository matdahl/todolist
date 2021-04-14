import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0 as Sql

Item{
    id: root

    signal categoriesChanged()
    signal openTodosChanged()

    // list of names of all categories
    property var categoriesNameList: []

    // list of task numbers for each category
    property var categoriesCount: [0]
    property int totalCount: 0

    property var categoriesModel: ListModel{}
    property var fullCategoriesModel: ListModel{}
    property var openTodosModel:  ListModel{}

    function refreshCategories(){
        if (!db) init()
        categoriesModel.clear()
        categoriesNameList.length = 0
        var cats = selectUnmutedCategories()
        for (var i=0; i<cats.length; i++){
            categoriesModel.append(cats[i])
            categoriesNameList.push(cats[i].name)
        }
        recount()
        categoriesChanged()
    }
    function refreshFullCategories(){
        if (!db) init()
        fullCategoriesModel.clear()
        var cats = selectCategories()
        for (var i=0; i<cats.length; i++){
            fullCategoriesModel.append(cats[i])
        }
        categoriesChanged()
    }
    function refreshOpenTodos(){
        if (!db) init()
        openTodosModel.clear()
        var todos = selectOpenTodos()
        for (var i=0; i<todos.length; i++){
            openTodosModel.append({itemid:   todos[i].itemid,
                                   title:    todos[i].title,
                                   category: todos[i].category,
                                   priority: todos[i].priority,
                                   due:      todos[i].due,
                                   dueSORT:  todos[i].due!==0 ? Qt.formatDateTime(new Date(todos[i].due),"yyyy/MM/dd-hh:mm")
                                                              : "9",
                                   repetition: todos[i].repetition,
                                   repetitionCount: todos[i].repetitionCount
                                  })
        }
        recount()
        openTodosChanged()
    }
    function recount(){
        totalCount = openTodosModel.count
        var n = categoriesCount.length = categoriesNameList.length+1
        for (var j=0;j<categoriesCount.length;j++){
            categoriesCount[j] = 0
        }
        for (var i=0;i<totalCount;i++){
            var k
            for (k=0;k<categoriesNameList.length;k++){
                if (categoriesNameList[k] === openTodosModel.get(i).category){
                    categoriesCount[k] += 1
                    break
                }
            }
            // if not found -> add to "other"
            if (k===n-1) categoriesCount[n-1] += 1
        }
    }

    property var db

    property string db_name: "todos.db"
    property string db_version: "1.0"
    property string db_description: "todos storage"
    property int    db_size: 1024
    property string db_table_categories: "categories1"
    property string db_table_todos_open: "open"

    /* ------------------------------ *
     * ----- initialisation I/O ----- *
     * ------------------------------ */
    function init(){
        // open database
        db = Sql.LocalStorage.openDatabaseSync(db_name,
                                               db_version,
                                               db_description,
                                               db_size,
                                               callback(db))

        init_categories()
        init_openTodos()
    }
    function callback(db){/* do nothing */}
    function init_categories(){
        db.transaction(function(tx){
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + db_table_categories + '(cid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, muted INTEGER DEFAULT 0, UNIQUE(name))')
            } catch(err){
                console.log("Error when creating table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
        refreshCategories()
        refreshFullCategories()
    }
    function init_openTodos(){
        var cmd = 'CREATE TABLE IF NOT EXISTS ' + db_table_todos_open + '('
        cmd    += 'itemid INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, priority INTEGER, due INTEGER)'
        db.transaction(function(tx){
            try {
                tx.executeSql(cmd)
            } catch(err){
                console.error("Error when creating table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
            }
        })
        // check if all required colunms are in table and create missing ones
        try{
            var colnames = []
            db.transaction(function(tx){
                var rt = tx.executeSql("PRAGMA table_info("+db_table_todos_open+")")
                for(var i=0;i<rt.rows.length;i++){
                    colnames.push(rt.rows[i].name)
                }
            })
            // since v1.1.0: require columns 'repetition' and 'repetitionCount'
            if (colnames.indexOf("repetition")<0){
                print("[INFO] openTodos table: add column 'repetition'")
                db.transaction(function(tx){
                    tx.executeSql("ALTER TABLE "+db_table_todos_open+" ADD repetition TEXT DEFAULT '-'")
                })
            }
            if (colnames.indexOf("repetitionCount")<0){
                print("[INFO] openTodos table: add column 'repetitionCount'")
                db.transaction(function(tx){
                    tx.executeSql("ALTER TABLE "+db_table_todos_open+" ADD repetitionCount INTEGER DEFAULT 1")
                })
            }
        } catch (err){
            console.error("Error when checking columns of table '"+db_table_todos_open+"': " + err)
        }
        refreshOpenTodos()
    }



    /* ------------------------ *
     * ----- category I/O ----- *
     * ------------------------ */
    function insertCategory(name){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('INSERT OR IGNORE INTO ' + db_table_categories + '(name,muted) VALUES(?,0)',[name])
            })
            refreshCategories()
            refreshFullCategories()
        } catch(err){
            console.log("Error when inserting category table '"+db_table_categories+"' in database '"+db_name+"': " + err)
        }

    }
    function selectCategories(){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('SELECT * FROM ' + db_table_categories)
            })
            return rt.rows
        } catch(err){
            console.log("Error when selecting all from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            return []
        }
    }
    function selectUnmutedCategories(){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('SELECT * FROM ' + db_table_categories + ' WHERE muted=0')
            })
            return rt.rows
        } catch(err){
            console.log("Error when selecting all enabled from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            return []
        }
    }
    function setMutedCategory(cid,muted){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + db_table_categories + ' SET muted=? WHERE cid=?',[muted,cid])
            })
            refreshCategories()
        } catch(err){
            console.log("Error when toggling muted in table '"+db_table_categories+"' in database '"+db_name+"': " + err+"\n"+JSON.stringify(todo))
        }
    }

    function removeCategory(cid){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ' + db_table_categories + ' WHERE cid='+cid)
            })
            refreshCategories()
            refreshFullCategories()
        } catch(err){
            console.log("Error when deleting category from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
        }

    }
    function swapCategories(index1,index2){
        if (!db) init()
        try {
            var cid1 = fullCategoriesModel.get(index1).cid
            var cid2 = fullCategoriesModel.get(index2).cid
            db.transaction(function(tx){
                var temp = -1
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[temp,cid1])
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[cid1,cid2])
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[cid2,temp])
            })
            fullCategoriesModel.move(index1,index2,1)
            fullCategoriesModel.get(index1).cid = cid1
            fullCategoriesModel.get(index2).cid = cid2
            refreshCategories()
            categoriesChanged()
        } catch(err){
            console.log("Error when swapping categories in table '"+db_table_categories+"' in database '"+db_name+"': " + err)
        }

    }



    /* ------------------------- *
     * ----- open task I/O ----- *
     * ------------------------- */
    function insertOpenTodo(todo){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('INSERT OR IGNORE INTO ' + db_table_todos_open + '(title,category,priority,due,repetition,repetitionCount) VALUES(?,?,?,?,?,?)',
                              [todo.title,todo.category,todo.priority,todo.due,todo.repetition,todo.repetitionCount])
            })
            refreshOpenTodos()
        } catch(err){
            console.log("Error when inserting todo table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }
    }
    function updateOpenTodo(todo){
        print("update todo: ",JSON.stringify(todo))
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + db_table_todos_open + ' SET title=?,category=?,priority=?,due=?,repetition=?,repetitionCount=? WHERE itemid='+todo.itemid,
                              [todo.title,todo.category,todo.priority,todo.due,todo.repetition,todo.repetitionCount])
            })
            refreshOpenTodos()
        } catch(err){
            console.log("Error when updating todo in table '"+db_table_todos_open+"' in database '"+db_name+"': " + err+"\n"+JSON.stringify(todo))
        }
    }
    function selectOpenTodos(){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('SELECT * FROM ' + db_table_todos_open)
            })
            return rt.rows
        } catch(err){
            console.log("Error when selecting all from table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
            return []
        }

    }
    function removeOpenTodo(itemid){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ' + db_table_todos_open + ' WHERE itemid='+itemid)
            })
            refreshOpenTodos()
        } catch(err){
            console.log("Error when deleting todo from table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }

    }
    function swapOpenTodos(index1,index2){
        if (!db) init()
        try {
            var uid1 = openTodosModel.get(index1).itemid
            var uid2 = openTodosModel.get(index2).itemid
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + db_table_todos_open + ' SET itemid=? WHERE itemid=?',[  -1,uid1])
                tx.executeSql('UPDATE ' + db_table_todos_open + ' SET itemid=? WHERE itemid=?',[uid1,uid2])
                tx.executeSql('UPDATE ' + db_table_todos_open + ' SET itemid=? WHERE itemid=?',[uid2,  -1])
            })
            openTodosModel.move(index1,index2,1)
            openTodosModel.get(index1).itemid = uid1
            openTodosModel.get(index2).itemid = uid2
            openTodosChanged()
        } catch(err){
            console.log("Error when swapping todos in table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }

    }

}

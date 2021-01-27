import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0 as Sql

Item{
    id: root

    signal categoriesChanged()
    signal openTodosChanged()
    signal doneTodosChanged()

    property var categoriesNameList: []

    property var categoriesModel: ListModel{}
    property var openTodosModel:  ListModel{}
    property var doneTodosModel:  ListModel{}

    function refreshCategories(){
        if (!db) init()
        categoriesModel.clear()
        categoriesNameList.length = 0
        var cats = selectCategories()
        for (var i=0; i<cats.length; i++){
            categoriesModel.append(cats[i])
            categoriesNameList.push(cats[i].name)
        }
        categoriesChanged()
    }

    function refreshOpenTodos(){
        if (!db) init()
        openTodosModel.clear()
        var todos = selectOpenTodos()
        for (var i=0; i<todos.length; i++){
            openTodosModel.append(todos[i])
        }
        openTodosChanged()
    }

    property var db

    property string db_name: "todos.db"
    property string db_version: "1.0"
    property string db_description: "todos storage"
    property int    db_size: 1024
    property string db_table_categories: "categories1"
    property string db_table_todos_open: "open"
    property string db_table_todos_done: "done"

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
        init_doneTodos()
    }
    function callback(db){/* do nothing */}
    function init_categories(){
        db.transaction(function(tx){
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + db_table_categories + '(cid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, UNIQUE(name))')
            } catch(err){
                console.log("Error when creating table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
        try{
            var colnames = []
            db.transaction(function(tx){
                var rt = tx.executeSql("PRAGMA table_info("+db_table_categories+")")
                for(var i=0;i<rt.rows.length;i++){
                    colnames.push(rt.rows[i].name)
                }
            })
            // since v1.1.0: require primary key cid column
            if (colnames.indexOf("cid")<0){
                db.transaction(function(tx){
                    tx.executeSql("DROP TABLE "+db_table_categories)
                })
                db.transaction(function(tx){
                    tx.executeSql('CREATE TABLE ' + db_table_categories + '(cid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, UNIQUE(name))')
                })
            }
        } catch (err){
            console.error("Error when checking columns of table '"+db_table_categories+"': " + err)
        }
        refreshCategories()
    }
    function init_openTodos(){
        var cmd = 'CREATE TABLE IF NOT EXISTS ' + db_table_todos_open + '('
        cmd    += 'itemid INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, priority INTEGER)'
        db.transaction(function(tx){
            try {
                tx.executeSql(cmd)
            } catch(err){
                console.error("Error when creating table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
            }
        })
        refreshOpenTodos()
    }
    function init_doneTodos(){

    }



    /* ------------------------ *
     * ----- category I/O ----- *
     * ------------------------ */
    function insertCategory(name){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('INSERT OR IGNORE INTO ' + db_table_categories + '(name) VALUES(?)',[name])
            })
            refreshCategories()
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
    function removeCategory(cid){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ' + db_table_categories + ' WHERE cid='+cid)
            })
            refreshCategories()
        } catch(err){
            console.log("Error when deleting category from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
        }

    }
    function swapCategories(index1,index2){
        if (!db) init()
        try {
            var cid1 = categoriesModel.get(index1).cid
            var cid2 = categoriesModel.get(index2).cid
            db.transaction(function(tx){
                var temp = -1
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[temp,cid1])
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[cid1,cid2])
                tx.executeSql('UPDATE ' + db_table_categories + ' SET cid=? WHERE cid=?',[cid2,temp])
            })
            categoriesModel.move(index1,index2,1)
            categoriesModel.get(index1).cid = cid1
            categoriesModel.get(index2).cid = cid2
            var name1 = categoriesNameList[index1]
            categoriesNameList[index1] = categoriesNameList[index2]
            categoriesNameList[index2] = name1
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
                tx.executeSql('INSERT OR IGNORE INTO ' + db_table_todos_open + '(title,category,priority) VALUES(?,?,?)',
                              [todo.title,todo.category,todo.priority])
            })
            refreshOpenTodos()
        } catch(err){
            console.log("Error when inserting todo table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }
    }
    function updateOpenTodo(todo){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + db_table_todos_open + ' SET title=?,category=?,priority=? WHERE itemid='+todo.itemid,
                              [todo.title,todo.category,todo.priority])
            })
            refreshOpenTodos()
        } catch(err){
            console.log("Error when updating todo table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
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

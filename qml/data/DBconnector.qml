/*
 * This template manages all the database I/O for categories and todos
 */

import QtQuick 2.7
import QtQuick.LocalStorage 2.0 as Sql

Item{
    id: root

    property var db

    property string dbName: "todos.db-test"
    property string dbVersion: "1.0"
    property string dbDescription: "todos storage"
    property int    dbSize: 1024

    property string dbTableCategories: "categories"
    property string dbTableOpenTodos: "open"

    /* ------------------------------ *
     * ----- initialisation I/O ----- *
     * ------------------------------ */
    function init(){
        db = Sql.LocalStorage.openDatabaseSync(dbName,dbVersion,dbDescription,dbSize,callback(db))
        init_categories()
        init_openTodos()
    }
    function callback(db){/* do nothing */}
    function init_categories(){
        db.transaction(function(tx){
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + dbTableCategories + '(cid INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, muted INTEGER DEFAULT 0, UNIQUE(name))')
            } catch(err){
                console.error("[ERROR] DBconnector: when creating table '"+dbTableCategories+"': " + err)
            }
        })
    }
    function init_openTodos(){
        var cmd = 'CREATE TABLE IF NOT EXISTS ' + dbTableOpenTodos + '('
        cmd    += 'itemid INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, priority INTEGER, due INTEGER, repetition TEXT DEFAULT "-",repetitionCount INTEGER DEFAULT 1)'
        db.transaction(function(tx){
            try {
                tx.executeSql(cmd)
            } catch(err){
                console.error("[ERROR] DBconnector: when creating table '"+dbTableOpenTodos+"': " + err)
            }
        })
        // check if all required colunms are in table and create missing ones
        try{
            var colnames = []
            db.transaction(function(tx){
                var rt = tx.executeSql("PRAGMA table_info("+dbTableOpenTodos+")")
                for(var i=0;i<rt.rows.length;i++){
                    colnames.push(rt.rows[i].name)
                }
            })
            // since v1.1.0: require columns 'repetition' and 'repetitionCount'
            if (colnames.indexOf("repetition")<0){
                console.log("[INFO] openTodos table: add column 'repetition'")
                db.transaction(function(tx){
                    tx.executeSql("ALTER TABLE "+dbTableOpenTodos+" ADD repetition TEXT DEFAULT '-'")
                })
            }
            if (colnames.indexOf("repetitionCount")<0){
                console.log("[INFO] openTodos table: add column 'repetitionCount'")
                db.transaction(function(tx){
                    tx.executeSql("ALTER TABLE "+dbTableOpenTodos+" ADD repetitionCount INTEGER DEFAULT 1")
                })
            }
        } catch (err){
            console.error("[ERROR] DBconnector: when checking columns of table '"+dbTableOpenTodos+"': " + err)
        }
    }

    /* ------------------------ *
     * ----- category I/O ----- *
     * ------------------------ */
    function insertCategory(name){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('INSERT OR IGNORE INTO ' + dbTableCategories + '(name,muted) VALUES(?,0)',[name])
            })
            return rt.insertID
        } catch(err){
            console.error("[ERROR] DBconnector: when inserting category into table '"+dbTableCategories+"': " + err)
            return -1
        }
    }
    function updateCategory(cat){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + dbTableCategories + ' SET muted=? WHERE cid=?',[cat.muted,cat.cid])
            })
            return true
        } catch(err){
            console.error("[ERROR] DBconnector: when updating category in table '"+dbTableCategories+"': " + err)
            return false
        }
    }
    function selectCategories(){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('SELECT * FROM ' + dbTableCategories)
            })
            return rt.rows
        } catch(err){
            console.error("[ERROR] DBconnector: when selecting all categories from table '"+dbTableCategories+"': " + err)
            return []
        }
    }
    function removeCategory(cid){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ' + dbTableCategories + ' WHERE cid='+cid)
            })
            return true
        } catch(err){
            console.error("[ERROR] DBconnector: when deleting category from table '"+dbTableCategories+"': " + err)
            return false
        }

    }
    function swapCategories(cid1,cid2){
        if (!db) init()
        try {
            db.transaction(function(tx){
                var temp = -1
                tx.executeSql('UPDATE ' + dbTableCategories + ' SET cid=? WHERE cid=?',[temp,cid1])
                tx.executeSql('UPDATE ' + dbTableCategories + ' SET cid=? WHERE cid=?',[cid1,cid2])
                tx.executeSql('UPDATE ' + dbTableCategories + ' SET cid=? WHERE cid=?',[cid2,temp])
            })
            return true
        } catch(err){
            console.error("[ERROR] DBconnector: when swapping categories in table '"+dbTableCategories+"': " + err)
            return false
        }
    }



    /* ------------------------- *
     * ----- open task I/O ----- *
     * ------------------------- */
    function insertOpenTodo(todo){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('INSERT OR IGNORE INTO ' + dbTableOpenTodos + '(title,category,priority,due,repetition,repetitionCount) VALUES(?,?,?,?,?,?)',
                                  [todo.title,todo.category,todo.priority,todo.due,todo.repetition,todo.repetitionCount])
            })
            return parseInt(rt.insertId)
        } catch(err){
            console.error("[ERROR] DBconnector: when inserting todo table '"+dbTableOpenTodos+"': " + err)
            return -1
        }
    }
    function updateOpenTodo(todo){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('UPDATE ' + dbTableOpenTodos + ' SET title=?,category=?,priority=?,due=?,repetition=?,repetitionCount=? WHERE itemid='+todo.itemid,
                              [todo.title,todo.category,todo.priority,todo.due,todo.repetition,todo.repetitionCount])
            })
            return true
        } catch(err){
            console.error("[ERROR] DBconnector: when updating todo in table '"+dbTableOpenTodos+"': " + err)
            return false
        }
    }
    function selectOpenTodos(){
        if (!db) init()
        try {
            var rt
            db.transaction(function(tx){
                rt = tx.executeSql('SELECT * FROM ' + dbTableOpenTodos)
            })
            return rt.rows
        } catch(err){
            console.error("[ERROR] DBconnector: when selecting all from table '"+dbTableOpenTodos+"': " + err)
            return []
        }
    }
    function removeOpenTodo(itemid){
        if (!db) init()
        try {
            db.transaction(function(tx){
                tx.executeSql('DELETE FROM ' + dbTableOpenTodos + ' WHERE itemid='+itemid)
            })
            return true
        } catch(err){
            console.error("[ERROR] DBconnector: when deleting todo from table '"+dbTableOpenTodos+"': " + err)
            return false
        }
    }



}

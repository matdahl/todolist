/*
 * Copyright (C) 2020  Matthias Dahlmanns
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * todolist is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import QtQuick.LocalStorage 2.0 as Sql

import "panels"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'todolist.todolist.mdahl'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property var categories: []

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('To Do List')

            leadingActionBar.actions: [
                Action{
                    iconName: "back"
                    visible: stack.depth > 1
                    onTriggered: stack.pop()
                }

            ]
            trailingActionBar.actions:[
                Action{
                    iconName: "add"
                    text: "Add todo"
                    onTriggered: {
                        if (stack.currentItem!==editPanel){
                            stack.collapse()
                            stack.push(editPanel)
                        }
                    }
                },
                Action{
                    iconName: "settings"
                    text:     "Settings"
                    onTriggered: {
                        if (stack.currentItem!==settingsPanel){
                            while (stack.depth>1) stack.pop()
                            stack.push(settingsPanel)
                        }
                    }
                }
            ]
        }

        StackView{
            id: stack
            anchors.fill: parent

            function collapse(){
                while (depth>1) pop()
            }

            ListPanel{
                id: listPanel
                categories: root.categories
                Component.onCompleted: stack.push(listPanel)
                onDeleteItem: db_delete_opentodo(itemid)
                onAchieved: db_move_to_done(itemid)
                onRefresh: db_read_opentodos()
                onEditItem: {
                    editPanel.set(todo,"edit")
                    stack.push(editPanel)
                }
            }

            SettingsPanel{
                id: settingsPanel
                categories: root.categories
                visible: false
                stack: stack
                onAdd_category:    db_add_category(name)
                onDelete_category: db_delete_category(name)
            }

            TodoEditPanel{
                id: editPanel
                categories: root.categories
                visible: false
                onAdded:  db_add_opentodo(todo)
                onEdited: db_edit_opentodo(todo)
            }
        }
    }

    Component.onCompleted: {
        initDB()
        db_read_categories()
        db_read_opentodos()
    }

    /* database functions */
    property var    db
    property string db_name: "todos.db"
    property string db_version: "1.0"
    property string db_description: "todos storage"
    property int    db_size: 1024
    property string db_table_todos_open: "open"
    property string db_table_todos_done: "done"
    property string db_table_categories: "categories1"

    // initialise the database
    function initDB(){
        // open database
        db = Sql.LocalStorage.openDatabaseSync(db_name,
                                               db_version,
                                               db_description,
                                               db_size,
                                               db_test_callback(db))

        // create open todo table if needed
        var cmd = 'CREATE TABLE IF NOT EXISTS ' + db_table_todos_open + '('
        cmd += 'itemid INTEGER PRIMARY KEY AUTOINCREMENT,'
        cmd += 'title TEXT, category TEXT, priority INTEGER)'
        db.transaction(function(tx){
            try {
                tx.executeSql(cmd)
            } catch(err){
                console.error("Error when creating table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
            }
        })

        // create done todo table if needed
        cmd  = 'CREATE TABLE IF NOT EXISTS ' + db_table_todos_done + '('
        cmd += 'itemid INTEGER, title TEXT, category TEXT, date TEXT)'
        db.transaction(function(tx){
            try {
                tx.executeSql(cmd)
            } catch(err){
                console.error("Error when creating table '"+db_table_todos_done+"' in database '"+db_name+"': " + err)
            }
        })

        // create categories table if needed
        db.transaction(function(tx){
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + db_table_categories + '(name TEXT, UNIQUE(name))')
            } catch(err){
                console.log("Error when creating table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
    }
    function db_test_callback(db){ /* do nothing */ }

    // checks whether certain category names are invalid
    property var invalidCategories: ["All","other",""]
    function isValidCategory(name){
        for (var i=0; i<invalidCategories.length; i++){
            if (name===invalidCategories[i]) return false
        }
        return true
    }

    // read categories from database
    function db_read_categories(){
        if (!db) return
        db.transaction(function(tx){
            try {
                var rt = tx.executeSql("SELECT * FROM "+db_table_categories)
                categories = []
                for (var i=0; i<rt.rows.length; i++){
                    categories.push(rt.rows[i].name)
                }
            } catch (err){
                console.error("Error reading from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
        listPanel.categories = categories
        settingsPanel.categories = categories
        editPanel.categories = categories
    }
    // add category to database
    function db_add_category(name){
        // check if everything is correct
        if (!(db && isValidCategory(name))) return

        db.transaction(function(tx){
            try {
                tx.executeSql("INSERT OR IGNORE INTO "+db_table_categories+" VALUES ('"+name+"')")
            } catch (err){
                console.error("Error insert into table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
        db_read_categories()
    }
    // remove category from database
    function db_delete_category(name){
        if (!db) return
        db.transaction(function(tx){
            try {
                tx.executeSql("DELETE FROM "+db_table_categories+" WHERE name='"+name+"'")
            } catch (err){
                console.error("Error deleting '"+name+"' from table '"+db_table_categories+"' in database '"+db_name+"': " + err)
            }
        })
        db_read_categories()
    }

    // read open todos from database
    function db_read_opentodos(){
        if (!db) return
        try {
            // assemble SQL statement
            var currentCategory = listPanel.selectedCategory
            var sqlStatement = "SELECT * FROM " + db_table_todos_open
            if (currentCategory !== "All" && currentCategory !== "other")
                sqlStatement += " WHERE category='"+currentCategory+"'"

            // request data
            var rt
            db.transaction(function(tx){rt = tx.executeSql(sqlStatement)})

            // import data into listModel
            listPanel.model.clear()
            for (var i=0; i<rt.rows.length; i++){
                // if "other" is selected, insert only if category is not in current category list
                if (currentCategory==="other" && categories.indexOf(rt.rows.item(i).category) !== -1)
                    continue
                listPanel.model.append(rt.rows.item(i))
            }
            listPanel.model.sort()
        } catch (err){
            console.error("Error reading from table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }

    }
    // insert new open todo into database
    function db_add_opentodo(todo){
        if (!db) return
        db.transaction(function(tx){
            try {
                tx.executeSql("INSERT INTO "+db_table_todos_open+" VALUES (NULL,?,?,?)",
                              [todo.title,todo.category,todo.priority])
            } catch (err){
                console.error("Error when insert into table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
            }
        })
        db_read_opentodos()
    }
    // delete open todo from database
    function db_delete_opentodo(itemid){
        if (!db) return
        try {
            db.transaction(function(tx){
                tx.executeSql("DELETE FROM "+db_table_todos_open+" WHERE itemid=?",[itemid])
            })
        } catch (err){
            console.error("Error when delete from table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }
        db_read_opentodos()
    }
    // edit open todo in database
    function db_edit_opentodo(todo){
        if (!db) return
        try{
            db.transaction(function(tx){
                tx.executeSql("UPDATE "+db_table_todos_open+" SET title=?,category=?,priority=? WHERE itemid=?",
                              [todo.title,todo.category,todo.priority,todo.itemid])
            })
        } catch(err){
            console.error("Error when updating in table '"+db_table_todos_open+"' in database '"+db_name+"': " + err)
        }
        db_read_opentodos()
    }

    // move a todo from open to done in database
    function db_move_to_done(itemid){
        // request item from database
        var rt
        db.transaction(function(tx){
            rt = tx.executeSql("SELECT * FROM "+db_table_todos_open+" WHERE itemid=?",
                          [itemid])
        })
        if (rt.rows.length !== 1){
            console.error("Invalid number of matches("+rt.rows.length+") when moving todo with id "+itemid+" from open to done.")
            return
        }

        // insert todo into done table
        db.transaction(function(tx){
            tx.executeSql("INSERT INTO "+db_table_todos_done+" VALUES(?,?,?,?)",
                          [itemid,rt.rows.item(0).title,rt.rows.item(0).category,Date()])
        })

        // remove todo from open table
        db.transaction(function(tx){
            tx.executeSql("DELETE FROM "+db_table_todos_open+" WHERE itemid=?",
                          [itemid])
        })

        // refresh GUI
        db_read_opentodos()
    }
    // read done todos from database
    function db_read_donetodos(){
        if (!db) return
    }
    // delete done todo from database
    function db_delete_donetodo(itemid){
        if (!db) return
        try {
            db.transaction(function(tx){
                tx.executeSql("DELETE FROM "+db_table_todos_done+" WHERE itemid=?",
                              [itemid])
            })
        } catch (err){
            console.error("Error when delete from table '"+db_table_todos_done+"' in database '"+db_name+"': " + err)
        }
    }
}

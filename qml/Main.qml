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
import "data"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'todolist.todolist.mdahl'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Colors{
        id: colors
        initialIndex: 7
    }

    theme.name: colors.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
    backgroundColor: colors.currentBackground

    Component.onCompleted: dbtodos.init()

    Settings{
        id: settings
        category: "General"
        property int maximalPriority: 3
    }

    DBtodos{
        id: dbtodos
    }

    property var categories: []

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('To Do List') + (stack.currentItem.headerSuffix ? " - "+stack.currentItem.headerSuffix : "")
            StyleHints{backgroundColor:colors.currentHeader}

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
                    visible: stack.currentItem===listPanel
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
                    visible: stack.currentItem===listPanel || stack.currentItem===editPanel
                    onTriggered: {
                        if (stack.currentItem!==settingsPanel){
                            while (stack.depth>1) stack.pop()
                            stack.push(settingsPanel)
                        }
                    }
                }
            ]
        }

        Rectangle{
            id: background
            anchors.fill: parent
            color: colors.currentBackground
        }

        StackView{
            id: stack
            anchors.fill: parent

            function collapse(){
                while (depth>1) pop()
            }

            ListPanel{
                id: listPanel
                Component.onCompleted: stack.push(listPanel)
            }

            SettingsPanel{
                id: settingsPanel
                visible: false
                stack: stack
            }

            TodoEditPanel{
                id: editPanel
                categories: root.categories
                visible: false
                onAdded:  dbtodos.insertOpenTodo(todo)
                onEdited: dbtodos.updateOpenTodo(todo)
            }
        }
    }
}

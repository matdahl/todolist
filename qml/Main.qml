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
import "dialogs"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'todolist.matdahl'
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)

    /* -------------------
     * ----- theming -----
     * ------------------- */

    Colors{
        id: colors
        defaultIndex: 7
    }
    theme.name: colors.currentThemeName

    /* --------------------
     * ----- settings -----
     * -------------------- */

    Settings{
        id: settings
        category: "General"
        property int maximalPriority: 3
        property int defaultPriority: 2
        property bool hasDueByDefault: false
        property int  defaultDueOffset: 1    // default number of days from today when task is due by default
        property bool   hasRepetitionByDefault: false
        property string defaultRepetitionUnit: "w"
        property int    defaultRepetitionCount: 1
    }

    /* -----------------
     * ----- model -----
     * ----------------- */

    TodoModels{
        id: models
    }

    /* ----------------------
     * ----- components -----
     * ---------------------- */

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('To Do Lists') + (stack.currentItem.headerSuffix ? " - "+stack.currentItem.headerSuffix : "")
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
                    iconName: "settings"
                    visible: stack.currentItem===listPanel
                    onTriggered: {
                        if (stack.currentItem!==settingsPanel){
                            while (stack.depth>1) stack.pop()
                            stack.push(settingsPanel)
                        }
                    }
                },
                Action{
                    iconName: "sort-listitem"
                    visible: stack.currentItem===listPanel
                    onTriggered: listPanel.showSortModeSelect = !listPanel.showSortModeSelect
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
            anchors.bottomMargin: bottomEdge.hint.visible ? bottomEdge.hint.height : 0
            onCurrentItemChanged: bottomEdge.collapse()
        }

        ListPanel{
            id: listPanel
            Component.onCompleted: stack.push(listPanel)
        }

        SettingsPanel{
            id: settingsPanel
            visible: false
        }

        TaskInsertBottomEdge{
            id: bottomEdge
            hint.visible: stack.currentItem === listPanel
        }

        RepetitionSelectPopover{
            id: repetitionSelectPopover
        }


        /* -------------------
         * ----- dialogs -----
         * ------------------- */

        TaskEditDialog{
            id: taskEditDialog
        }
    }
}

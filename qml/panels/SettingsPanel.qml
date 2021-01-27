import QtQuick 2.7
import Ubuntu.Components 1.3
import "../components"

Item{
    id: root

    property var stack

    property bool useDarkMode: true

    Column{
        id: col
        width: root.width
        SettingsMenuItem{
            text: "Categories"
            stack: root.stack
            subpage: catPanel
        }
        SettingsMenuSwitch{
            id: itDarkMode
            text: i18n.tr("Dark Mode")
            checked: root.useDarkMode
            onCheckedChanged: root.useDarkMode = checked
        }
    }

    // the panel to manage the book categories
    SettingsCategoriesPanel{
        id: catPanel
        visible: false
    }
}

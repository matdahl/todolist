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
        SettingsCaption{
            title: i18n.tr("Appearance")
        }
        SettingsMenuSwitch{
            text: i18n.tr("Dark Mode")
            Component.onCompleted: checked = colors.darkMode
            onCheckedChanged: colors.darkMode = checked
        }
        SettingsMenuDoubleColorSelect{
            text: i18n.tr("Color")
            model: colors.headerColors
            Component.onCompleted: currentSelectedColor = colors.currentIndex
            onCurrentSelectedColorChanged: colors.currentIndex = currentSelectedColor
        }
    }

    // the panel to manage the book categories
    SettingsCategoriesPanel{
        id: catPanel
        visible: false
    }
}

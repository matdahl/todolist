import QtQuick 2.7
import Ubuntu.Components 1.3

import "../components"
import "../components/settings"

Item{
    id: root

    property string headerSuffix: i18n.tr("Settings")

    ScrollView{
        id: scroll
        anchors.fill: parent
        Column{
            id: col
            width: scroll.width
            SettingsMenuItem{
                text: i18n.tr("Categories")
                subpage: catPanel
            }

            SettingsCaption{
                title: i18n.tr("Parameters")
            }
            SettingsEntryInteger{
                id: stMaxPriority
                text: i18n.tr("Highest Priority")
                minvalue: 1
                maxvalue: 9
                Component.onCompleted: value = settings.maximalPriority
                onValueChanged: {
                    settings.maximalPriority = value
                    if (value < settings.defaultPriority){
                        settings.defaultPriority = value
                        stDefaultPriority.value = value
                    }
                }
            }
            SettingsEntryInteger{
                id: stDefaultPriority
                text: i18n.tr("Default Priority")
                minvalue: 0
                maxvalue: settings.maximalPriority
                Component.onCompleted: value = settings.defaultPriority
                onValueChanged: settings.defaultPriority = value
            }
            SettingsMenuSwitch{
                id: stDueByDefault
                text: i18n.tr("Set deadline by default")
                Component.onCompleted: checked = settings.hasDueByDefault
                onCheckedChanged: settings.hasDueByDefault = checked
            }
            SettingsEntryInteger{
                id: stDefaultDueOffset
                text: i18n.tr("Default offset for deadline (days)")
                minvalue: 0
                maxvalue: 10000
                Component.onCompleted: value = settings.defaultDueOffset
                onValueChanged: settings.defaultDueOffset = value
            }
            SettingsEntryRepetition{
                id: stDefaultRepetitionInterval
                text: i18n.tr("Default repetition interval")
            }
            SettingsCaption{
                title: i18n.tr("Appearance")
            }
            SettingsMenuSwitch{
                text: i18n.tr("Use default theme")
                Component.onCompleted: checked = colors.useDefaultTheme
                onCheckedChanged: colors.useDefaultTheme = checked
            }

            SettingsMenuSwitch{
                enabled: !colors.useDefaultTheme
                text: i18n.tr("Dark Mode")
                Component.onCompleted: checked = colors.darkMode
                onCheckedChanged: colors.darkMode = checked
            }
            SettingsMenuDoubleColorSelect{
                enabled: !colors.useDefaultTheme
                onEnabledChanged: if (!enabled) expanded = false
                text: i18n.tr("Color")
                model: colors.headerColors
                Component.onCompleted: currentSelectedColor = colors.currentIndex
                onCurrentSelectedColorChanged: colors.currentIndex = currentSelectedColor
            }
        }
    }

    // the panel to manage the book categories
    SettingsCategoriesPanel{
        id: catPanel
        visible: false
    }
}

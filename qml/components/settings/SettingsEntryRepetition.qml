import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

import ".."

ListItem{
    id: root

    property string text: ""

    ListItemLayout{
        id: layout
        summary{
            text: root.text
            textSize: Label.Medium
            color: theme.palette.normal.backgroundText
        }

        RepetitionIntervalButton{
            id: button
            SlotsLayout.position: SlotsLayout.Last
            width: units.gu(16)
            onIntervalChanged: settings.defaultRepetitionUnit = interval
            onIntervalCountChanged: settings.defaultRepetitionCount = intervalCount
            Component.onCompleted: {
                interval = settings.defaultRepetitionUnit
                intervalCount = settings.defaultRepetitionCount
            }
        }
    }
}

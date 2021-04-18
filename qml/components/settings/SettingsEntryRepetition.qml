import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

import ".."

ListItem{
    id: root

    property string text: ""

    ListItemLayout{
        id: layout
        title.text: root.text

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

import QtQuick 2.7
import Ubuntu.Components 1.3

import "../dialogs"

Button{
    id: root
    text: enabled ? interval==="m" ? intervalCount===1 ? i18n.tr("monthly") : i18n.tr("every %1 months").arg(intervalCount)
                                   : interval==="w" ? intervalCount===1 ? i18n.tr("weekly") : i18n.tr("every %1 weeks").arg(intervalCount)
                                                    : intervalCount===1 ? i18n.tr("daily")  : i18n.tr("every %1 days").arg(intervalCount)
                  : i18n.tr("no repetition")
    onClicked: repetitionSelectPopover.open(root)
    property string interval: "d"
    property int    intervalCount: 1

    RepetitionSelectPopover{
        id: repetitionSelectPopover
    }
}


import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

Item {
    id: root

    property var host

    function open(host){
        root.host = host
        PopupUtils.open(popoverComponent, host)
    }

    Component{
        id: popoverComponent
        Popover{
            id: popover
            Row{
                spacing: units.gu(2)
                padding: units.gu(2)
                Picker{
                    id: countPicker
                    width: 0.4*popover.contentWidth - units.gu(3)
                    model: 100
                    circular: false
                    delegate: PickerDelegate{
                        Label{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: index+1
                        }
                    }
                    Component.onCompleted: selectedIndex = host.intervalCount>0 ? host.intervalCount-1 : 0
                    onSelectedIndexChanged: host.intervalCount = selectedIndex+1
                }
                OptionSelector{
                    id: intervalPicker
                    anchors.verticalCenter: countPicker.verticalCenter
                    width: 0.6*popover.contentWidth - units.gu(3)
                    expanded: true
                    model: [i18n.tr("days"),i18n.tr("weeks"),i18n.tr("months")]
                    delegate: OptionSelectorDelegate{
                        text: modelData
                    }
                    Component.onCompleted: selectedIndex = host.interval==="m" ? 2 : host.interval==="w" ? 1 : 0
                    onSelectedIndexChanged: host.interval = selectedIndex===0 ? "d" : selectedIndex===1 ? "w" : "m"
                }
            }
        }
    }
}

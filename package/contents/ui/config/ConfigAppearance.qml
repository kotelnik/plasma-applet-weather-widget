import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property bool cfg_fahrenheitEnabled
    property int cfg_layoutType

    onCfg_fahrenheitEnabledChanged: {
        if (cfg_fahrenheitEnabled) {
            temperatureTypeGroup.current = temperatureFahrenheit
        } else {
            temperatureTypeGroup.current = temperatureCelsius
        }
    }
    
    onCfg_layoutTypeChanged: {
        switch (cfg_layoutType) {
        case 0:
            layoutTypeGroup.current = layoutTypeRadioHorizontal;
            break;
        case 1:
            layoutTypeGroup.current = layoutTypeRadioVertical;
            break;
        case 2:
            layoutTypeGroup.current = layoutTypeRadioCompact;
            break;
        default:
        }
    }
    
    Component.onCompleted: {
        cfg_fahrenheitEnabledChanged()
        cfg_layoutTypeChanged()
    }
    
    ExclusiveGroup {
        id: temperatureTypeGroup
    }
    
    ExclusiveGroup {
        id: layoutTypeGroup
    }
    
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        Label {
            text: i18n("Temperature:")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: temperatureCelsius
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°C")
            onCheckedChanged: if (checked) cfg_fahrenheitEnabled = false
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureFahrenheit
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°F")
            onCheckedChanged: if (checked) cfg_fahrenheitEnabled = true
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Layout type:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        RadioButton {
            id: layoutTypeRadioHorizontal
            exclusiveGroup: layoutTypeGroup
            text: i18n("Horizontal")
            onCheckedChanged: if (checked) cfg_layoutType = 0;
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        RadioButton {
            id: layoutTypeRadioVertical
            exclusiveGroup: layoutTypeGroup
            text: i18n("Vertical")
            onCheckedChanged: if (checked) cfg_layoutType = 1;
        }
        RadioButton {
            id: layoutTypeRadioCompact
            exclusiveGroup: layoutTypeGroup
            text: i18n("Compact")
            onCheckedChanged: if (checked) cfg_layoutType = 2;
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('NOTE: Setting layout type for in-tray plasmoid has no effect.')
            Layout.columnSpan: 2
        }
    }
    
}

import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_compactLayout: compactLayout.checked
    property int cfg_fahrenheitEnabled

    onCfg_fahrenheitEnabledChanged: {
        if (cfg_fahrenheitEnabled) {
            temperatureTypeGroup.current = temperatureFahrenheit
        } else {
            temperatureTypeGroup.current = temperatureCelsius
        }
    }
    
    ExclusiveGroup {
        id: temperatureTypeGroup
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
        }
        
        CheckBox {
            id: compactLayout
            Layout.columnSpan: 2
            text: i18n('Vertical layout')
            enabled: false
        }
    }
    
}

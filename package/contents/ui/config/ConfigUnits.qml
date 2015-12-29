import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    
    property bool cfg_fahrenheitEnabled
    property bool cfg_inhgEnabled
    property bool cfg_mphEnabled
    
    onCfg_fahrenheitEnabledChanged: {
        if (cfg_fahrenheitEnabled) {
            temperatureTypeGroup.current = temperatureFahrenheit
        } else {
            temperatureTypeGroup.current = temperatureCelsius
        }
    }
    
    onCfg_inhgEnabledChanged: {
        if (cfg_inhgEnabled) {
            pressureTypeGroup.current = pressureInhg
        } else {
            pressureTypeGroup.current = pressureHpa
        }
    }
    
    onCfg_mphEnabledChanged: {
        if (cfg_mphEnabled) {
            windSpeedTypeGroup.current = speedMph
        } else {
            windSpeedTypeGroup.current = speedMps
        }
    }
    
    Component.onCompleted: {
        cfg_fahrenheitEnabledChanged()
        cfg_inhgEnabledChanged()
        cfg_mphEnabledChanged()
    }
    
    ExclusiveGroup {
        id: temperatureTypeGroup
    }
    
    ExclusiveGroup {
        id: pressureTypeGroup
    }
    
    ExclusiveGroup {
        id: windSpeedTypeGroup
    }
    
    GridLayout {
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
            text: i18n("Pressure:")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: pressureHpa
            exclusiveGroup: pressureTypeGroup
            text: i18n("hPa")
            onCheckedChanged: if (checked) cfg_inhgEnabled = false
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: pressureInhg
            exclusiveGroup: pressureTypeGroup
            text: i18n("inHg")
            onCheckedChanged: if (checked) cfg_inhgEnabled = true
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n("Wind speed:")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: speedMps
            exclusiveGroup: windSpeedTypeGroup
            text: i18n("m/s")
            onCheckedChanged: if (checked) cfg_mphEnabled = false
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: speedMph
            exclusiveGroup: windSpeedTypeGroup
            text: i18n("mph")
            onCheckedChanged: if (checked) cfg_mphEnabled = true
        }
    }
    
}

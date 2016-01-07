import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    
    property int cfg_temperatureType
    property int cfg_pressureType
    property int cfg_windSpeedType
    
    onCfg_temperatureTypeChanged: {
        switch (cfg_temperatureType) {
        case 0:
            temperatureTypeGroup.current = temperatureTypeRadioCelsius;
            break;
        case 1:
            temperatureTypeGroup.current = temperatureTypeRadioFahrenheit;
            break;
        default:
        }
    }
    
    onCfg_pressureTypeChanged: {
        switch (cfg_pressureType) {
        case 0:
            pressureTypeGroup.current = pressureTypeRadioHpa;
            break;
        case 1:
            pressureTypeGroup.current = pressureTypeRadioInhg;
            break;
        case 2:
            pressureTypeGroup.current = pressureTypeRadioMmhg;
            break;
        default:
        }
    }
    
    onCfg_windSpeedTypeChanged: {
        switch (cfg_windSpeedType) {
        case 0:
            windSpeedTypeGroup.current = windSpeedTypeRadioMps;
            break;
        case 1:
            windSpeedTypeGroup.current = windSpeedTypeRadioMph;
            break;
        default:
        }
    }
    
    Component.onCompleted: {
        cfg_temperatureTypeChanged()
        cfg_pressureTypeChanged()
        cfg_windSpeedTypeChanged()
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
            id: temperatureTypeRadioCelsius
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°C")
            onCheckedChanged: if (checked) cfg_temperatureType = 0
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: temperatureTypeRadioFahrenheit
            exclusiveGroup: temperatureTypeGroup
            text: i18n("°F")
            onCheckedChanged: if (checked) cfg_temperatureType = 1
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
            id: pressureTypeRadioHpa
            exclusiveGroup: pressureTypeGroup
            text: i18n("hPa")
            onCheckedChanged: if (checked) cfg_pressureType = 0
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        RadioButton {
            id: pressureTypeRadioInhg
            exclusiveGroup: pressureTypeGroup
            text: i18n("inHg")
            onCheckedChanged: if (checked) cfg_pressureType = 1
        }
        RadioButton {
            id: pressureTypeRadioMmhg
            exclusiveGroup: pressureTypeGroup
            text: i18n("mmHg")
            onCheckedChanged: if (checked) cfg_pressureType = 2
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
            id: windSpeedTypeRadioMps
            exclusiveGroup: windSpeedTypeGroup
            text: i18n("m/s")
            onCheckedChanged: if (checked) cfg_windSpeedType = 0
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 1
        }
        RadioButton {
            id: windSpeedTypeRadioMph
            exclusiveGroup: windSpeedTypeGroup
            text: i18n("mph")
            onCheckedChanged: if (checked) cfg_windSpeedType = 1
        }
    }
    
}

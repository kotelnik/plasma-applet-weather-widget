import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {

    property alias cfg_lat: lat.text
    property alias cfg_lon: lon.text
    property alias cfg_town: town.text
    property alias cfg_reloadIntervalMin: reloadIntervalMin.value
    
    property int textfieldWidth: theme.defaultFont.pointSize * 30

    GridLayout {
        columns: 2
        
        Label {
            text: i18n('Location')
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }
        
        Item {
            width: 2
            height: 2
        }
        
        Label {
            text: i18n('Latitude:')
            Layout.alignment: Qt.AlignRight
        }
        
        TextField {
            id: lat
            validator: DoubleValidator {
                bottom: -90
                top: 90
            }
            Layout.preferredWidth: textfieldWidth
        }
        
        Label {
            text: i18n('Longitude:')
            Layout.alignment: Qt.AlignRight
        }
        
        TextField {
            id: lon
            validator: DoubleValidator {
                bottom: -180
                top: 180
            }
            Layout.preferredWidth: textfieldWidth
        }
        
        Label {
            text: i18n('Town string:')
            Layout.alignment: Qt.AlignRight
        }
        
        TextField {
            id: town
            placeholderText: 'Town'
            Layout.preferredWidth: textfieldWidth
        }
        
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 3
        }
        
        Text {
            font.italic: true
            text: 'Find your town string in yr.no (english version)\nand place here the end of URL (without enclosing slashes) like this:\nhttp://www.yr.no/place/Germany/North_Rhine-Westphalia/Bonn/'
            Layout.preferredWidth: textfieldWidth
        }
        
        Item {
            height: theme.defaultFont.pointSize * 2.5
            Text {
                id: arrowText
                font.italic: true
                text: '-> '
            }
            Text {
                anchors.left: arrowText.right
                font.italic: true
                font.bold: true
                text: 'Germany/North_Rhine-Westphalia/Bonn'
            }
            Layout.preferredWidth: textfieldWidth
        }
        
        Text {
            text: 'NOTE: This will get automated in future versions.'
            Layout.preferredWidth: textfieldWidth
        }
        
        Item {
            width: 2
            height: 2
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Miscelaneous')
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }
        
        Item {
            width: 2
            height: 2
        }

        Label {
            text: i18n('Reload interval:')
            Layout.alignment: Qt.AlignRight
        }
        
        SpinBox {
            id: reloadIntervalMin
            decimals: 0
            stepSize: 10
            minimumValue: 20
            maximumValue: 120
            suffix: i18nc('Abbreviation for minutes', 'min')
        }
        
    }
    
}

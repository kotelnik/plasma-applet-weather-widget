import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import "../../code/config-utils.js" as ConfigUtils

Item {

    property alias cfg_reloadIntervalMin: reloadIntervalMin.value
    property string cfg_townStrings
    
    property int textfieldWidth: theme.defaultFont.pointSize * 50

    ListModel {
        id: townStringsModel
    }
    
    Component.onCompleted: {
        var townStrings = ConfigUtils.getTownStringArray()
        for (var i = 0; i < townStrings.length; i++) {
            townStringsModel.append({
                townString: townStrings[i]
            })
        }
    }
    
    function townStringsModelChanged() {
        var newTownStrings = ''
        for (var i = 0; i < townStringsModel.count; i++) {
            var townString = townStringsModel.get(i).townString
            if (i > 0) {
                newTownStrings += ','
            }
            newTownStrings += townString
        }
        cfg_townStrings = newTownStrings
        print('townStrings: ' + cfg_townStrings)
    }
    
    
    Dialog {
        id: addTownStringDialog
        title: "Add Place"
        
        width: 300
        height: 100

        contentItem: Item {
            
            GridLayout {
                columns: 1
                
                TextField {
                    id: newTownStringField
                    placeholderText: 'Paste URL here'
                    Layout.preferredWidth: addTownStringDialog.width
                    Layout.preferredHeight: addTownStringDialog.height / 2
                }
                
                Button {
                    text: 'Add'
                    width: addTownStringDialog.width
                    Layout.preferredHeight: addTownStringDialog.height / 2
                    onClicked: {
                        
                        //http://www.yr.no/place/Germany/North_Rhine-Westphalia/Bonn/
                        var url = newTownStringField.text
                        var match = /https?:\/\/www\.yr\.no\/[a-zA-Z]+\/([^\/ ]+\/[^\/ ]+\/[^\/ ]+)(\/.*)?/.exec(url)
                        var resultString = null
                        if (match !== null) {
                            resultString = match[1]
                        }
                        if (!resultString) {
                            newTownStringField.text = 'Error parsing url.'
                            return
                        }
                        
                        townStringsModel.append({
                            townString: decodeURI(resultString)
                        })
                        townStringsModelChanged()
                        addTownStringDialog.close()
                    }
                }
            }
        }
    }
    
    
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
        
        TableView {
            id: townStringTable
            headerVisible: false
            
            TableViewColumn {
                role: 'townString'
                title: "Town String"
                width: textfieldWidth * 0.7
            }
            
            TableViewColumn {
                title: "Action"
                width: textfieldWidth * 0.3 - 4
                
                delegate: Item {
                    
                    GridLayout {
                        columns: 3
                        
                        Button {
                            iconName: 'go-up'
                            Layout.preferredHeight: 23
                            onClicked: {
                                townStringsModel.move(styleData.row, styleData.row - 1, 1)
                                townStringsModelChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.preferredHeight: 23
                            onClicked: {
                                townStringsModel.move(styleData.row, styleData.row + 1, 1)
                                townStringsModelChanged()
                            }
                            enabled: styleData.row < townStringsModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.preferredHeight: 23
                            onClicked: {
                                townStringsModel.remove(styleData.row)
                                townStringsModelChanged()
                            }
                        }
                    }
                }
                
            }
            model: townStringsModel
            Layout.preferredHeight: 150
            Layout.preferredWidth: textfieldWidth
            Layout.columnSpan: 2
        }
        Button {
            iconName: 'list-add'
            Layout.preferredWidth: 100
            Layout.columnSpan: 2
            onClicked: {
                addTownStringDialog.open()
            }
        }
        
        Item {
            width: 2
            height: 20
            Layout.columnSpan: 2
        }
        
        Text {
            font.italic: true
            text: 'Find your town string in yr.no (english version)\nand use the URL from your browser to add a new location. E.g. paste this:\nhttp://www.yr.no/place/Germany/North_Rhine-Westphalia/Bonn/'
            Layout.preferredWidth: textfieldWidth
            Layout.columnSpan: 2
        }
        
        Text {
            text: 'NOTE: This will get automated in future versions.'
            Layout.preferredWidth: textfieldWidth
            Layout.columnSpan: 2
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

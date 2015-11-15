import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import "../../code/config-utils.js" as ConfigUtils

Item {

    property alias cfg_reloadIntervalMin: reloadIntervalMin.value
    property string cfg_townStrings
    
    ListModel {
        id: townStringsModel
    }
    
    Component.onCompleted: {
        var townStrings = ConfigUtils.getTownStringArray()
        for (var i = 0; i < townStrings.length; i++) {
            townStringsModel.append({
                townString: townStrings[i].townString,
                placeAlias: townStrings[i].placeAlias
            })
        }
    }
    
    function townStringsModelChanged() {
        var newTownStringsArray = []
        for (var i = 0; i < townStringsModel.count; i++) {
            var townString = townStringsModel.get(i).townString
            var placeAlias = townStringsModel.get(i).placeAlias
            newTownStringsArray.push({
                townString: townString,
                placeAlias: placeAlias
            })
        }
        cfg_townStrings = JSON.stringify(newTownStringsArray)
        print('[weatherWidget] townStrings: ' + cfg_townStrings)
    }
    
    
    Dialog {
        id: addTownStringDialog
        title: 'Add Place'
        
        width: 500
        
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        
        onAccepted: {
            //http://www.yr.no/place/Germany/North_Rhine-Westphalia/Bonn/
            var url = newTownStringField.text
            var match = /https?:\/\/www\.yr\.no\/[a-zA-Z]+\/(([^\/ ]+\/){2,}[^\/ ]+)\/[^\/ ]*/.exec(url)
            var resultString = null
            if (match !== null) {
                resultString = match[1]
            }
            if (!resultString) {
                newTownStringField.text = 'Error parsing url.'
                return
            }
            
            var placeAlias = resultString.substring(resultString.lastIndexOf('/') + 1).replace(/_/g, ' ')
            
            townStringsModel.append({
                townString: decodeURI(resultString),
                placeAlias: decodeURI(placeAlias)
            })
            townStringsModelChanged()
            addTownStringDialog.close()
        }
        
        TextField {
            id: newTownStringField
            placeholderText: 'Paste URL here'
            width: parent.width
        }
    }
    
    Dialog {
        id: changePlaceAliasDialog
        title: 'Change Alias'
        
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        
        onAccepted: {
            var newPlaceAlias = newPlaceAliasField.text
            
            townStringsModel.setProperty(changePlaceAliasDialog.tableIndex, 'placeAlias', newPlaceAlias)
            
            townStringsModelChanged()
            changePlaceAliasDialog.close()
        }
        
        property int tableIndex: 0
        
        TextField {
            id: newPlaceAliasField
            placeholderText: 'Enter place alias'
            width: parent.width
        }
    }
    
    GridLayout {
        columns: 2
        anchors.left: parent.left
        anchors.right: parent.right
        
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
            width: parent.width
            
            TableViewColumn {
                role: 'townString'
                title: 'Town String'
                width: parent.width * 0.5
            }
            
            TableViewColumn {
                role: 'placeAlias'
                title: 'Place Alias'
                width: parent.width * 0.2
                
                delegate: MouseArea {
                    
                    anchors.fill: parent
                    
                    Label {
                        id: placeAliasText
                        text: styleData.value
                        height: parent.height
                    }
                    
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        changePlaceAliasDialog.open()
                        changePlaceAliasDialog.tableIndex = styleData.row
                        newPlaceAliasField.text = placeAliasText.text
                        newPlaceAliasField.focus = true
                    }
                }
            }
            
            TableViewColumn {
                title: "Action"
                width: parent.width * 0.2
                
                delegate: Item {
                    
                    GridLayout {
                        height: parent.height
                        columns: 3
                        rowSpacing: 0
                        
                        Button {
                            iconName: 'go-up'
                            Layout.fillHeight: true
                            onClicked: {
                                townStringsModel.move(styleData.row, styleData.row - 1, 1)
                                townStringsModelChanged()
                            }
                            enabled: styleData.row > 0
                        }
                        
                        Button {
                            iconName: 'go-down'
                            Layout.fillHeight: true
                            onClicked: {
                                townStringsModel.move(styleData.row, styleData.row + 1, 1)
                                townStringsModelChanged()
                            }
                            enabled: styleData.row < townStringsModel.count - 1
                        }
                        
                        Button {
                            iconName: 'list-remove'
                            Layout.fillHeight: true
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
            Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        Button {
            iconName: 'list-add'
            Layout.preferredWidth: 100
            Layout.columnSpan: 2
            onClicked: {
                addTownStringDialog.open()
                newTownStringField.text = ''
                newTownStringField.focus = true
            }
        }
        
        Item {
            width: 2
            height: 20
            Layout.columnSpan: 2
        }
        
        Label {
            font.italic: true
            text: 'Find your town string in yr.no (english version)\nand use the URL from your browser to add a new location. E.g. paste this:\nhttp://www.yr.no/place/Germany/North_Rhine-Westphalia/Bonn/'
            //Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Label {
            text: 'NOTE: This will get automated in future versions.'
            //Layout.preferredWidth: parent.width
            Layout.columnSpan: 2
        }
        
        Item {
            width: 2
            height: 2
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Miscellaneous')
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

/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/icons.js" as IconTools
import "../code/temperature-utils.js" as TemperatureUtils

Item {
    id: compactRepresentation
    
    property double partHeight: vertical ? (parent.width / 2) / 1.3 : parent.height
    property double partWidth: partHeight * 1.3
    
    property double fontPointSize: partHeight * 0.5
    
    Layout.preferredWidth: partWidth * 2
    Layout.preferredHeight: partHeight
    
    ListView {
        id: mainView
        
        model: actualWeatherModel
        delegate: Item {
            id: mainViewDelegate
            
            width: Layout.maximumWidth
            height: Layout.maximumHeight
            
            Item {
                id: temperatureNumberItem
                
                width: partWidth
                height: partHeight
                
                Text {
                    id: temperatureText
                    
                    width: parent.width
                    height: parent.height
                    
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    
                    text: TemperatureUtils.getTemperatureNumber(temperature, fahrenheitEnabled) + '°'
                    color: theme.textColor
                    font.pointSize: fontPointSize
                }
            }
            
            Item {
                width: partWidth
                height: partHeight
                
                anchors.top: mainViewDelegate.top
                anchors.left: mainViewDelegate.left
                anchors.leftMargin: temperatureNumberItem.width
                anchors.topMargin: 0
                
                Label {
                    anchors.centerIn: parent
                    
                    font.family: 'weathericons'
                    text: IconTools.getIconCode(iconName, true, getPartOfDayIndex())
                    
                    color: theme.textColor
                    font.pointSize: fontPointSize
                }
            }
        }
    }
    
    PlasmaComponents.BusyIndicator {
        id: busyIndicator
        anchors.fill: parent
        visible: false
        running: false
    }
    
    states: [
        State {
            name: "loading"
            when: loadingData
            
            PropertyChanges {
                target: busyIndicator
                visible: true
                running: true
            }
            
            PropertyChanges {
                target: mainView
                opacity: 0.5
            }
        }
    ]
    
    Text {
        id: lastReloadedNotifier
        
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: - partHeight * 0.05
        
        font.pointSize: partHeight * 0.2
        color: theme.highlightColor
        
        text: lastReloadedText
        
        visible: false
    }
    
    
    
    MouseArea {
        anchors.fill: parent
        
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        
        hoverEnabled: true
        
        onEntered: {
            lastReloadedNotifier.visible = !plasmoid.expanded
        }
        
        onExited: {
            lastReloadedNotifier.visible = false
        }
        
        onClicked: {
            if (mouse.button == Qt.MiddleButton) {
                main.reloadData()
            } else {
                plasmoid.expanded = !plasmoid.expanded
                lastReloadedNotifier.visible = !plasmoid.expanded
            }
        }
        
        
        PlasmaCore.ToolTipArea {
            id: toolTipArea
            anchors.fill: parent
            active: !plasmoid.expanded
            interactive: true
            mainText: placeAlias
            subText: tooltipSubText
            textFormat: Text.RichText
        }
    }
    
}

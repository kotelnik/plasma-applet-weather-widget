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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/icons.js" as IconTools
import "../code/temperature-utils.js" as TemperatureUtils

Item {
    id: compactRepresentationInTray

    property double fontPointSize: height * 0.6

    ListView {
        id: mainView
        
        anchors.fill: parent
        
        model: actualWeatherModel
        delegate: Item {
            id: mainViewDelegate
            
            width: mainView.width
            height: mainView.height

            PlasmaComponents.Label {
                anchors.fill: parent

                opacity: 0.8
                font.family: 'weathericons'
                text: IconTools.getIconCode(iconName, true, getPartOfDayIndex())

                font.pointSize: fontPointSize
                fontSizeMode: Text.Fit
            }

            PlasmaComponents.Label {
                id: temperatureText

                anchors.fill: parent

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignBottom
                    
                text: TemperatureUtils.getTemperatureNumber(temperature, fahrenheitEnabled) + '°'
                    
                font.bold: true
                font.pointSize: fontPointSize * 0.5
            }
            
            DropShadow {
                anchors.fill: temperatureText
                radius: 3
                samples: 16
                spread: 0.9
                fast: true
                color: theme.backgroundColor
                source: temperatureText
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
    
    Plasmoid.toolTipMainText: placeAlias
    Plasmoid.toolTipSubText: tooltipSubText
    //TODO why is this not working?
    //Plasmoid.toolTipTextFormat: Text.RichText
    Plasmoid.icon: Qt.resolvedUrl('../images/weather-widget.svg')
    
}

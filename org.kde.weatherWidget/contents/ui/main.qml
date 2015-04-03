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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.0
import "../code/reloader.js" as Reloader

Item {
    id: main
    
    property double lat: plasmoid.configuration.lat
    property double lon: plasmoid.configuration.lon
    property string town: plasmoid.configuration.town
    
    property string overviewImageSource: 'http://www.yr.no/place/' + town + '/meteogram.png'
    property string overviewLink: 'http://www.yr.no/place/' + town + '/'
    property int reloadIntervalMin: plasmoid.configuration.reloadIntervalMin
    property int reloadIntervalMs: reloadIntervalMin * 60 * 1000
    
    property string lastReloadedText: '⬇ 0m ago'
    
    property bool verticalAlignment: plasmoid.configuration.compactLayout
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    anchors.fill: parent
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation { }
    Plasmoid.fullRepresentation: FullRepresentation { }
    
    FontLoader {
        source: 'plasmapackage:/fonts/weathericons-regular-webfont.ttf'
    }
    
    XmlListModel {
        id: xmlModel
        source: 'http://api.yr.no/weatherapi/locationforecastlts/1.2/?lat=' + lat + ';lon=' + lon
        query: '/weatherdata/product'

        XmlRole {
            name: 'temperature'
            query: '(time[location/temperature])[2]/location/temperature/@value/string()'
        }
        XmlRole {
            name: 'iconName'
            query: '(time[location/temperature])[2]/following-sibling::time[1]/location/symbol/@id/string()'
        }
    }
    
    Timer {
        interval: 1000 * 5
        running: true
        repeat: true
        onTriggered: {
            var ready = Reloader.isReadyToReload(reloadIntervalMs)
            if (ready) {
                Reloader.setReloaded()
                
                xmlModel.reload()
                
                var mem = overviewImageSource
                overviewImageSource = ''
                overviewImageSource = mem
                
                print('reloaded')
            }
            
            lastReloadedText = '⬇ ' + Reloader.getLastReloadedMins() + 'm ago'
        }
    }
    
}

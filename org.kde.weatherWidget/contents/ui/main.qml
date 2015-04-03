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
    
    property string townString: plasmoid.configuration.townString
    
//     property string overviewImageSource: 'http://www.yr.no/place/' + townString + '/meteogram.png'
//     property string overviewLink: 'http://www.yr.no/place/' + townString + '/'
    property string overviewImageSource
    property string overviewLink
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
        source: 'http://www.yr.no/place/' + townString + '/forecast.xml'
        query: '/weatherdata/forecast/tabular/time[1]'

        XmlRole {
            name: 'temperature'
            query: 'temperature/@value/string()'
        }
        XmlRole {
            name: 'iconName'
            query: 'symbol/@number/string()'
        }
    }
    
    function reloadData() {
        if (xmlModel.status == XmlListModel.Loading) {
            print('still loading')
            return
        }
        xmlModel.reload()
        
        print('reload called')
    }
    
    function reloaded() {
        Reloader.setReloaded()
        print('reloaded')
    }
    
    Timer {
        interval: 1000 * 5
        running: true
        repeat: true
        onTriggered: {
            
            if (Reloader.isReadyToReload(reloadIntervalMs)) {
                reloadData()
            }
            
            lastReloadedText = '⬇ ' + Reloader.getLastReloadedMins() + 'm ago'
        }
    }
    
}

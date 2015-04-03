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

Item {
    id: compactRepresentation
    
    property int imageWidth: 828
    property int imageHeight: 272
    
    width: imageWidth
    height: imageHeight + theme.defaultFont.pointSize * 3
    
    Image {
        id: overviewImage
        cache: false
        source: overviewImageSource
    }
    
    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: lastReloadedText
    }
    
    Text {
        id: creditText
        
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: 'Weather forecast from yr.no, delivered by the Norwegian Meteorological Institute and the NRK'
    }
    
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: creditText
        
        hoverEnabled: true
        
        onClicked: {
            print('opening: ', overviewLink)
            Qt.openUrlExternally(overviewLink) //overviewLink
        }
        
        onEntered: {
            creditText.font.underline = true
        }
        
        onExited: {
            creditText.font.underline = false
        }
    }
    
}

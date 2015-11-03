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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: fullRepresentation
    
    property int imageWidth: 828
    property int imageHeight: 302
    
    property double footerHeight: theme.defaultFont.pointSize * 3
    
    property int nextDayItemSpacing: 5
    property int nextDaysHeight: imageHeight * 0.4
    property int nextDaysVerticalMargin: 10
    property int hourLegendMargin: 20
    property double nextDayItemWidth: (imageWidth / nextDaysCount) - nextDayItemSpacing - hourLegendMargin / nextDaysCount
    property int headingHeight: 20
    
    width: imageWidth
    height: headingHeight + imageHeight + footerHeight + nextDaysHeight + nextDaysVerticalMargin * 2
    
    PlasmaComponents.Label {
        id: currentLocationText
        
        anchors.left: parent.left
        anchors.top: parent.top
        verticalAlignment: Text.AlignTop
        
        text: main.placeAlias
    }
    
    PlasmaComponents.Label {
        id: nextLocationText
        
        anchors.right: parent.right
        anchors.top: parent.top
        verticalAlignment: Text.AlignTop
        
        text: 'Next Location'
    }
    
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: nextLocationText
        
        hoverEnabled: true
        
        onClicked: {
            dbgprint('clicked next location')
            main.setNextTownString()
        }
        
        onEntered: {
            nextLocationText.font.underline = true
        }
        
        onExited: {
            nextLocationText.font.underline = false
        }
    }
    
    Meteogram {
        id: meteogram
        anchors.top: parent.top
        anchors.topMargin: headingHeight
        width: imageWidth
        height: imageHeight
    }
    
    /*
     * 
     * NEXT DAYS
     * 
     */
    ListView {
        id: nextDaysView
        anchors.bottom: parent.bottom
        anchors.bottomMargin: footerHeight + nextDaysVerticalMargin
        anchors.left: parent.left
        anchors.leftMargin: hourLegendMargin
        anchors.right: parent.right
        height: nextDaysHeight
        
        model: nextDaysModel
        orientation: Qt.Horizontal
        spacing: nextDayItemSpacing
        interactive: false
        
        delegate: NextDayItem {
            width: nextDayItemWidth
            height: nextDaysHeight
        }
    }
    
    Item {
        id: hourLegend
        anchors.bottom: parent.bottom
        anchors.bottomMargin: footerHeight
        width: theme.defaultFont.pointSize * 2.4
        height: nextDaysHeight - 15
        
        PlasmaComponents.Label {
            text: '0h'
            anchors.top: parent.top
            anchors.right: parent.right
            font.pointSize: theme.defaultFont.pointSize * 0.8
            opacity: 0.6
        }
        PlasmaComponents.Label {
            text: '.\n.\n.\n.'
            anchors.fill: parent
            anchors.topMargin: - theme.defaultFont.pointSize * 0.5
            anchors.leftMargin: hourLegendMargin * 0.4
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: theme.defaultFont.pointSize
            opacity: 0.6
        }
        PlasmaComponents.Label {
            text: '24h'
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            verticalAlignment: Text.AlignBottom
            font.pointSize: theme.defaultFont.pointSize * 0.8
            opacity: 0.6
        }
    }
    
    
    /*
     * 
     * FOOTER
     * 
     */
    MouseArea {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        
        width: lastReloadedTextComponent.contentWidth
        height: lastReloadedTextComponent.contentHeight

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        PlasmaComponents.Label {
            id: lastReloadedTextComponent
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignBottom
            
            text: lastReloadedText
        }
        
        PlasmaComponents.Label {
            id: reloadTextComponent
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignBottom
            
            text: '\u21bb Reload'
            visible: false
        }
        
        onEntered: {
            lastReloadedTextComponent.visible = false
            reloadTextComponent.visible = true
        }
        
        onExited: {
            lastReloadedTextComponent.visible = true
            reloadTextComponent.visible = false
        }
        
        onClicked: {
            main.reloadData()
        }
    }
    
    
    PlasmaComponents.Label {
        id: creditText
        
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        verticalAlignment: Text.AlignBottom
        
        text: 'Weather forecast from yr.no, delivered by the Norwegian Meteorological Institute and the NRK'
    }
    
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: creditText
        
        hoverEnabled: true
        
        onClicked: {
            dbgprint('opening: ', overviewLink)
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

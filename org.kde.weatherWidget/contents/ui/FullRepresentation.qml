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

Item {
    id: fullRepresentation
    
    property int imageWidth: 828
    property int imageHeight: 302
    
    property double footerHeight: theme.defaultFont.pointSize * 3
    
    property int nextDayItemSpacing: 5
    property int nextDaysHeight: imageHeight * 0.4
    property int nextDaysVerticalMargin: 10
    property double nextDayItemWidth: (imageWidth / nextDaysCount) - nextDayItemSpacing
    property int headingHeight: 20
    
    width: imageWidth
    height: headingHeight + imageHeight + footerHeight + nextDaysHeight + nextDaysVerticalMargin * 2
    
    Text {
        id: currentLocationText
        
        anchors.left: parent.left
        anchors.top: parent.top
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: main.townString
    }
    
    Text {
        id: nextLocationText
        
        anchors.right: parent.right
        anchors.top: parent.top
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: 'Next Location'
    }
    
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: nextLocationText
        
        hoverEnabled: true
        
        onClicked: {
            print('clicked next location')
            main.setNextTownString()
        }
        
        onEntered: {
            nextLocationText.font.underline = true
        }
        
        onExited: {
            nextLocationText.font.underline = false
        }
    }
    
    Text {
        id: noImageText
        width: imageWidth
        height: imageHeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.top: parent.top
        anchors.topMargin: headingHeight
        
        text: loadingError ? 'Offline mode' : 'Loading image...'
        font.pointSize: theme.defaultFont.pointSize
        color: theme.textColor
    }
    
    Image {
        id: overviewImage
        cache: false
        source: overviewImageSource
        anchors.top: parent.top
        anchors.topMargin: headingHeight
    }
    
    states: [
        State {
            name: "error"
            when: overviewImage.status == Image.Error || overviewImage.status == Image.Null

            StateChangeScript {
                script: {
                    imageLoadingError = true
                }
            }
        },
        State {
            name: "loading"
            when: overviewImage.status == Image.Loading || overviewImage.status == Image.Ready

            StateChangeScript {
                script: {
                    imageLoadingError = false
                }
            }
        }
    ]
    
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
        
        Text {
            id: lastReloadedTextComponent
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            
            color: theme.textColor
            font.pointSize: theme.defaultFont.pointSize
            
            text: lastReloadedText
        }
        
        Text {
            id: reloadTextComponent
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            
            color: theme.textColor
            font.pointSize: theme.defaultFont.pointSize
            
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

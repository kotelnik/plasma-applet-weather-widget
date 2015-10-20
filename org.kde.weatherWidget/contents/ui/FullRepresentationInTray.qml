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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: fullRepresentation
    
    width: parent.width
    
    property double footerHeight: theme.defaultFont.pointSize * 5
    
    property int nextDaysSpacing: 5
    property int nextDayHeight: 70
    property int hourLegendMargin: 20
    property int headingHeight: 30
    property int nextDayItemSpacing: 10
    
    property double headingTopMargin: 10
    
    property color lineColor: theme.textColor
    
    Text {
        id: currentLocationText
        
        anchors.left: parent.left
        anchors.top: parent.top
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: main.placeAlias
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
    
    
    
    
    /*
     * 
     * NEXT DAYS
     * 
     */
    ScrollView {
        id: nextDays
        
        anchors.top: parent.top
        anchors.topMargin: headingHeight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: footerHeight
        
        width: parent.width
        height: parent.height - footerHeight - headingHeight
        
        ListView {
            id: nextDaysView
            
            anchors.fill: parent
            width: parent.width
            height: parent.height
            
            model: nextDaysModel
            orientation: Qt.Vertical
            spacing: nextDayItemSpacing
            interactive: false
            
            delegate: Item {
                
                width: nextDaysView.width
                height: nextDayHeight
                
                PlasmaCore.SvgItem {
                    id: dayTitleLine
                    width: parent.width
                    height: lineSvg.elementSize("horizontal-line").height
                    elementId: "horizontal-line"
                    svg: PlasmaCore.Svg {
                        id: lineSvg
                        imagePath: "widgets/line"
                    }
                }
                
                Text {
                    id: dayTitleText
                    
                    anchors.top: dayTitleLine.bottom
                    anchors.topMargin: units.smallSpacing
                    
                    text: dayTitle + ' ' + dateString
                    color: theme.textColor
                    font.pointSize: theme.defaultFont.pointSize
                }
                
                
                
                /*
                * 
                * four item data
                * 
                */
                property double periodMargin: 15
                property double periodItemWidth: (width - periodMargin * 4) / 4
                property double periodItemHeight: nextDayHeight - headingTopMargin
                property double periodFontSize: periodItemHeight  * 0.27
                
                Item {
                    
                    anchors.top: parent.top
                    anchors.topMargin: headingTopMargin
                    
                    height: periodItemHeight
                    
                    NextDayPeriodItem {
                        id: period1
                        width: periodItemWidth
                        height: parent.height
                        temperature: temperature0
                        iconName: iconName0
                        partOfDay: 1
                        fontPointSize: periodFontSize
                    }
                    
                    NextDayPeriodItem {
                        id: period2
                        width: periodItemWidth
                        height: parent.height
                        temperature: temperature1
                        iconName: iconName1
                        partOfDay: 0
                        fontPointSize: periodFontSize
                        
                        anchors.left: period1.right
                        anchors.leftMargin: periodMargin
                    }
                    
                    NextDayPeriodItem {
                        id: period3
                        width: periodItemWidth
                        height: parent.height
                        temperature: temperature2
                        iconName: iconName2
                        partOfDay: 0
                        fontPointSize: periodFontSize
                        
                        anchors.left: period2.right
                        anchors.leftMargin: periodMargin
                    }
                    
                    NextDayPeriodItem {
                        id: period4
                        width: periodItemWidth
                        height: parent.height
                        temperature: temperature3
                        iconName: iconName3
                        partOfDay: 1
                        fontPointSize: periodFontSize
                        
                        anchors.left: period3.right
                        anchors.leftMargin: periodMargin
                    }
                }
                
            }
        }
    }
    
    
    
    
    /*
     * 
     * FOOTER
     * 
     */
    MouseArea {
        id: reloadMouseArea

        anchors.top: nextDays.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.topMargin: units.smallSpacing
        
        width: lastReloadedTextComponent.contentWidth
        height: lastReloadedTextComponent.contentHeight

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        Text {
            id: lastReloadedTextComponent
            anchors.fill: parent
            
            color: theme.textColor
            font.pointSize: theme.defaultFont.pointSize
            
            text: lastReloadedText
        }
        
        Text {
            id: reloadTextComponent
            anchors.fill: parent
            
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
        
        anchors.top: nextDays.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: reloadMouseArea.right
        anchors.topMargin: units.smallSpacing
        anchors.leftMargin: units.largeSpacing
        
        color: theme.textColor
        font.pointSize: theme.defaultFont.pointSize
        
        text: 'Weather forecast from yr.no, delivered by the Norwegian Meteorological Institute and the NRK'
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
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

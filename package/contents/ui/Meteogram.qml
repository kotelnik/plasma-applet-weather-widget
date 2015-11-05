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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/temperature-utils.js" as TemperatureUtils

Item {
    id: meteogram
    
    property int temperatureSizeY: 21
    property int pressureSizeY: 101
    property int pressureMultiplier: Math.round((pressureSizeY - 1) / (temperatureSizeY - 1))
    
    property int graphLeftMargin: 28
    property int graphTopMargin: 20
    property double graphWidth: meteogram.width - graphLeftMargin * 2
    property double graphHeight: meteogram.height - graphTopMargin * 2
    
    property var dataArray: []
    
    property int dataArraySize: 2
    property double sampleWidth: graphWidth / (dataArraySize - 1)

    property int endDayHour: 0
    
    property double temperatureAdditiveY: 0
    property double temperatureMultiplierY: graphHeight / (temperatureSizeY - 1)
    
    property int pressureAdditiveY: - 950
    property double pressureMultiplierY: graphHeight / (pressureSizeY - 1)
    
    property bool meteogramModelChanged: main.meteogramModelChanged
    
    property color pressureColor: Qt.rgba(0.3, 1.0, 0.3, 1.0)
    
    onGraphHeightChanged: {
        dbgprint('graphHeight changed to: ' + graphHeight)
        redrawCanvas()
    }
    
    onMeteogramModelChangedChanged: {
        dbgprint('meteogram changed')
        modelUpdated()
    }
    
    function modelUpdated() {
        
        dbgprint('meteogram model updated ' + meteogramModel.count)
        dataArraySize = meteogramModel.count
        
        if (dataArraySize === 0) {
            dbgprint('model is empty')
            return
        }
        
        horizontalGridModel.clear()
        for (var i = 0; i < meteogramModel.count; i++) {
            horizontalGridModel.append({
                num: i,
                hourFrom: meteogramModel.get(i).from.getHours()
            })
        }
        
        var minValue = null
        var maxValue = null
        var maxHour = null
        
        for (var i = 0; i < meteogramModel.count; i++) {
            var value = meteogramModel.get(i).temperature
            var hour = horizontalGridModel.get(i).hourFrom
            if (minValue === null) {
                minValue = value
                maxValue = value
                maxHour = hour
                continue
            }
            if (value < minValue) {
                minValue = value
            }
            if (value > maxValue) {
                maxValue = value
            }
            if (hour > maxHour) {
                maxHour = hour
            }
        }
        
        dbgprint('minValue: ' + minValue)
        dbgprint('maxValue: ' + maxValue)
        dbgprint('temperatureSizeY: ' + temperatureSizeY)
        
        var mid = (maxValue - minValue) / 2 + minValue
        var halfSize = temperatureSizeY / 2
        
        temperatureAdditiveY = Math.round(- (mid - halfSize))
        
        dbgprint('temperatureAdditiveY: ' + temperatureAdditiveY)
        
        endDayHour = maxHour
        
        dbgprint('endDayHour: ' + endDayHour)
        
        redrawCanvas()
    }
    
    function redrawCanvas() {
        
        print('redrawing canvas with temperatureMultiplierY=' + temperatureMultiplierY)
        
        var newPathElements = []
        var newPressureElements = []
        
        if (meteogramModel.count === 0 || temperatureMultiplierY > 1000000 || temperatureMultiplierY === 0) {
            return
        }
        
        for (var i = 0; i < meteogramModel.count; i++) {
            var dataObj = meteogramModel.get(i)
            
            dbgprint('hour: ' + dataObj.from.getHours())
            
            var rawTempY = temperatureSizeY - (dataObj.temperature + temperatureAdditiveY)
            dbgprint('realTemp: ' + dataObj.temperature + ', rawTempY: ' + rawTempY)
            var temperatureY = rawTempY * temperatureMultiplierY
            
            var rawPressY = pressureSizeY - (dataObj.pressureHpa + pressureAdditiveY)
            dbgprint('realPress: ' + dataObj.pressureHpa + ', rawTempY: ' + rawPressY)
            var pressureY = rawPressY * pressureMultiplierY
            
            if (i === 0) {
                temperaturePath.startY = temperatureY
                pressurePath.startY = pressureY
                continue
            }
            
            newPathElements.push(Qt.createQmlObject('import QtQuick 2.0; PathCurve { x: ' + (i * sampleWidth) + '; y: ' + temperatureY + ' }', meteogram, "dynamicTemperature" + i))

            newPressureElements.push(Qt.createQmlObject('import QtQuick 2.0; PathCurve { x: ' + (i * sampleWidth) + '; y: ' + pressureY + ' }', meteogram, "dynamicPressure" + i))
        }
        
        temperaturePath.pathElements = newPathElements
        pressurePath.pathElements = newPressureElements
        
        meteogramCanvas.requestPaint()
        
    }
    
    ListModel {
        id: verticalGridModel
    }
    
    ListModel {
        id: horizontalGridModel
    }
    
    Component.onCompleted: {
        for (var i = 0; i < temperatureSizeY; i++) {
            verticalGridModel.append({
                num: i
            })
        }
    }
    
    Item {
        id: graph
        width: graphWidth
        height: graphHeight
        anchors.centerIn: parent
        anchors.topMargin: -(graphHeight / temperatureSizeY) * 0.5
        
        visible: renderMeteogram
        
        ListView {
            id: horizontalLines
            model: verticalGridModel
            anchors.fill: parent
            
            delegate: Item {
                height: horizontalLines.height / (temperatureSizeY - 1)
                width: horizontalLines.width
                
                visible: num % 2 === 0
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.textColor
                    opacity: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                PlasmaComponents.Label {
                    text: TemperatureUtils.getTemperatureNumber(-temperatureAdditiveY + (temperatureSizeY - num), fahrenheitEnabled) + '°'
                    height: parent.height
                    width: graphLeftMargin - 2
                    horizontalAlignment: Text.AlignRight
                    anchors.left: parent.left
                    anchors.leftMargin: -graphLeftMargin
                    font.pointSize: 8
                }
                
                PlasmaComponents.Label {
                    text: (-pressureAdditiveY + (pressureSizeY - 1 - num * pressureMultiplier))
                    height: parent.height
                    width: graphLeftMargin - 2
                    horizontalAlignment: Text.AlignLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -graphLeftMargin
                    font.pointSize: 8
                    color: pressureColor
                }
            }
        }
        
        ListView {
            id: verticalLines
            model: horizontalGridModel
            anchors.fill: parent
            anchors.topMargin: -graph.anchors.topMargin
            orientation: ListView.Horizontal
            
            delegate: Item {
                height: horizontalLines.height
                width: horizontalLines.width / (dataArraySize - 1)
                
                Rectangle {
                    width: hourFrom === endDayHour ? 2 : 1
                    height: parent.height
                    color: theme.textColor
                    opacity: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    visible: num % 2 === 1
                }
                
                PlasmaComponents.Label {
                    text: hourFrom < 10 ? '0' + hourFrom : hourFrom
                    height: graphTopMargin - 2
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -graphTopMargin
                    font.pointSize: 9
                    
                    visible: num % 2 === 0
                }
            }
        }
        
        Canvas {
            id: meteogramCanvas
            anchors.fill: parent
            anchors.topMargin: (horizontalLines.height / temperatureSizeY) * 0.5
            anchors.bottomMargin: (horizontalLines.height / temperatureSizeY) * 0.5
            contextType: '2d'

            Path {
                id: pressurePath
                startX: 0
            }
            
            Path {
                id: temperaturePath
                startX: 0
            }
            
            onPaint: {
                context.clearRect(0, 0, meteogramCanvas.width, meteogramCanvas.height)
                
                context.strokeStyle = pressureColor
                context.lineWidth = 1;
                context.path = pressurePath
                context.stroke()
                
                context.strokeStyle = Qt.rgba(1.0, 0.1, 0.1, 1.0)
                context.lineWidth = 2;
                context.path = temperaturePath
                context.stroke()
            }
        }
    }
    
    PlasmaComponents.Label {
        id: noImageText
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.top: parent.top
        anchors.topMargin: headingHeight
        text: loadingError ? 'Offline mode' : 'Loading image...'
        visible: !renderMeteogram
    }
    
    Image {
        id: overviewImage
        cache: false
        source: renderMeteogram ? undefined : overviewImageSource
        anchors.fill: parent
        visible: !renderMeteogram
    }
    
    states: [
        State {
            name: 'error'
            when: overviewImage.status == Image.Error || overviewImage.status == Image.Null

            StateChangeScript {
                script: {
                    dbgprint('image loading error')
                    imageLoadingError = true
                }
            }
        },
        State {
            name: 'loading'
            when: overviewImage.status == Image.Loading || overviewImage.status == Image.Ready

            StateChangeScript {
                script: {
                    imageLoadingError = false
                }
            }
        }
    ]
    
}

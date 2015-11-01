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

Item {
    id: meteogram
    
    property var dataArray: []
    
    property int dataArraySize: 2
    property double sampleWidth: meteogram.width / (dataArraySize - 1)

    property int temperatureMaxY: 0
    property int temperatureMinY: 0
    property int temperatureSideGap: 5
    property double temperatureAdditiveY: - temperatureMinY
    property double temperatureMultiplierY: meteogram.height / (temperatureMaxY - temperatureMinY)
    
    property int pressureSideGap: 20
    property int pressureMaxY: 100 + pressureSideGap
    property int pressureAdditiveY: - 950 + pressureSideGap
    property double pressureMultiplierY: meteogram.height / (100 + pressureSideGap * 2)
    
    property bool meteogramModelChanged: main.meteogramModelChanged
    
    onSampleWidthChanged: {
        redrawCanvas()
    }
    
    onMeteogramModelChangedChanged: {
        dbgprint('meteogram changed')
        modelUpdated()
    }
    
    function modelUpdated() {
        
        dbgprint('meteogram model updated ' + meteogramModel.count)
        dataArraySize = meteogramModel.count
        
        var minValue = null
        var maxValue = null
        
        for (var i = 0; i < meteogramModel.count; i++) {
            var value = meteogramModel.get(i).temperature
            if (minValue === null || maxValue === null) {
                minValue = value
                maxValue = value
            }
            if (value < minValue) {
                minValue = value
            }
            if (value > maxValue) {
                maxValue = value
            }
        }
        
        temperatureMaxY = maxValue + temperatureSideGap
        temperatureMinY = minValue - temperatureSideGap
        
        dbgprint('maxValue: ' + maxValue + ', minValue: ' + minValue)
        dbgprint('temperatureMaxY: ' + temperatureMaxY + ', temperatureMinY: ' + temperatureMinY)
        
        redrawCanvas()
    }
    
    function redrawCanvas() {
        
        print('redrawing canvas with temperatureMultiplierY=' + temperatureMultiplierY)
        
        var newPathElements = []
        var newPressureElements = []
        
        if (meteogramModel.count === 0 || temperatureMultiplierY > 1000000) {
            return
        }
        
        for (var i = 0; i < meteogramModel.count; i++) {
            var dataObj = meteogramModel.get(i)
            
            var temperatureY = (temperatureMaxY + temperatureSideGap - dataObj.temperature - temperatureAdditiveY) * temperatureMultiplierY
            var pressureY = (pressureMaxY + pressureSideGap - dataObj.pressureHpa - pressureAdditiveY) * pressureMultiplierY
            
//             dbgprint('temperature: ' + dataObj.temperature + ', pressure: ' + dataObj.pressureHpa)
            
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
    
    Canvas {
        id: meteogramCanvas
        anchors.fill: parent
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
            
            context.strokeStyle = Qt.rgba(0.3, 1.0, 0.3, 1.0)
            context.path = pressurePath
            context.stroke()
            
            context.strokeStyle = Qt.rgba(1.0, 0.1, 0.1, 1.0)
            context.path = temperaturePath
            context.stroke()
        }
        
        visible: false
    }
    
    Image {
        id: overviewImage
        cache: false
        source: overviewImageSource
        anchors.fill: parent
        
        visible: true
    }
    
}

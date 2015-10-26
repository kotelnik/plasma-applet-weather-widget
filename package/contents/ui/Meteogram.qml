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
    
    property int sideGap: 10
    property int dataArraySize: 1
    property double sampleWidth: meteogram.width / (dataArraySize - 1)
    property double yMultiplier: meteogram.height / (maxY - minY)
    
    property int maxY: 0
    property int minY: 0
    
    onSampleWidthChanged: {
        redrawCanvas()
    }
    
    onYMultiplierChanged: {
        redrawCanvas()
    }
    
    ListModel {
        id: meteogramModel
    }
    
    function modelUpdated() {
        
        print('meteogram model updated')
        
        var minValue = null
        var maxValue = null
        
        dataArray.forEach(function (dataObj) {
            var value = dataObj.temperature
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
        })
        
        maxY = maxValue + sideGap
        minY = minValue - sideGap
        
        redrawCanvas()
    }
    
    function redrawCanvas() {
        
        print('redrawing canvas with yMultiplier=' + yMultiplier)
        
        var newPathElements = []
        var newPressureElements = []
        
        if (dataArray === undefined || yMultiplier > 1000000) {
            return
        }
        
        dataArray.forEach(function (dataObj, i) {
            if (i === 0) {
                temperaturePath.startY = dataObj.temperature * yMultiplier
                pressurePath.startY = dataObj.pressure * 0.2
                return
            }
            
            newPathElements.push(Qt.createQmlObject('import QtQuick 2.0; PathCurve { x: ' + (i * sampleWidth) + '; y: ' + ((dataObj.temperature + sideGap) * yMultiplier) + ' }', meteogram, "dynamicTemperature" + i))
            
            newPressureElements.push(Qt.createQmlObject('import QtQuick 2.0; PathCurve { x: ' + (i * sampleWidth) + '; y: ' + ((dataObj.pressure + sideGap) * 0.2) + ' }', meteogram, "dynamicPressure" + i))
        })
        
        temperaturePath.pathElements = newPathElements
        pressurePath.pathElements = newPressureElements
        
        meteogramCanvas.requestPaint()
        
    }
    
    function setNewTemperatureArray(newDataArray) {
        dataArray = newDataArray
        dataArraySize = dataArray.length
        modelUpdated()
    }
    
    
    Component.onCompleted: {
        
        //20
        
        var temperatureArray = [4,2,6,10,12,17,12,11,8,7,4,2,6,10,12,17,12,11,8,7, 4, 2, 20]
        
        var newDataArray = []
        
        temperatureArray.forEach(function (temp) {
            newDataArray.push({
                temperature: temp,
                precipitation: 0.3,
                windDirection: 'ENE',
                windSpeed: 7.6,
                pressure: 1002.4,
                iconNumber: 13
            })
        })
        
        setNewTemperatureArray(newDataArray)
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
    }
    
}

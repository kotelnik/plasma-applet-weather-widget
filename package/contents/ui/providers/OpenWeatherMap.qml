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
import QtQuick.XmlListModel 2.0
import "../../code/model-utils.js" as ModelUtils
import "../../code/data-loader.js" as DataLoader
import "../../code/unit-utils.js" as UnitUtils

Item {
    id: owm
    
    property string providerId: 'owm'
    
    property string urlPrefix: 'http://api.openweathermap.org/data/2.5'
    property string appIdAndModeSuffix: '&units=metric&mode=xml&appid=5819a34c58f8f07bc282820ca08948f1'
    
    XmlListModel {
        id: xmlModelLongTerm
        query: '/weatherdata/forecast/time'

        XmlRole {
            name: 'date'
            query: '@day/string()'
        }
        XmlRole {
            name: 'temperatureMorning'
            query: 'temperature/@morn/string()'
        }
        XmlRole {
            name: 'temperatureDay'
            query: 'temperature/@day/string()'
        }
        XmlRole {
            name: 'temperatureEvening'
            query: 'temperature/@eve/string()'
        }
        XmlRole {
            name: 'temperatureNight'
            query: 'temperature/@night/string()'
        }
        XmlRole {
            name: 'iconName'
            query: 'symbol/@number/string()'
        }
        XmlRole {
            name: 'windDirection'
            query: 'windDirection/@code/string()'
        }
        XmlRole {
            name: 'windSpeedMps'
            query: 'windSpeed/@mps/string()'
        }
        XmlRole {
            name: 'pressureHpa'
            query: 'pressure/@value/string()'
        }
    }
    
    XmlListModel {
        id: xmlModelHourByHour
        query: '/weatherdata/forecast/time'

        XmlRole {
            name: 'from'
            query: '@from/string()'
        }
        XmlRole {
            name: 'to'
            query: '@to/string()'
        }
        XmlRole {
            name: 'temperature'
            query: 'temperature/@value/string()'
        }
        XmlRole {
            name: 'iconName'
            query: 'symbol/@number/string()'
        }
        XmlRole {
            name: 'windDirection'
            query: 'windDirection/@code/string()'
        }
        XmlRole {
            name: 'windSpeedMps'
            query: 'windSpeed/@mps/string()'
        }
        XmlRole {
            name: 'pressureHpa'
            query: 'pressure/@value/string()'
        }
        XmlRole {
            name: 'precipitationAvg'
            query: 'precipitation/@value/string()'
        }
    }
    
    XmlListModel {
        id: xmlModelCurrent
        query: '/current'

        XmlRole {
            name: 'temperature'
            query: 'temperature/@value/string()'
        }
        XmlRole {
            name: 'iconName'
            query: 'weather/@number/string()'
        }
        XmlRole {
            name: 'humidity'
            query: 'humidity/@value/string()'
        }
        XmlRole {
            name: 'pressureHpa'
            query: 'pressure/@value/string()'
        }
        XmlRole {
            name: 'windSpeedMps'
            query: 'wind/speed/@value/string()'
        }
        XmlRole {
            name: 'windDirection'
            query: 'wind/direction/@code/string()'
        }
        XmlRole {
            name: 'cloudiness'
            query: 'clouds/@value/string()'
        }
        XmlRole {
            name: 'updated'
            query: 'lastupdate/@value/string()'
        }
        XmlRole {
            name: 'rise'
            query: 'city/sun/@rise/string()'
        }
        XmlRole {
            name: 'set'
            query: 'city/sun/@set/string()'
        }
    }
    
    property var xmlModelLongTermStatus: xmlModelLongTerm.status
    property var xmlModelCurrentStatus: xmlModelCurrent.status
    property var xmlModelHourByHourStatus: xmlModelHourByHour.status
    
    function parseDate(dateString) {
        return new Date(dateString + '.000Z')
    }
    
    onXmlModelCurrentStatusChanged: {
        if (xmlModelCurrent.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelCurrent ready')
        additionalWeatherInfo.sunRise = parseDate(xmlModelCurrent.get(0).rise)
        additionalWeatherInfo.sunSet = parseDate(xmlModelCurrent.get(0).set)
        updateTodayModel()
        updateAdditionalWeatherInfoText()
    }
    
    onXmlModelHourByHourStatusChanged: {
        if (xmlModelHourByHour.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelHourByHour ready')
        updateTodayModels(xmlModelHourByHour)
        updateMeteogramModel(xmlModelHourByHour)
    }

    onXmlModelLongTermStatusChanged: {
        if (xmlModelLongTerm.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelLongTerm ready')
        updateNextDaysModel(xmlModelLongTerm)
        refreshTooltipSubText()
    }
    
    function updateTodayModel() {
        var currentTimeObj = xmlModelCurrent.get(0)
        additionalWeatherInfo.sunRise = parseDate(currentTimeObj.rise)
        additionalWeatherInfo.sunSet = parseDate(currentTimeObj.set)
        dbgprint('setting actual weather from current xml model')
        actualWeatherModel.clear()
        actualWeatherModel.append(currentTimeObj)
    }
    
    function updateTodayModels(xmlModelHourByHour) {
        
        dbgprint('updating today models')
        
        var now = new Date()
        var tooOldCurrentDataLimit = new Date(now.getTime() - (2 * 60 * 60 * 1000))
        var nearFutureWeather = additionalWeatherInfo.nearFutureWeather
        
        // check if actual weather is not too old or empty
        if (actualWeatherModel.count > 0 && parseDate(actualWeatherModel.get(0).updated) < tooOldCurrentDataLimit) {
            actualWeatherModel.clear()
        }
        
        // set current models
        nearFutureWeather.iconName = null
        nearFutureWeather.temperature = null
        var foundNow = false
        for (var i = 0; i < xmlModelHourByHour.count; i++) {
            var timeObj = xmlModelHourByHour.get(i)
            var dateFrom = parseDate(timeObj.from)
            var dateTo = parseDate(timeObj.to)
            dbgprint('HOUR BY HOUR: dateFrom=' + dateFrom + ', dateTo=' + dateTo + ', now=' + now + ', i=' + i)
            
            if (!foundNow && dateFrom <= now && now <= dateTo) {
                dbgprint('foundNow setting to true')
                foundNow = true
                if (actualWeatherModel.count === 0) {
                    dbgprint('adding to actualWeatherModel - temperature: ' + timeObj.temperature + ', iconName: ' + timeObj.iconName)
                    actualWeatherModel.append(timeObj)
                }
                continue
            }
            
            if (foundNow) {
                nearFutureWeather.iconName = timeObj.iconName
                nearFutureWeather.temperature = timeObj.temperature
                dbgprint('setting near future - ' + nearFutureWeather.iconName)
                break
            }
        }
        
        dbgprint('result actualWeatherModel count: ' + actualWeatherModel.count)
        dbgprint('result nearFutureWeather.iconName: ' + nearFutureWeather.iconName)
        
    }
    
    function updateNextDaysModel(xmlModelLongTerm) {
        
        var nextDaysFixedCount = nextDaysCount
        
        var now = new Date()
        var nextDayStart = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.wholeDayDurationMs)
        dbgprint('next day start: ' + nextDayStart)
        
        dbgprint('orig: ' + xmlModelLongTerm.count)

        var newObjectArray = []
        var addingStarted = false
        
        var interestingTimeObj = null
        var nextInterestingTimeObj = null
        var currentWeatherModelsSet = false
        
        var time0600 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 6)
        var time1200 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 12)
        var time1800 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 18)
        
        for (var i = 0; i < xmlModelLongTerm.count; i++) {
            var timeObj = xmlModelLongTerm.get(i)
            var dateFrom = Date.fromLocaleString(xmlLocale, timeObj.date, 'yyyy-MM-dd')
            var dateTo = new Date(dateFrom.getTime())
            dateTo.setDate(dateTo.getDate() + 1);
            dateTo = new Date(dateTo.getTime() - 1)
            dbgprint('dateFrom=' + dateFrom + ', dateTo=' + dateTo + ', now=' + now + ', i=' + i)
            
            // encountered old data -> continue to next
            if (now > dateTo) {
                dbgprint('skipping this day')
                continue
            }
            
            var lastObject = ModelUtils.createEmptyNextDaysObject()
            
            var isToday = false
            if (dateFrom <= now && now <= dateTo) {
                dbgprint('setting today')
                lastObject.dayTitle = i18n('today')
                isToday = true
            } else {
                lastObject.dayTitle = Qt.locale().dayName(dateTo.getDay(), Locale.ShortFormat) + ' ' + dateTo.getDate() + '.' + (dateTo.getMonth() + 1) + '.'
            }
            
            newObjectArray.push(lastObject)
            lastObject.tempInfoArray.push({
                temperature: toCelsiaStr(timeObj.temperatureMorning),
                iconName: timeObj.iconName,
                isPast: isToday && now > time0600
            })
            lastObject.tempInfoArray.push({
                temperature: toCelsiaStr(timeObj.temperatureDay),
                iconName: timeObj.iconName,
                isPast: isToday && now > time1200
            })
            lastObject.tempInfoArray.push({
                temperature: toCelsiaStr(timeObj.temperatureEvening),
                iconName: timeObj.iconName,
                isPast: isToday && now > time1800
            })
            lastObject.tempInfoArray.push({
                temperature: toCelsiaStr(timeObj.temperatureNight),
                iconName: timeObj.iconName,
                isPast: false
            })
        }

        //
        // set next days model
        //
        nextDaysModel.clear()
        newObjectArray.forEach(function (objToAdd) {
            if (nextDaysModel.count >= nextDaysFixedCount) {
                return
            }
            ModelUtils.populateNextDaysObject(objToAdd)
            nextDaysModel.append(objToAdd)
        })
        for (var i = 0; i < (nextDaysFixedCount - nextDaysModel.count); i++) {
            nextDaysModel.append(ModelUtils.createEmptyNextDaysObject())
        }
        
        dbgprint('result nextDaysModel count: ' + nextDaysModel.count)
    }
    
    function updateMeteogramModel(xmlModelHourByHour) {
        
        meteogramModel.clear()
        
        var firstFromMs = null
        var limitMsDifference = 1000 * 60 * 60 * 54 // 2.25 days
        var now = new Date()
        
        for (var i = 0; i < xmlModelHourByHour.count; i++) {
            var obj = xmlModelHourByHour.get(i)
            var dateFrom = parseDate(obj.from)
            var dateTo = parseDate(obj.to)
            dbgprint('meteo fill: i=' + i + ', from=' + obj.from + ', to=' + obj.to)
            dbgprint('parsed: from=' + dateFrom + ', to=' + dateTo)
            
            if (now > dateTo) {
                continue;
            }
            
            if (dateFrom <= now && now <= dateTo) {
                dbgprint('foundNow')
                dateFrom = now
            }
            
            var prec = obj.precipitationAvg
            meteogramModel.append({
                from: dateFrom,
                to: dateTo,
                temperature: parseInt(obj.temperature),
                precipitationAvg: obj.precipitationAvg,
                precipitationMin: '',
                precipitationMax: obj.precipitationAvg,
                windDirection: obj.windDirection,
                windSpeedMps: parseFloat(obj.windSpeedMps),
                pressureHpa: parseFloat(obj.pressureHpa),
                iconName: obj.iconName
            })
            
            if (firstFromMs === null) {
                firstFromMs = dateFrom.getTime()
            }
            
            if (dateTo.getTime() - firstFromMs > limitMsDifference) {
                dbgprint('breaking')
                break
            }
        }
        
        dbgprint('meteogramModel.count = ' + meteogramModel.count)
        
        main.meteogramModelChanged = !main.meteogramModelChanged
    }
    
    function toCelsiaStr(kelvinStr) {
        //return String(UnitUtils.kelvinToCelsia(parseFloat(kelvinStr)))
        return kelvinStr
    }
    
    /**
     * successCallback(contentToCache)
     * failureCallback()
     */
    function loadDataFromInternet(successCallback, failureCallback, locationObject) {

        var placeIdentifier = locationObject.placeIdentifier
        
        var loadedCounter = 0
        
        var loadedData = {
            current: null,
            hourByHour: null,
            longTerm: null
        }
        
        function checkIfDone() {
            loadedCounter++
            if (loadedCounter === 3) {
                successCallback(loadedData)
            }
        }
        
        function successCurrent(xmlString) {
            loadedData.current = xmlString
            checkIfDone()
        }
        
        function successHourByHour(xmlString) {
            loadedData.hourByHour = xmlString
            checkIfDone()
        }
        
        function successLongTerm(xmlString) {
            loadedData.longTerm = xmlString
            checkIfDone()
        }
        
        DataLoader.fetchXmlFromInternet(urlPrefix + '/weather?id=' + placeIdentifier + appIdAndModeSuffix, successCurrent, failureCallback)
        DataLoader.fetchXmlFromInternet(urlPrefix + '/forecast?id=' + placeIdentifier + appIdAndModeSuffix, successHourByHour, failureCallback)
        DataLoader.fetchXmlFromInternet(urlPrefix + '/forecast/daily?id=' + placeIdentifier + '&cnt=14' + appIdAndModeSuffix, successLongTerm, failureCallback)
    }
    
    function setWeatherContents(cacheContent) {
        if (!cacheContent.longTerm || !cacheContent.hourByHour || !cacheContent.current) {
            return false
        }
        xmlModelCurrent.xml = ''
        xmlModelCurrent.xml = cacheContent.current
        xmlModelLongTerm.xml = ''
        xmlModelLongTerm.xml = cacheContent.longTerm
        xmlModelHourByHour.xml = ''
        xmlModelHourByHour.xml = cacheContent.hourByHour
        return true
    }
    
    function getCreditLabel(placeIdentifier) {
        return 'Open Weather Map'
    }
    
    function getCreditLink(placeIdentifier) {
        return 'http://openweathermap.org/city/' + placeIdentifier
    }
    
    function reloadMeteogramImage(placeIdentifier) {
        main.overviewImageSource = ''
    }
    
}

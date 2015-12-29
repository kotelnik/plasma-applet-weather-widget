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
    
    property string urlPrefix: 'http://api.openweathermap.org/data/2.5/forecast'
    property string appIdAndModeSuffix: '&mode=xml&appid=5819a34c58f8f07bc282820ca08948f1'
    
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
        id: xmlModelSunRiseSet
        query: '/weatherdata/sun'

        XmlRole {
            name: 'rise'
            query: '@rise/string()'
        }
        XmlRole {
            name: 'set'
            query: '@set/string()'
        }
    }
    
    property var xmlModelLongTermStatus: xmlModelLongTerm.status
    property var xmlModelSunRiseSetStatus: xmlModelSunRiseSet.status
    property var xmlModelHourByHourStatus: xmlModelHourByHour.status

    onXmlModelLongTermStatusChanged: {
        if (xmlModelLongTerm.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelLongTerm ready')
        updateNextDaysModel(nextDaysModel, xmlModelLongTerm)
        refreshTooltipSubText(actualWeatherModel, additionalWeatherInfo)
    }
    
    onXmlModelSunRiseSetStatusChanged: {
        if (xmlModelSunRiseSet.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelSunRiseSet ready')
        additionalWeatherInfo.sunRise = Date.fromLocaleString(xmlLocale, xmlModelSunRiseSet.get(0).rise, datetimeFormat)
        additionalWeatherInfo.sunSet = Date.fromLocaleString(xmlLocale, xmlModelSunRiseSet.get(0).set, datetimeFormat)
        updateAdditionalWeatherInfoText()
    }
    
    onXmlModelHourByHourStatusChanged: {
        if (xmlModelHourByHour.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelHourByHour ready')
        updateTodayModels(actualWeatherModel, additionalWeatherInfo.nearFutureWeather, xmlModelHourByHour)
        updateMeteogramModel(meteogramModel, xmlModelHourByHour)
    }
    
    function updateMeteogramModel(meteogramModel, originalXmlModel) {
        
        meteogramModel.clear()
        
        var firstFromMs = null
        var limitMsDifference = 1000 * 60 * 60 * 54 // 2.25 days
        
        for (var i = 0; i < originalXmlModel.count; i++) {
            var obj = originalXmlModel.get(i)
            var dateFrom = Date.fromLocaleString(xmlLocale, obj.from, datetimeFormat)
            var dateTo = Date.fromLocaleString(xmlLocale, obj.to, datetimeFormat)
            dbgprint('meteo fill: i=' + i + ', from=' + obj.from + ', to=' + obj.to)
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
    
    function updateTodayModels(currentWeatherModel, nearFutureWeather, originalXmlModelHourByHour) {
        
        var now = new Date()
        
        // set current models
        currentWeatherModel.clear()
        nearFutureWeather.iconName = null
        nearFutureWeather.temperature = null
        var foundNow = false
        for (var i = 0; i < originalXmlModelHourByHour.count; i++) {
            var timeObj = originalXmlModelHourByHour.get(i)
            var dateFrom = new Date(timeObj.from)
            var dateTo = new Date(timeObj.to)
            dbgprint('HOUR BY HOUR: dateFrom=' + dateFrom + ', dateTo=' + dateTo + ', now=' + now + ', i=' + i)
            
            if (dateFrom <= now && now <= dateTo) {
                dbgprint('foundNow setting to true and adding to currentWeatherModel - temperature: ' + timeObj.temperature + ', iconName: ' + timeObj.iconName)
                foundNow = true
                currentWeatherModel.append(timeObj)
                continue
            }
            
            if (foundNow) {
                nearFutureWeather.iconName = timeObj.iconName
                nearFutureWeather.temperature = timeObj.temperature
                dbgprint('setting near future - ' + nearFutureWeather.iconName)
                break
            }
        }
        
        dbgprint('result currentWeatherModel count: ' + currentWeatherModel.count)
        dbgprint('result nearFutureWeather.iconName: ' + nearFutureWeather.iconName)
        
    }
    
    function updateNextDaysModel(nextDaysWeatherModel, originalXmlModel) {
        
        var nextDaysFixedCount = nextDaysCount
        
        var now = new Date()
        var nextDayStart = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.wholeDayDurationMs)
        dbgprint('next day start: ' + nextDayStart)
        
        dbgprint('orig: ' + originalXmlModel.count)

        var newObjectArray = []
        var addingStarted = false
        
        var interestingTimeObj = null
        var nextInterestingTimeObj = null
        var currentWeatherModelsSet = false
        
        var time0600 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 6)
        var time1200 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 12)
        var time1800 = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.hourDurationMs * 18)
        
        for (var i = 0; i < originalXmlModel.count; i++) {
            var timeObj = originalXmlModel.get(i)
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
        nextDaysWeatherModel.clear()
        newObjectArray.forEach(function (objToAdd) {
            if (nextDaysWeatherModel.count >= nextDaysFixedCount) {
                return
            }
            ModelUtils.populateNextDaysObject(objToAdd)
            nextDaysWeatherModel.append(objToAdd)
        })
        for (var i = 0; i < (nextDaysFixedCount - nextDaysWeatherModel.count); i++) {
            nextDaysWeatherModel.append(ModelUtils.createEmptyNextDaysObject())
        }
        
        dbgprint('result nextDaysWeatherModel count: ' + nextDaysWeatherModel.count)
    }
    
    function toCelsiaStr(kelvinStr) {
        return String(UnitUtils.kelvinToCelsia(parseFloat(kelvinStr)))
    }
    
    /**
     * successCallback(contentToCache)
     * failureCallback()
     */
    function loadDataFromInternet(successCallback, failureCallback, locationObject) {

        var placeIdentifier = locationObject.placeIdentifier
        
        var loadedCounter = 0
        
        var loadedData = {
            longTerm: null,
            hourByHour: null
        }
        
        function successLongTerm(xmlString) {
            loadedData.longTerm = xmlString
            loadedCounter++
            if (loadedCounter === 2) {
                successCallback(loadedData)
            }
        }
        
        function successHourByHour(xmlString) {
            loadedData.hourByHour = xmlString
            loadedCounter++
            if (loadedCounter === 2) {
                successCallback(loadedData)
            }
        }
        
        DataLoader.fetchXmlFromInternet(urlPrefix + '/daily?id=' + placeIdentifier + '&cnt=14' + appIdAndModeSuffix, successLongTerm, failureCallback)
        DataLoader.fetchXmlFromInternet(urlPrefix + '?id=' + placeIdentifier + appIdAndModeSuffix, successHourByHour, failureCallback)
        
    }
    
    function setWeatherContents(cacheContent) {
        if (!cacheContent.longTerm || !cacheContent.hourByHour) {
            return false
        }
        xmlModelLongTerm.xml = ''
        xmlModelSunRiseSet.xml = ''
        xmlModelHourByHour.xml = ''
        xmlModelLongTerm.xml = cacheContent.longTerm
        xmlModelSunRiseSet.xml = cacheContent.longTerm
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

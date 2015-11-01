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

Item {
    id: yrno
    
    property string urlPreifx: 'http://www.yr.no/place/'
    
    property var providerSources: {}
    
    Component.onCompleted: {
        providerSources = {
            longTermUrl: yrnoUrlPreifx + townString + '/forecast.xml'
        }
    }
    
    XmlListModel {
        id: xmlModelLongTerm
        query: '/weatherdata/forecast/tabular/time'

        XmlRole {
            name: 'from'
            query: '@from/string()'
        }
        XmlRole {
            name: 'to'
            query: '@to/string()'
        }
        XmlRole {
            name: 'period'
            query: '@period/string()'
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
    }
    
    XmlListModel {
        id: xmlModelHourByHour
        query: '/weatherdata/forecast/tabular/time'

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
            name: 'iconNumber'
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
        XmlRole {
            name: 'precipitationMin'
            query: 'precipitation/@minvalue/string()'
        }
        XmlRole {
            name: 'precipitationMax'
            query: 'precipitation/@maxvalue/string()'
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
        updateWeatherModels(actualWeatherModel, additionalWeatherInfo.nearFutureWeather, nextDaysModel, xmlModelLongTerm)
        refreshTooltipSubText(actualWeatherModel, additionalWeatherInfo, fahrenheitEnabled)
    }
    
    onXmlModelSunRiseSetStatusChanged: {
        if (xmlModelSunRiseSet.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelSunRiseSet ready')
        additionalWeatherInfo.sunRise = Date.fromLocaleString(locale, xmlModelSunRiseSet.get(0).rise, datetimeFormat)
        additionalWeatherInfo.sunSet = Date.fromLocaleString(locale, xmlModelSunRiseSet.get(0).set, datetimeFormat)
        var sunRise = additionalWeatherInfo.sunRise
        var sunSet = additionalWeatherInfo.sunSet
        var now = new Date()
        sunRise.setFullYear(now.getFullYear())
        sunRise.setMonth(now.getMonth())
        sunRise.setDate(now.getDate())
        sunSet.setFullYear(now.getFullYear())
        sunSet.setMonth(now.getMonth())
        sunSet.setDate(now.getDate())
        additionalWeatherInfo.sunRiseTime = Qt.formatTime(sunRise, Qt.locale().timeFormat(Locale.ShortFormat))
        additionalWeatherInfo.sunSetTime = Qt.formatTime(sunSet, Qt.locale().timeFormat(Locale.ShortFormat))
        refreshTooltipSubText(actualWeatherModel, additionalWeatherInfo, fahrenheitEnabled)
    }
    
    onXmlModelHourByHourStatusChanged: {
        if (xmlModelHourByHour.status != XmlListModel.Ready) {
            return
        }
        dbgprint('xmlModelHourByHour ready')
        updateMeteogramModel(meteogramModel, xmlModelHourByHour)
    }
    
    function updateMeteogramModel(meteogramModel, originalXmlModel) {
        
        meteogramModel.clear()
        
        for (var i = 0; i < originalXmlModel.count; i++) {
            var obj = originalXmlModel.get(i)
            meteogramModel.append({
                temperature: parseInt(obj.temperature),
                precipitationAvg: parseFloat(obj.precipitationAvg),
                precipitationMin: parseFloat(obj.precipitationMin),
                precipitationMax: parseFloat(obj.precipitationMax),
                windDirection: obj.windDirection,
                windSpeedMps: parseFloat(obj.windSpeedMps),
                pressureHpa: parseFloat(obj.pressureHpa),
                iconNumber: obj.iconNumber
            })
        }
        
        dbgprint('meteogramModel.count = ' + meteogramModel.count)
        
        main.meteogramModelChanged = !main.meteogramModelChanged
    }
    
    function updateWeatherModels(currentWeatherModel, nearFutureWeather, nextDaysWeatherModel, originalXmlModel) {
        
        var nextDaysFixedCount = nextDaysCount
        
        var now = new Date()
        var nextDayStart = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + ModelUtils.wholeDayDurationMs)
        dbgprint('next day start: ' + nextDayStart)
        
        dbgprint('orig: ' + originalXmlModel.count)

        var todayObject = null
        var newObjectArray = []
        var lastObject = null
        var addingStarted = false
        
        var interestingTimeObj = null
        var nextInterestingTimeObj = null
        var currentWeatherModelsSet = false
        
        for (var i = 0; i < originalXmlModel.count; i++) {
            var timeObj = originalXmlModel.get(i)
            var dateFrom = new Date(timeObj.from)
            var dateTo = new Date(timeObj.to)
//             dbgprint('from=' + dateFrom + ', to=' + dateTo + ', now=' + now + ', i=' + i)
            
            // prepare current models
            if (!currentWeatherModelsSet
                && ((i === 0 && now < dateFrom) || (dateFrom < now && now < dateTo))) {
                
                interestingTimeObj = timeObj
                if (i + 1 < originalXmlModel.count) {
                    nextInterestingTimeObj = originalXmlModel.get(i + 1)
                }
                currentWeatherModelsSet = true
            }
            
            if (!addingStarted) {
                addingStarted = dateTo >= nextDayStart && timeObj.period === '0'
                
                if (!addingStarted) {
                    
                    // add today object
                    if (todayObject === null) {
                        todayObject = ModelUtils.createEmptyNextDaysObject()
                        todayObject.dayTitle = i18n('today')
                    }
                    todayObject.temperatureArray.push(timeObj.temperature)
                    todayObject.iconNameArray.push(timeObj.iconName)
                    
                    continue
                }
                dbgprint('found start!')
            }
            
            var periodNo = parseInt(timeObj.period)
            if (periodNo === 0) {
                dbgprint('period 0, array: ' + newObjectArray.length + ', nextDaysCount: ' + nextDaysFixedCount)
                if (newObjectArray.length === nextDaysFixedCount) {
                    dbgprint('breaking')
                    break
                }
                lastObject = ModelUtils.createEmptyNextDaysObject()
                lastObject.dayTitle = Qt.locale().dayName(dateTo.getDay(), Locale.ShortFormat) + ' ' + dateTo.getDate() + '.' + (dateTo.getMonth() + 1) + '.'
                newObjectArray.push(lastObject)
            }
            
            lastObject.temperatureArray.push(timeObj.temperature)
            lastObject.iconNameArray.push(timeObj.iconName)
            
//             dbgprint('lastObject.temperatureArray: ', lastObject.temperatureArray)
        }

        // set current models
        currentWeatherModel.clear()
        if (interestingTimeObj !== null) {
            currentWeatherModel.append(interestingTimeObj)
        }
        nearFutureWeather.iconName = null
        nearFutureWeather.temperature = null
        if (nextInterestingTimeObj !== null) {
            nearFutureWeather.iconName = nextInterestingTimeObj.iconName
            nearFutureWeather.temperature = nextInterestingTimeObj.temperature
        }

        //
        // set next days model
        //
        nextDaysWeatherModel.clear()
        
        // prepend today object
        if (todayObject !== null) {
            while (todayObject.temperatureArray.length < 4) {
                todayObject.temperatureArray.unshift(null)
                todayObject.iconNameArray.unshift(null)
            }
            ModelUtils.populateNextDaysObject(todayObject)
            nextDaysWeatherModel.append(todayObject)
        }
        
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
        
        dbgprint('result currentWeatherModel count: ', currentWeatherModel.count)
        dbgprint('result nearFutureWeather.iconName: ', nearFutureWeather.iconName)
        dbgprint('result nextDaysWeatherModel count: ', nextDaysWeatherModel.count)
    }
    
    /**
     * successCallback(contentToCache, overviewLinkUrl)
     * failureCallback()
     */
    function loadDataFromInternet(successCallback, failureCallback, locationObject) {

        var townString = locationObject.townString
        var overviewLinkUrl = urlPreifx + townString + '/'
        
        var loadedCounter = 0
        
        var loadedData = {
            longTerm: null,
            hourByHour: null
        }
        
        function successLongTerm(xmlString) {
            loadedData.longTerm = xmlString
            loadedCounter++
            if (loadedCounter === 2) {
                successCallback(loadedData, overviewLinkUrl)
            }
        }
        
        function successHourByHour(xmlString) {
            loadedData.hourByHour = xmlString
            loadedCounter++
            if (loadedCounter === 2) {
                successCallback(loadedData, overviewLinkUrl)
            }
        }
        
        DataLoader.fetchXmlFromInternet(urlPreifx + townString + '/forecast.xml', successLongTerm, failureCallback)
        DataLoader.fetchXmlFromInternet(urlPreifx + townString + '/forecast_hour_by_hour.xml', successHourByHour, failureCallback)
        
    }
    
    function setWeatherContents(cacheContent) {
        if (!cacheContent.longTerm || !cacheContent.hourByHour) {
            return false
        }
        xmlModelLongTerm.xml = cacheContent.longTerm
        xmlModelSunRiseSet.xml = cacheContent.longTerm
        xmlModelHourByHour.xml = cacheContent.hourByHour
        return true
    }
    
}

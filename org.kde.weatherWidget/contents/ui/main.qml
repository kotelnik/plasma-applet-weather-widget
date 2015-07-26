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
import "../code/reloader.js" as Reloader
import "../code/model-utils.js" as ModelUtils
import "../code/config-utils.js" as ConfigUtils
import "../code/icons.js" as IconTools
import "../code/temperature-utils.js" as TemperatureUtils

Item {
    id: main
    
    property string yrnoUrlPreifx: 'http://www.yr.no/place/'
    
    property string townString
    property string placeAlias
    property string xmlCacheKey
    property var xmlCacheMap: {}
    property var lastReloadedMsMap: {}
    property bool fahrenheitEnabled: plasmoid.configuration.fahrenheitEnabled
    property string townStringsJsonStr: plasmoid.configuration.townStrings
    
    property string datetimeFormat: 'yyyy-MM-dd\'T\'hh:mm:ss'
    property var locale: Qt.locale('en_GB')
    property date sunRise: Date.fromLocaleString(locale, '2000-01-01T06:00:00', datetimeFormat)
    property date sunSet: Date.fromLocaleString(locale, '2000-01-01T18:00:00', datetimeFormat)
    
    property string overviewImageSource
    property string overviewLink
    property int reloadIntervalMin: plasmoid.configuration.reloadIntervalMin
    property int reloadIntervalMs: reloadIntervalMin * 60 * 1000
    
    property bool loadingData: false
    property bool loadingError: false
    property bool imageLoadingError: true
    property bool alreadyLoadedFromCache: false
    
    property string lastReloadedText: '⬇ 0m ago'
    property string tooltipSubText: ''
    
    property bool verticalAlignment: plasmoid.configuration.compactLayout
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property bool inTray: (plasmoid.parent === null)
    
    property int nextDaysCount: inTray ? 3 : 8
    
    anchors.fill: parent
    
    property Component crInTray: CompactRepresentationInTray { }
    property Component cr: CompactRepresentation { }
    
    property Component frInTray: FullRepresentationInTray { }
    property Component fr: FullRepresentation { }
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: cr
    Plasmoid.fullRepresentation: fr
    
    FontLoader {
        source: '../fonts/weathericons-regular-webfont.ttf'
    }
    
    XmlListModel {
        id: xmlModel
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
    
    ListModel {
        id: actualWeatherModel
    }
    
    ListModel {
        id: nextDaysModel
    }
    
    Component.onCompleted: {
        
        if (inTray) {
            Plasmoid.compactRepresentation = crInTray
            Plasmoid.fullRepresentation = frInTray
        }
        
        //fill xml cache xml
        var xmlCache = plasmoid.configuration.xmlCacheJson
        if (xmlCache) {
            xmlCacheMap = JSON.parse(xmlCache)
        }
        xmlCacheMap = xmlCacheMap || {}
        
        //fill last reloaded
        var lastReloadedMsJson = plasmoid.configuration.lastReloadedMsJson
        if (lastReloadedMsJson) {
            lastReloadedMsMap = JSON.parse(lastReloadedMsJson)
        }
        lastReloadedMsMap = lastReloadedMsMap || {}
        
        //get town string
        setNextTownString(true)
    }
    
    onTownStringsJsonStrChanged: {
        setNextTownString(true)
    }
    
    function showData() {
        print('init: plasmoid.configuration.lastReloadedMs = ' + getLastReloadedMs())
        var ok = loadFromCache()
        if (!ok) {
            reloadData()
        }
        updateLastReloadedText()
        reloadImage()
    }
    
    function setNextTownString(initial) {
        var townStrings = ConfigUtils.getTownStringArray()
        print('townStrings count', townStrings.length, plasmoid.configuration.townStringIndex)
        var townStringIndex = plasmoid.configuration.townStringIndex
        if (!initial) {
            townStringIndex++
        }
        if (townStringIndex > townStrings.length - 1) {
            townStringIndex = 0
        }
        plasmoid.configuration.townStringIndex = townStringIndex
        print('townStringIndex now', plasmoid.configuration.townStringIndex)
        townString = townStrings[townStringIndex].townString
        placeAlias = townStrings[townStringIndex].placeAlias
        print('next town string is: ' + townString)
        xmlCacheKey = generateXmlCacheKey(townString)
        print('next xmlCacheKey is: ' + xmlCacheKey)
        
        alreadyLoadedFromCache = false
        overviewLink = yrnoUrlPreifx + townString + '/'
        
        showData()
    }
    
    function generateXmlCacheKey(townStr) {
        var hash = 0
        if (townStr.length !== 0) {
            for (var i = 0; i < townStr.length; i++) {
                var ch = townStr.charCodeAt(i);
                hash = ((hash << 5) - hash) + ch
                hash = hash & hash // Convert to 32bit integer
            }
        }
        return 'xmlCache_' + hash
    }
    
    function reloadData() {
        if (loadingData) {
            print('still loading')
            return
        }
        
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }
            
            loadingData = false
                
            if (xhr.status !== 200) {
                handleLoadError()
                return
            }
            
            // success
            print('successfully loaded from the internet')
            
            var xmlString = xhr.responseText;
            if (!ModelUtils.isXmlStringValid(xmlString)) {
                print('incomming xmlString is not valid: ' + xmlString)
                return
            }
            print('incomming text seems to be valid')
            
            xmlCacheMap[xmlCacheKey] = xmlString
            alreadyLoadedFromCache = false
            plasmoid.configuration.xmlCacheJson = JSON.stringify(xmlCacheMap)
            
            reloadImage()
            overviewLink = yrnoUrlPreifx + townString + '/'
            reloaded()
            
            loadFromCache()
        }
        xhr.open('GET', yrnoUrlPreifx + townString + '/forecast.xml')
        
        loadingData = true
        xhr.send()
        
        print('reload called, xmlCacheKey is: ' + xmlCacheKey)
    }
    
    function reloadImage() {
        print('reloading image')
        overviewImageSource = ''
        overviewImageSource = yrnoUrlPreifx + townString + '/avansert_meteogram.png'
    }
    
    function setLastReloadedMs(lastReloadedMs) {
        lastReloadedMsMap[xmlCacheKey] = lastReloadedMs
        plasmoid.configuration.lastReloadedMsJson = JSON.stringify(lastReloadedMsMap)
    }
    
    function getLastReloadedMs() {
        if (!lastReloadedMsMap) {
            return new Date().getTime()
        }
        return lastReloadedMsMap[xmlCacheKey]
    }
    
    function reloaded() {
        setLastReloadedMs(Reloader.setReloaded())
        updateLastReloadedText()
        print('reloaded')
    }
    
    function loadFromCache() {
        print('loading from cache, config key: ', xmlCacheKey)
        
        if (alreadyLoadedFromCache) {
            print('already loaded from cache')
            return true
        }
        
        if (!xmlCacheMap || !xmlCacheMap[xmlCacheKey]) {
            print('cache not available')
            return false
        }
        
        xmlModel.xml = xmlCacheMap[xmlCacheKey]
        xmlModelSunRiseSet.xml = xmlCacheMap[xmlCacheKey]
        alreadyLoadedFromCache = true
        return true
    }
    
    states: [
        State {
            name: 'ready'
            when: xmlModel.status == XmlListModel.Ready
            
            StateChangeScript {
                script: {
                    print('xmlModel ready')
                    ModelUtils.updateCurrentWeatherModel(actualWeatherModel, xmlModel)
                    ModelUtils.updateNextDaysWeatherModel(nextDaysModel, xmlModel)
                    refreshTooltipSubText()
                }
            }
        }
    ]
    
    Item {
        states: [
            State {
                name: 'sunReady'
                when: xmlModelSunRiseSet.status == XmlListModel.Ready
                
                StateChangeScript {
                    script: {
                        print('xmlModelSunRiseSet ready')
                        sunRise = Date.fromLocaleString(locale, xmlModelSunRiseSet.get(0).rise, datetimeFormat)
                        sunSet = Date.fromLocaleString(locale, xmlModelSunRiseSet.get(0).set, datetimeFormat)
                        var now = new Date()
                        sunRise.setFullYear(now.getFullYear())
                        sunRise.setMonth(now.getMonth())
                        sunRise.setDate(now.getDate())
                        sunSet.setFullYear(now.getFullYear())
                        sunSet.setMonth(now.getMonth())
                        sunSet.setDate(now.getDate())
                        print('new sunRise: ' + sunRise + ', sunSet: ' + sunSet)
                    }
                }
            }
        ]
    }
    
    function handleLoadError() {
        print('Error getting weather data. Scheduling data reload...')
        Reloader.scheduleDataReload()
        
        loadFromCache()
    }
    
    function updateLastReloadedText() {
        lastReloadedText = '⬇ ' + Reloader.getLastReloadedMins(getLastReloadedMs()) + 'm ago'
    }
    
    function refreshTooltipSubText() {
        print('refreshing sub text')
        var futureWeatherIcon = IconTools.getIconCode(xmlModel.get(1).iconName, true, getPartOfDayIndex())
        var windDirectionIcon = IconTools.getWindDirectionIconCode(xmlModel.get(0).windDirection)
        var subText = ''
        subText += '<br /><font size="4"><font style="font-family: weathericons">' + windDirectionIcon + '</font></font><font size="4"> ' + xmlModel.get(0).windSpeedMps + ' M/s</font>'
        subText += '<br /><font size="4">' + xmlModel.get(0).pressureHpa + ' hPa</font>'
        subText += '<br /><br />'
        subText += '<font size="6">~><b><font color="transparent">__</font>' + TemperatureUtils.getTemperatureNumber(xmlModel.get(1).temperature, fahrenheitEnabled) + '°' + (fahrenheitEnabled ? 'F' : 'C')
        subText += '<font color="transparent">__</font><font style="font-family: weathericons">' + futureWeatherIcon + '</font></b></font>'
        tooltipSubText = subText
    }
    
    function getPartOfDayIndex() {
        //return xmlModel.get(1).period === '0' || xmlModel.get(1).period === '3' ? 1 : 0
        
        var now = new Date()
        print('determining part of day')
        return sunRise < now && now < sunSet ? 0 : 1
    }
    
    function tryReload() {
        updateLastReloadedText()
        
        if (imageLoadingError && !loadingError) {
            reloadImage()
            imageLoadingError = false
        }
        
        if (Reloader.isReadyToReload(reloadIntervalMs, getLastReloadedMs())) {
            reloadData()
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            tryReload()
        }
    }
    
    onFahrenheitEnabledChanged: {
        refreshTooltipSubText()
    }
    
}

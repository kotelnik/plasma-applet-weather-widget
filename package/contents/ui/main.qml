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
import QtQuick.Controls 1.0
import "../code/data-loader.js" as DataLoader
import "../code/config-utils.js" as ConfigUtils
import "../code/icons.js" as IconTools
import "../code/temperature-utils.js" as TemperatureUtils
import "providers"

Item {
    id: main
    
    property string yrnoUrlPreifx: 'http://www.yr.no/place/'
    
    property string townString
    property string placeAlias
    property string cacheKey
    property var cacheMap: {}
    property var lastReloadedMsMap: {}
    property bool renderMeteogram: plasmoid.configuration.renderMeteogram
    property bool fahrenheitEnabled: plasmoid.configuration.fahrenheitEnabled
    property string townStringsJsonStr: plasmoid.configuration.townStrings
    
    property string datetimeFormat: 'yyyy-MM-dd\'T\'hh:mm:ss'
    property var locale: Qt.locale('en_GB')
    property var additionalWeatherInfo: {}
    
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
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property bool inTray: (plasmoid.parent === null || plasmoid.parent.objectName === 'taskItemContainer')
    
    property int inTrayActiveTimeoutSec: plasmoid.configuration.inTrayActiveTimeoutSec
    
    property int nextDaysCount: 8
    
    // 0 - standard
    // 1 - vertical
    // 2 - compact
    property int layoutType: plasmoid.configuration.layoutType
    
    property bool updatingPaused: true
    
    property var currentProvider: null
    
    property bool meteogramModelChanged: false
    
    anchors.fill: parent
    
    property Component crInTray: CompactRepresentationInTray { }
    property Component cr: CompactRepresentation { }
    
    property Component frInTray: FullRepresentationInTray { }
    property Component fr: FullRepresentation { }
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: cr
    Plasmoid.fullRepresentation: fr
    
    property bool debugLogging: true
    
    function dbgprint(msg) {
        if (!debugLogging) {
            return
        }
        print('[weatherWidget] ' + msg)
    }
    
    FontLoader {
        source: '../fonts/weathericons-regular-webfont.ttf'
    }
    
    YrNo {
        id: yrnoProvider
    }
    
    ListModel {
        id: actualWeatherModel
    }
    
    ListModel {
        id: nextDaysModel
    }
    
    ListModel {
        id: meteogramModel
    }
    
    function action_toggleUpdatingPaused() {
        updatingPaused = !updatingPaused
        plasmoid.setAction('toggleUpdatingPaused', updatingPaused ? i18n('Resume Updating') : i18n('Pause Updating'), updatingPaused ? 'media-playback-start' : 'media-playback-pause');
    }
    
    WeatherCache {
        id: weatherCache
    }
    
    Component.onCompleted: {
        
        additionalWeatherInfo = {
            sunRise: Date.fromLocaleString(locale, '2000-01-01T06:00:00', datetimeFormat),
            sunSet: Date.fromLocaleString(locale, '2000-01-01T18:00:00', datetimeFormat),
            sunRiseTime: '6:00',
            sunSetTime: '18:00',
            nearFutureWeather: {
                iconName: null,
                temperature: null
            }
        }
        
        // systray settings
        if (inTray) {
            Plasmoid.compactRepresentation = crInTray
            Plasmoid.fullRepresentation = frInTray
        }
        
        // init contextMenu
        action_toggleUpdatingPaused()
        
        var cacheContent = weatherCache.readCache()
        
        dbgprint('readCache result length: ' + cacheContent.length)
            
        //fill xml cache xml
        if (cacheContent) {
            try {
                cacheMap = JSON.parse(cacheContent)
                dbgprint('cacheMap initialized - keys:')
                for (var key in cacheMap) {
                    dbgprint('  ' + key + ', data: ' + cacheMap[key])
                }
            } catch (error) {
                dbgprint('error parsing cacheContent')
            }
        }
        cacheMap = cacheMap || {}
        
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
        dbgprint('init: plasmoid.configuration.lastReloadedMs = ' + getLastReloadedMs())
        var ok = loadFromCache()
        if (!ok) {
            reloadData()
        }
        updateLastReloadedText()
        reloadMeteogram()
    }
    
    function setNextTownString(initial) {
        var townStrings = ConfigUtils.getTownStringArray()
        dbgprint('townStrings count=' + townStrings.length + ', townStringsIndex=' + plasmoid.configuration.townStringIndex)
        var townStringIndex = plasmoid.configuration.townStringIndex
        if (!initial) {
            townStringIndex++
        }
        if (townStringIndex > townStrings.length - 1) {
            townStringIndex = 0
        }
        plasmoid.configuration.townStringIndex = townStringIndex
        dbgprint('townStringIndex now: ' + plasmoid.configuration.townStringIndex)
        townString = townStrings[townStringIndex].townString
        placeAlias = townStrings[townStringIndex].placeAlias
        dbgprint('next town string is: ' + townString)
        cacheKey = DataLoader.generateCacheKey(townString)
        dbgprint('next cacheKey is: ' + cacheKey)
        
        alreadyLoadedFromCache = false
        overviewLink = yrnoUrlPreifx + townString + '/'
        
        currentProvider = yrnoProvider
        
        showData()
    }
    
    function dataLoadedFromInternet(contentToCache, overviewLinkUrl) {
        loadingData = false
        
        dbgprint('saving cacheKey = ' + cacheKey)
        cacheMap[cacheKey] = contentToCache
        dbgprint('cacheMap now has these keys:')
        for (var key in cacheMap) {
            dbgprint('  ' + key)
        }
        alreadyLoadedFromCache = false
        weatherCache.writeCache(JSON.stringify(cacheMap))
        
        reloadMeteogram()
        overviewLink = overviewLinkUrl
        reloaded()
        
        loadFromCache()
    }
    
    function reloadData() {
        if (loadingData) {
            dbgprint('still loading')
            return
        }
        
        loadingData = true
        
        function successCallback(contentToCache, overviewLinkUrl) {
            
        }
        
        function failureCallback() {
            main.loadingData = false
            handleLoadError()
        }
        
        currentProvider.loadDataFromInternet(dataLoadedFromInternet, failureCallback, { townString: townString })
        
        dbgprint('reload called, cacheKey is: ' + cacheKey)
    }
    
    function reloadMeteogram() {
        dbgprint('reloading image')
        overviewImageSource = ''
        overviewImageSource = yrnoUrlPreifx + townString + '/avansert_meteogram.png'
    }
    
    function setLastReloadedMs(lastReloadedMs) {
        lastReloadedMsMap[cacheKey] = lastReloadedMs
        plasmoid.configuration.lastReloadedMsJson = JSON.stringify(lastReloadedMsMap)
    }
    
    function getLastReloadedMs() {
        if (!lastReloadedMsMap) {
            return new Date().getTime()
        }
        return lastReloadedMsMap[cacheKey]
    }
    
    function reloaded() {
        setLastReloadedMs(DataLoader.setReloaded())
        updateLastReloadedText()
        dbgprint('reloaded')
    }
    
    function loadFromCache() {
        dbgprint('loading from cache, config key: ' + cacheKey)
        
        if (alreadyLoadedFromCache) {
            dbgprint('already loaded from cache')
            return true
        }
        
        if (!cacheMap || !cacheMap[cacheKey]) {
            dbgprint('cache not available')
            return false
        }
        
        var success = currentProvider.setWeatherContents(cacheMap[cacheKey])
        if (!success) {
            dbgprint('setting weather contents not successful')
            return false
        }
        
        alreadyLoadedFromCache = true
        return true
    }
    
    function handleLoadError() {
        dbgprint('Error getting weather data. Scheduling data reload...')
        DataLoader.scheduleDataReload()
        
        loadFromCache()
    }
    
    onInTrayActiveTimeoutSecChanged: {
        updateLastReloadedText()
    }
    
    function updateLastReloadedText() {
        var lastReloadedMs = getLastReloadedMs()
        lastReloadedText = '⬇ ' + DataLoader.getLastReloadedTimeText(lastReloadedMs) + ' ago'
        plasmoid.status = DataLoader.getPlasmoidStatus(lastReloadedMs, inTrayActiveTimeoutSec)
    }
    
    function refreshTooltipSubText(actualWeatherModel, additionalWeatherInfo, fahrenheitEnabled) {
        dbgprint('refreshing sub text')
        if (additionalWeatherInfo === undefined || additionalWeatherInfo.nearFutureWeather.iconName === null) {
            dbgprint('model not yet ready')
            return
        }
        var nearFutureWeather = additionalWeatherInfo.nearFutureWeather
        var futureWeatherIcon = IconTools.getIconCode(nearFutureWeather.iconName, true, getPartOfDayIndex())
        var windDirectionIcon = IconTools.getWindDirectionIconCode(actualWeatherModel.get(0).windDirection)
        var subText = ''
        
        if (inTray) {
            subText += '<br /><font size="4"> ' + actualWeatherModel.get(0).windSpeedMps + ' m/s</s</font>'
            subText += '<br /><font size="4">' + actualWeatherModel.get(0).pressureHpa + ' hPa</font>'
            subText += '<br /><font size="4">⬆&nbsp;' + additionalWeatherInfo.sunRiseTime + '&nbsp;&nbsp;&nbsp;⬇&nbsp;' + additionalWeatherInfo.sunSetTime + '</font>'
            subText += '<br /><br />'
            subText += '<font size="6">~><b><font color="transparent">__</font>' + TemperatureUtils.getTemperatureNumber(nearFutureWeather.temperature, fahrenheitEnabled) + '°' + (fahrenheitEnabled ? 'F' : 'C')
        } else {
            subText += '<br /><font size="4" style="font-family: weathericons">' + windDirectionIcon + '</font><font size="4"> ' + actualWeatherModel.get(0).windSpeedMps + ' m/s</s</font>'
            subText += '<br /><font size="4">' + actualWeatherModel.get(0).pressureHpa + ' hPa</font>'
            subText += '<br /><font size="4"><font style="font-family: weathericons">\uf051</font>&nbsp;' + additionalWeatherInfo.sunRiseTime + '&nbsp;&nbsp;&nbsp;<font style="font-family: weathericons">\uf052</font>&nbsp;' + additionalWeatherInfo.sunSetTime + '</font>'
            subText += '<br /><br />'
            subText += '<font size="6">~><b><font color="transparent">__</font>' + TemperatureUtils.getTemperatureNumber(nearFutureWeather.temperature, fahrenheitEnabled) + '°' + (fahrenheitEnabled ? 'F' : 'C')
            subText += '<font color="transparent">__</font><font style="font-family: weathericons">' + futureWeatherIcon + '</font></b></font>'
        }
        
        tooltipSubText = subText
    }
    
    function getPartOfDayIndex() {
        var now = new Date()
        return additionalWeatherInfo.sunRise < now && now < additionalWeatherInfo.sunSet ? 0 : 1
    }
    
    function tryReload() {
        updateLastReloadedText()
        
        if (updatingPaused) {
            return
        }
        
        if (imageLoadingError && !loadingError) {
            reloadMeteogram()
            imageLoadingError = false
        }
        
        if (DataLoader.isReadyToReload(reloadIntervalMs, getLastReloadedMs())) {
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
        refreshTooltipSubText(actualWeatherModel, additionalWeatherInfo, fahrenheitEnabled)
    }
    
}

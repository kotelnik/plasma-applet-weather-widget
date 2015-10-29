var scheduledDataReload = null

var DataType = {
    YRNO: 1,
    OWP: 2
}

function isReadyToReload(reloadIntervalMs, lastReloaded) {
    var now = new Date().getTime()
    if (loadingError && scheduledDataReload !== null) {
        return scheduledDataReload < now
    }
    if (!lastReloaded) {
        lastReloaded = 0
    }
    return now - lastReloaded > reloadIntervalMs
}

function setReloaded() {
    loadingError = false
    return new Date().getTime()
}

function getLastReloadedTimeText(lastReloaded) {
    var reloadedAgoMs = getReloadedAgoMs(lastReloaded)
    var mins = reloadedAgoMs / 60000;
    
    if (mins <= 180) {
        return Math.round(mins) + 'm'
    }
    
    var hours = mins / 60
    if (hours <= 48) {
        return Math.round(hours) + 'h'
    }
    
    var days = hours / 24
    if (days <= 14) {
        return Math.round(days) + 'd'
    }
    
    return 'long'
}

function scheduleDataReload() {
    var now = new Date().getTime()
    loadingError = true
    scheduledDataReload = now + 15000
}

function getReloadedAgoMs(lastReloaded) {
    if (!lastReloaded) {
        lastReloaded = 0
    }
    return new Date().getTime() - lastReloaded
}

function getPlasmoidStatus(lastReloaded, inTrayActiveTimeoutSec) {
    var reloadedAgoMs = getReloadedAgoMs(lastReloaded)
    if (reloadedAgoMs < inTrayActiveTimeoutSec*1000) {
        return PlasmaCore.Types.ActiveStatus
    } else {
        return PlasmaCore.Types.PassiveStatus
    }
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

function isXmlStringValid(xmlString) {
    return xmlString.indexOf('<?xml ') === 0
}

function fetchXmlFromInternet(getUrl, successCallback, failureCallback) {
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE) {
            return
        }
        
        if (xhr.status !== 200) {
            failureCallback()
            return
        }
        
        // success
        dbgprint('successfully loaded from the internet')
        
        var xmlString = xhr.responseText;
        if (!DataLoader.isXmlStringValid(xmlString)) {
            dbgprint('incomming xmlString is not valid: ' + xmlString)
            return
        }
        dbgprint('incomming text seems to be valid')
        
        successCallback(xmlString)
    }
    xhr.open('GET', getUrl)
    xhr.send()
    
    dbgprint('GET called for url: ' + getUrl)
    print('[weatherWidget] GET called for url: ' + getUrl)
}

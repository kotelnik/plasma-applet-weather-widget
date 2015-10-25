var scheduledDataReload = null

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

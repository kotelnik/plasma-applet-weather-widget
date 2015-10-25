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
    if (!lastReloaded) {
        lastReloaded = 0
    }
    var reloadedAgoMs = new Date().getTime() - lastReloaded
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

var scheduledDataReload = null

function isReadyToReload(reloadIntervalMs, lastReloaded) {
    print('is ready to reload - lastReloaded: ' + lastReloaded)
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

function getLastReloadedMins(lastReloaded) {
    if (!lastReloaded) {
        lastReloaded = 0
    }
    var reloadedAgoMs = new Date().getTime() - lastReloaded
    return Math.round(reloadedAgoMs / 60000)
}

function scheduleDataReload() {
    var now = new Date().getTime()
    loadingError = true
    scheduledDataReload = now + 15000
}

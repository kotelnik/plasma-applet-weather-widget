var lastReloaded = new Date().getTime()
var wasErrorReloading = false
var scheduledDataReload = new Date().getTime()

function isReadyToReload(reloadIntervalMs) {
    var now = new Date().getTime()
    if (wasErrorReloading && scheduledDataReload < now) {
        return true
    }
    return now - lastReloaded > reloadIntervalMs
}

function setReloaded() {
    wasErrorReloading = false
    lastReloaded = new Date().getTime()
}

function getLastReloadedMins() {
    var reloadedAgoMs = new Date().getTime() - lastReloaded
    return Math.round(reloadedAgoMs / 1000 / 60)
}

function scheduleDataReload() {
    var now = new Date().getTime()
    wasErrorReloading = true
    scheduledDataReload = now + 1000 * 15
}

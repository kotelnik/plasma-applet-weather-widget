var lastReloaded = new Date().getTime()

function isReadyToReload(reloadIntervalMs) {
    var now = new Date().getTime()
    return now - lastReloaded > reloadIntervalMs
}

function setReloaded() {
    lastReloaded = new Date().getTime()
}

function getLastReloadedMins() {
    var reloadedAgoMs = new Date().getTime() - lastReloaded
    return Math.round(reloadedAgoMs / 1000 / 60)
}

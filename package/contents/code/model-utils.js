var wholeDayDurationMs = 1000 * 60 * 60 * 24

function createEmptyNextDaysObject() {
    return {
        temperatureArray: [],
        iconNameArray: [],
        dayTitle: ''
    }
}

function populateNextDaysObject(nextDaysObj) {
    for (var i = 0; i < 4; i++) {
        nextDaysObj['temperature' + i] = nextDaysObj.temperatureArray[i]
        nextDaysObj['iconName' + i] = nextDaysObj.iconNameArray[i]
        nextDaysObj['hidden' + i] = nextDaysObj.iconNameArray[i] === null
    }
}

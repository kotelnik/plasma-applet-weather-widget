/*
 * TEMPERATURE
 */
function toFahrenheit(celsia) {
    return celsia * (9/5) + 32
}

function getTemperatureNumber(temperatureStr, fahrenheitEnabled) {
    var fl = parseFloat(temperatureStr)
    if (fahrenheitEnabled) {
        fl = toFahrenheit(fl)
    }
    return Math.round(fl)
}

function kelvinToCelsia(kelvin) {
    return kelvin - 273.15
}

/*
 * PRESSURE
 */
function getPressureNumber(hpa, inhgEnabled) {
    if (inhgEnabled) {
        return Math.round(hpa * 0.0295299830714 * 10) / 10
//         return Math.round(hpa * 0.0295299830714)//TODO
    }
    return hpa
}

function getPressureText(hpa, inhgEnabled) {
    return getPressureNumber(hpa, inhgEnabled) + ' ' + getPressureEnding(inhgEnabled)
}

function getPressureEnding(inhgEnabled) {
    return inhgEnabled ? 'inHg' : 'hPa'
}

/*
 * WIND SPEED
 */
function getWindSpeedNumber(mps, mphEnabled) {
    if (mphEnabled) {
        return Math.round(mps * 2.2369362920544 * 10) / 10
    }
    return mps
}

function getWindSpeedText(mps, mphEnabled) {
    return getWindSpeedNumber(mps, mphEnabled) + ' ' + getWindSpeedEnding(mphEnabled)
}

function getWindSpeedEnding(mphEnabled) {
    return mphEnabled ? 'mph' : 'm/s'
}

function getHourText(hourNumber, twelveHourClockEnabled) {
    var result = hourNumber
    if (twelveHourClockEnabled) {
        if (hourNumber === 0) {
            result = 12
        } else {
            result = hourNumber > 12 ? hourNumber - 12 : hourNumber
        }
    }
    return result < 10 ? '0' + result : result
}

function getAmOrPm(hourNumber) {
    if (hourNumber === 0) {
        return 'AM'
    }
    return hourNumber > 11 ? 'PM' : 'AM'
}

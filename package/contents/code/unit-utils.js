/*
 * TEMPERATURE
 */
var TemperatureType = {
    CELSIUS: 0,
    FAHRENHEIT: 1
}

function toFahrenheit(celsia) {
    return celsia * (9/5) + 32
}

function getTemperatureNumber(temperatureStr, temperatureType) {
    var fl = parseFloat(temperatureStr)
    if (temperatureType === TemperatureType.FAHRENHEIT) {
        fl = toFahrenheit(fl)
    }
    return Math.round(fl)
}

function kelvinToCelsia(kelvin) {
    return kelvin - 273.15
}

function getTemperatureEnding(temperatureType) {
    return temperatureType === TemperatureType.FAHRENHEIT ? '°F' : '°C'
}

/*
 * PRESSURE
 */
var PressureType = {
    HPA: 0,
    INHG: 1,
    MMHG: 2
}

function getPressureNumber(hpa, pressureType) {
    if (pressureType === PressureType.INHG) {
        return Math.round(hpa * 0.0295299830714 * 10) / 10
    }
    if (pressureType === PressureType.MMHG) {
        return Math.round(hpa * 0.750061683)
    }
    return hpa
}

function getPressureText(hpa, pressureType) {
    return getPressureNumber(hpa, pressureType) + ' ' + getPressureEnding(pressureType)
}

function getPressureEnding(pressureType) {
    if (pressureType === PressureType.INHG) {
        return 'inHg'
    }
    if (pressureType === PressureType.MMHG) {
        return 'mmHg'
    }
    return 'hPa'
}

/*
 * WIND SPEED
 */
var WindSpeedType = {
    MPS: 0,
    MPH: 1
}

function getWindSpeedNumber(mps, windSpeedType) {
    if (windSpeedType === WindSpeedType.MPH) {
        return Math.round(mps * 2.2369362920544 * 10) / 10
    }
    return mps
}

function getWindSpeedText(mps, windSpeedType) {
    return getWindSpeedNumber(mps, windSpeedType) + ' ' + getWindSpeedEnding(windSpeedType)
}

function getWindSpeedEnding(windSpeedType) {
    return windSpeedType === WindSpeedType.MPH ? 'mph' : 'm/s'
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

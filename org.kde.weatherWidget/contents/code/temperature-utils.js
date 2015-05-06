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

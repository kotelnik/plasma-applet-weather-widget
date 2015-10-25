var wholeDayDurationMs = 1000 * 60 * 60 * 24

function isXmlStringValid(xmlString) {
    
    return xmlString.indexOf('<?xml ') === 0
    
}

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

function updateWeatherModels(currentWeatherModel, nextCurrentWeatherModel, nextDaysWeatherModel, originalXmlModel) {
    
    var nextDaysFixedCount = nextDaysCount
    
    var now = new Date()
    var nextDayStart = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + wholeDayDurationMs)
    dbgprint('next day start: ' + nextDayStart)
    
    dbgprint('orig: ' + originalXmlModel.count)

    var todayObject = null
    var newObjectArray = []
    var lastObject = null
    var addingStarted = false
    
    var interestingTimeObj = null
    var nextInterestingTimeObj = null
    var currentWeatherModelsSet = false
    
    for (var i = 0; i < originalXmlModel.count; i++) {
        var timeObj = originalXmlModel.get(i)
        var dateFrom = new Date(timeObj.from)
        var dateTo = new Date(timeObj.to)
        dbgprint('from=' + dateFrom + ', to=' + dateTo + ', now=' + now + ', i=' + i)
        
        // prepare current models
        if (!currentWeatherModelsSet
            && ((i === 0 && now < dateFrom) || (dateFrom < now && now < dateTo))) {
            
            interestingTimeObj = timeObj
            if (i + 1 < originalXmlModel.count) {
                nextInterestingTimeObj = originalXmlModel.get(i + 1)
            }
            currentWeatherModelsSet = true
        }
        
        if (!addingStarted) {
            addingStarted = dateTo >= nextDayStart && timeObj.period === '0'
            
            if (!addingStarted) {
                
                // add today object
                if (todayObject === null) {
                    todayObject = createEmptyNextDaysObject()
                    todayObject.dayTitle = i18n('today')
                }
                todayObject.temperatureArray.push(timeObj.temperature)
                todayObject.iconNameArray.push(timeObj.iconName)
                
                continue
            }
            dbgprint('found start!')
        }
        
        var periodNo = parseInt(timeObj.period)
        if (periodNo === 0) {
            dbgprint('period 0, array: ' + newObjectArray.length + ', nextDaysCount: ' + nextDaysFixedCount)
            if (newObjectArray.length === nextDaysFixedCount) {
                dbgprint('breaking')
                break
            }
            lastObject = createEmptyNextDaysObject()
            lastObject.dayTitle = Qt.locale().dayName(dateTo.getDay(), Locale.ShortFormat) + ' ' + dateTo.getDate() + '.' + (dateTo.getMonth() + 1) + '.'
            newObjectArray.push(lastObject)
        }
        
        lastObject.temperatureArray.push(timeObj.temperature)
        lastObject.iconNameArray.push(timeObj.iconName)
        
        dbgprint('lastObject.temperatureArray: ', lastObject.temperatureArray)
    }

    // set current models
    currentWeatherModel.clear()
    nextCurrentWeatherModel.clear()
    if (interestingTimeObj !== null) {
        currentWeatherModel.append(interestingTimeObj)
    }
    if (nextInterestingTimeObj !== null) {
        nextCurrentWeatherModel.append(nextInterestingTimeObj)
    }

    //
    // set next days model
    //
    nextDaysWeatherModel.clear()
    
    // prepend today object
    if (todayObject !== null) {
        while (todayObject.temperatureArray.length < 4) {
            todayObject.temperatureArray.unshift(null)
            todayObject.iconNameArray.unshift(null)
        }
        populateNextDaysObject(todayObject)
        nextDaysWeatherModel.append(todayObject)
    }
    
    newObjectArray.forEach(function (objToAdd) {
        if (nextDaysWeatherModel.count >= nextDaysFixedCount) {
            return
        }
        populateNextDaysObject(objToAdd)
        nextDaysWeatherModel.append(objToAdd)
    })
    for (var i = 0; i < (nextDaysFixedCount - nextDaysWeatherModel.count); i++) {
        nextDaysWeatherModel.append(createEmptyNextDaysObject())
    }
    
    dbgprint('result currentWeatherModel count: ', currentWeatherModel.count)
    dbgprint('result nextCurrentWeatherModel count: ', nextCurrentWeatherModel.count)
    dbgprint('result nextDaysWeatherModel count: ', nextDaysWeatherModel.count)
}

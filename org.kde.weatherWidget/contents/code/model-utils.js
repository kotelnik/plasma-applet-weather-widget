var wholeDayDurationMs = 1000 * 60 * 60 * 24

function updateCurrentWeatherModel(currentWeatherModel, nextCurrentWeatherModel, originalXmlModel) {
    
    var now = new Date()
    var interestingTimeObj = null
    var nextInterestingTimeObj = null
    
    print('orig', originalXmlModel.count)
    
    for (var i = 0; i < originalXmlModel.count; i++) {
        var timeObj = originalXmlModel.get(i)
        var dateFrom = new Date(timeObj.from)
        var dateTo = new Date(timeObj.to)
        print('from, to, now, i', dateFrom, dateTo, now, i)
        
        if ((i === 0 && now < dateFrom)
            || (dateFrom < now && now < dateTo)) {
            
            interestingTimeObj = timeObj
            if (i + 1 < originalXmlModel.count) {
                nextInterestingTimeObj = originalXmlModel.get(i + 1)
            }
            break
        }
    }
    
    currentWeatherModel.clear()
    nextCurrentWeatherModel.clear()
    
    if (interestingTimeObj !== null) {
        currentWeatherModel.append(interestingTimeObj)
    }
    if (nextInterestingTimeObj !== null) {
        nextCurrentWeatherModel.append(nextInterestingTimeObj)
    }
    
    print('w model: ', currentWeatherModel.count)
}

function createEmptyNextDaysObject() {
    return {
        temperatureArray: [],
        iconNameArray: [],
        dateString: '',
        dayTitle: ''
    }
}

function populateNextDaysObject(nextDaysObj) {
    for (var i = 0; i < 4; i++) {
        nextDaysObj['temperature' + i] = nextDaysObj.temperatureArray[i]
        nextDaysObj['iconName' + i] = nextDaysObj.iconNameArray[i]
    }
}

function updateNextDaysWeatherModel(nextDaysWeatherModel, originalXmlModel) {
    
    var nextDaysFixedCount = nextDaysCount
    
    var now = new Date()
    var nextDayStart = new Date(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() + wholeDayDurationMs)
    
    print('2orig', originalXmlModel.count)

    var newObjectArray = []
    var lastObject = null
    var addingStarted = false
    
    for (var i = 0; i < originalXmlModel.count; i++) {
        var timeObj = originalXmlModel.get(i)
        var dateFrom = new Date(timeObj.from)
        var dateTo = new Date(timeObj.to)
        print('2from, to, now, i', dateFrom, dateTo, now, i)
        
        if (!addingStarted) {
            addingStarted = dateTo.getFullYear() === nextDayStart.getFullYear() && dateTo.getMonth() === nextDayStart.getMonth() && dateTo.getDate() === nextDayStart.getDate() && timeObj.period === '0'
            if (!addingStarted) {
                continue
            }
            print('found start!')
        }
        
        var periodNo = parseInt(timeObj.period)
        if (periodNo === 0) {
            print('period 0, array: ' + newObjectArray.length + ', nextDaysCount: ' + nextDaysFixedCount)
            if (newObjectArray.length === nextDaysFixedCount) {
                print('breaking')
                break
            }
            lastObject = createEmptyNextDaysObject()
            lastObject.dateString = dateTo.getDate() + '.' + (dateTo.getMonth() + 1) + '.'
            lastObject.dayTitle = Qt.locale().dayName(dateTo.getDay(), Locale.ShortFormat)
            newObjectArray.push(lastObject)
        }
        
        lastObject.temperatureArray.push(timeObj.temperature)
        lastObject.iconNameArray.push(timeObj.iconName)
        
        print('lastObject.temperatureArray: ', lastObject.temperatureArray)
    }
    
    nextDaysWeatherModel.clear()
    
    for (var i = 0; i < newObjectArray.length; i++) {
        var objToAdd = newObjectArray[i]
        populateNextDaysObject(objToAdd)
        nextDaysWeatherModel.append(objToAdd)
    }
    for (var i = 0; i < (nextDaysFixedCount - nextDaysWeatherModel.count); i++) {
        nextDaysWeatherModel.append(createEmptyNextDaysObject())
    }
    
    print('2w model: ', nextDaysWeatherModel.count)
}

function isXmlStringValid(xmlString) {
    
    return xmlString.indexOf('<?xml ') === 0
    
}
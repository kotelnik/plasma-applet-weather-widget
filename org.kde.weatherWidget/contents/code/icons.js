var iconCodeById = {
     '1': ['\uf00d', '\uf095'],
     '2': ['\uf00c', '\uf083'],
     '3': ['\uf002', '\uf031'],
     '4': ['\uf013', '\uf013'],
     '5': ['\uf009', '\uf037'],
     '6': ['\uf00e', '\uf03a'],
     '7': ['\uf006', '\uf034'],
     '8': ['\uf00a', '\uf038'],
     '9': ['\uf01a', '\uf01a'],
    '10': ['\uf019', '\uf019'],
    '11': ['\uf01e', '\uf01e'],
    '12': ['\uf017', '\uf017'],
    '13': ['\uf01b', '\uf01b'],
    '14': ['\uf06b', '\uf06c'], //TODO no icon in fonts! using SnowSunThunder
    '15': ['\uf063', '\uf063'],
    '20': ['\uf068', '\uf069'],
    '21': ['\uf06b', '\uf06c'],
    '22': ['\uf01d', '\uf01d'],
    '23': ['\uf01d', '\uf01d'], //TODO used LightRainThunder
    '24': ['\uf00b', '\uf039'], //TODO used DrizzleSun
    '25': ['\uf010', '\uf03b'],
    '26': ['\uf068', '\uf069'], //TODO used SleetSunThunder
    '27': ['\uf068', '\uf069'], //TODO used SleetSunThunder
    '28': ['\uf06b', '\uf06c'], //TODO no icon in fonts! using SnowSunThunder
    '29': ['\uf06b', '\uf06c'], //TODO no icon in fonts! using SnowSunThunder
    '30': ['\uf01c', '\uf01c'], //TODO used Drizzle
    '31': ['\uf01d', '\uf01d'], //TODO used LightRainThunder
    '32': ['\uf01d', '\uf01d'], //TODO used LightRainThunder
    '33': ['\uf06b', '\uf06c'], //TODO no icon in fonts! using SnowSunThunder
    '34': ['\uf06b', '\uf06c'], //TODO no icon in fonts! using SnowSunThunder
    '40': ['\uf00b', '\uf039'],
    '41': ['\uf008', '\uf036'],
    '42': ['\uf006', '\uf034'], //TODO used SleetSun
    '43': ['\uf006', '\uf034'], //TODO used SleetSun
    '44': ['\uf00a', '\uf038'], //TODO used SnowSun
    '45': ['\uf00a', '\uf038'], //TODO used SnowSun
    '46': ['\uf01c', '\uf01c'],
    '47': ['\uf017', '\uf017'], //TODO same as Sleet for now
    '48': ['\uf017', '\uf017'], //TODO same as Sleet for now
    '49': ['\uf01b', '\uf01b'], //TODO used Snow
    '50': ['\uf01b', '\uf01b']  //TODO used Snow
}

var iconIdByIconName = {
    'Sun': '1',
    'LightCloud': '2',
    'PartlyCloud': '3',
    'Cloud': '4',
    'LightRainSun': '5',
    'LightRainThunderSun': '6',
    'SleetSun': '7',
    'SnowSun': '8',
    'LightRain': '9',
    'Rain': '10',
    'RainThunder': '11',
    'Sleet': '12',
    'Snow': '13',
    'SnowThunder': '14',
    'Fog': '15',
    'SleetSunThunder': '20',
    'SnowSunThunder': '21',
    'LightRainThunder': '22',
    'SleetThunder': '23',
    'DrizzleThunderSun': '24',
    'RainThunderSun': '25',
    'LightSleetThunderSun': '26',
    'HeavySleetThunderSun': '27',
    'LightSnowThunderSun': '28',
    'HeavySnowThunderSun': '29',
    'DrizzleThunder': '30',
    'LightSleetThunder': '31',
    'HeavySleetThunder': '32',
    'LightSnowThunder': '33',
    'HeavySnowThunder': '34',
    'DrizzleSun': '40',
    'RainSun': '41',
    'LightSleetSun': '42',
    'HeavySleetSun': '43',
    'LightSnowSun': '44',
    'HeavysnowSun': '45',
    'Drizzle': '46',
    'LightSleet': '47',
    'HeavySleet': '48',
    'LightSnow': '49',
    'HeavySnow': '50'
}

var iconCodeByWindDirectionCode = {
    'N'  : '\uf05c',
    'NNE': '\uf05c',
    'NE' : '\uf05a',
    'ENE': '\uf059',
    'E'  : '\uf059',
    'ESE': '\uf059',
    'SE' : '\uf05d',
    'SSE': '\uf060',
    'S'  : '\uf060',
    'SSW': '\uf060',
    'SW' : '\uf05e',
    'WSW': '\uf061',
    'W'  : '\uf061',
    'WNW': '\uf061',
    'NW' : '\uf05b',
    'NNW': '\uf05c'
}

function getIconCode(iconName, byIdFlag, partOfDay) {
    print('iconName: ' + iconName)
    var iconCodeParts = null
    if (byIdFlag) {
        iconCodeParts = iconCodeById[iconName];
    } else {
        iconCodeParts = iconCodeById[iconIdByIconName[iconName]];
    }
    if (!iconCodeParts) {
        return '\uf073';
    }
    return iconCodeParts[partOfDay];
}

function getWindDirectionIconCode(code) {
    print('wind direction: ' + code)
    var iconCode = iconCodeByWindDirectionCode[code]
    if (!iconCode) {
        return '\uf073'
    }
    return iconCode
}

function getSunriseIcon() {
    return '\uf052'
}

function getSunsetIcon() {
    return '\uf051'
}

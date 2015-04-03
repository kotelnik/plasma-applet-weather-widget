var iconCodeByName = {
    'Sun': '\uf00d',
    'LightCloud': '\uf00c',
    'PartlyCloud': '\uf002',
    'Cloud': '\uf013',
    'LightRainSun': '\uf009',
    'LightRainThunderSun': '\uf00e',
    'SleetSun': '\uf006',
    'SnowSun': '\uf00a',
    'LightRain': '\uf01a',
    'Rain': '\uf019',
    'RainThunder': '\uf01e',
    'Sleet': '\uf017',
    'Snow': '\uf01b',
    'SnowThunder': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    'Fog': '\uf063',
    'SleetSunThunder': '\uf068',
    'SnowSunThunder': '\uf06b',
    'LightRainThunder': '\uf01d',
    'SleetThunder': '\uf01d', //TODO used LightRainThunder
    'DrizzleThunderSun': '\uf00b', //TODO used DrizzleSun
    'RainThunderSun': '\uf010',
    'LightSleetThunderSun': '\uf068', //TODO used SleetSunThunder
    'HeavySleetThunderSun': '\uf068', //TODO used SleetSunThunder
    'LightSnowThunderSun': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    'HeavySnowThunderSun': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    'DrizzleThunder': '\uf01c', //TODO used Drizzle
    'LightSleetThunder': '\uf01d', //TODO used LightRainThunder
    'HeavySleetThunder': '\uf01d', //TODO used LightRainThunder
    'LightSnowThunder': '\uf06b', //TODO no icon in fonts! using SnowSunThunder
    'HeavySnowThunder': '\uf06b', //TODO no icon in fonts! using SnowSunThunder
    'DrizzleSun': '\uf00b',
    'RainSun': '\uf008',
    'LightSleetSun': '\uf006', //TODO used SleetSun
    'HeavySleetSun': '\uf006', //TODO used SleetSun
    'LightSnowSun': '\uf00a', //TODO used SnowSun
    'HeavysnowSun': '\uf00a', //TODO used SnowSun
    'Drizzle': '\uf01c',
    'LightSleet': '\uf017',//TODO same as Sleet for now
    'HeavySleet': '\uf017',//TODO same as Sleet for now
    'LightSnow': '\uf01b', //TODO used Snow
    'HeavySnow': '\uf01b' //TODO used Snow
}

var iconCodeById = {
    '1': '\uf00d',
    '2': '\uf00c',
    '3': '\uf002',
    '4': '\uf013',
    '5': '\uf009',
    '6': '\uf00e',
    '7': '\uf006',
    '8': '\uf00a',
    '9': '\uf01a',
    '10': '\uf019',
    '11': '\uf01e',
    '12': '\uf017',
    '13': '\uf01b',
    '14': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    '15': '\uf063',
    '20': '\uf068',
    '21': '\uf06b',
    '22': '\uf01d',
    '23': '\uf01d', //TODO used LightRainThunder
    '24': '\uf00b', //TODO used DrizzleSun
    '25': '\uf010',
    '26': '\uf068', //TODO used SleetSunThunder
    '27': '\uf068', //TODO used SleetSunThunder
    '28': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    '29': '\uf06b',//TODO no icon in fonts! using SnowSunThunder
    '30': '\uf01c', //TODO used Drizzle
    '31': '\uf01d', //TODO used LightRainThunder
    '32': '\uf01d', //TODO used LightRainThunder
    '33': '\uf06b', //TODO no icon in fonts! using SnowSunThunder
    '34': '\uf06b', //TODO no icon in fonts! using SnowSunThunder
    '40': '\uf00b',
    '41': '\uf008',
    '42': '\uf006', //TODO used SleetSun
    '43': '\uf006', //TODO used SleetSun
    '44': '\uf00a', //TODO used SnowSun
    '45': '\uf00a', //TODO used SnowSun
    '46': '\uf01c',
    '47': '\uf017',//TODO same as Sleet for now
    '48': '\uf017',//TODO same as Sleet for now
    '49': '\uf01b', //TODO used Snow
    '50': '\uf01b' //TODO used Snow
}


function getIconCode(iconName, byIdFlag) {
    print('iconName: ' + iconName)
    var iconCode = null
    if (byIdFlag) {
        iconCode = iconCodeById[iconName];
    } else {
        iconCode = iconCodeByName[iconName];
    }
    if (!iconCode) {
        return '\uf073';
    }
    return iconCode;
}
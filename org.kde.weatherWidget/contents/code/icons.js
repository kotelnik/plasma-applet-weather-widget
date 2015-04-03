var iconCodeByName = {
    'Sun': '\uf00d',
    'Drizzle': '\uf01c',
    'LightRain': '\uf01a',
    'LightCloud': '\uf00c',
    'PartlyCloud': '\uf002',
    'Cloud': '\uf013',
    'LightRainSun': '\uf009',
    'LightRainThunderSun': '\uf00e',
    'SleetSun': '\uf006',
    'SnowSun': '\uf00a',
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
    'LightSleet': '\uf017',//TODO same as Sleet for now
    'HeavySleet': '\uf017',//TODO same as Sleet for now
    'LightSnow': '\uf01b', //TODO used Snow
    'HeavySnow': '\uf01b' //TODO used Snow
}


function getIconCode(iconName) {
    print('iconName: ' + iconName)
    var iconCode = iconCodeByName[iconName];
    if (!iconCode) {
        return '\uf073';
    }
    return iconCode;
}
/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: weatherCache
    
    property string cacheFolderPath: '~/.cache/plasma/plasmoids/org.kde.weatherWidget/'
    property string cacheFilePath: cacheFolderPath + 'plasmoidId-' + plasmoid.id + '.json'
    property string writePattern: 'mkdir -p ' + cacheFolderPath + ' && echo \'{cacheContent}\' > ' + cacheFilePath
    property string readPattern: 'cat ' + cacheFilePath
    
    property var readCacheCallback: null
    
    function writeCache(cacheContent) {
        dbgprint('writing cache with pattern: ' + writePattern)
        writeCacheExecutableDS.connectSource(writePattern.replace('{cacheContent}', cacheContent))
    }
    
    function readCache(callback) {
        if (readCacheCallback !== null) {
            dbgprint('already reading!')
            return false
        }
        readCacheCallback = callback
        readCacheExecutableDS.connectSource(readPattern)
    }
    
    PlasmaCore.DataSource {
        id: writeCacheExecutableDS
        engine: 'executable'
        onNewData: {
            disconnectSource(sourceName)
            if (data['exit code'] > 0) {
                dbgprint('error writing cache: ' + data.stderr)
                return
            }
            dbgprint('writing cache succeded')
        }
    }
    
    PlasmaCore.DataSource {
        id: readCacheExecutableDS
        engine: 'executable'
        
        onNewData: {
            var currentCallback = readCacheCallback;
            readCacheCallback = null
            
            disconnectSource(sourceName)
            
            if (currentCallback === null) {
                dbgprint('there is no callback set!')
                currentCallback = function () {}
            }
            
            if (data['exit code'] > 0) {
                dbgprint('error reading cache: ' + data.stderr)
                currentCallback('')
                return
            }
            dbgprint('reading cache succeded: ' + data.stdout)
            currentCallback(data.stdout)
        }
    }
    
}
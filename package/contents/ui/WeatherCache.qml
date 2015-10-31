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
import org.kde.private.weatherWidget 1.0 as WW

Item {
    id: weatherCache
        
    WW.Backend {
        id: cacheBackend
    }
    
    function writeCache(cacheContent) {
        dbgprint('writing cache')
        cacheBackend.writeCache(cacheContent, plasmoid.id)
        
    }
    
    function readCache() {
        dbgprint('reading cache')
        return cacheBackend.readCache(plasmoid.id)
    }
    
}
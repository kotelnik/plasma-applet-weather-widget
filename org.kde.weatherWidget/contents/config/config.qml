import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n('General')
         icon: 'preferences-system-windows'
         source: 'ConfigGeneral.qml'
    }
    ConfigCategory {
         name: i18n('Appearance')
         icon: 'preferences-desktop-color'
         source: 'ConfigAppearance.qml'
    }
}

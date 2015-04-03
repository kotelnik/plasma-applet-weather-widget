import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_compactLayout: compactLayout.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        CheckBox {
            id: compactLayout
            Layout.columnSpan: 2
            text: i18n('Vertical layout')
            enabled: false
        }
    }
    
}

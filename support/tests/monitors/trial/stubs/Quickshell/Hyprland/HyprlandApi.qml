pragma Singleton
import QtQuick
QtObject {
    property var focusedMonitor: null
    signal rawEvent(var event)
    function monitorFor(screen) { return null }
}

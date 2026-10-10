// stand-in for the Quickshell singleton, with the commands it was asked to run
pragma Singleton
import QtQuick
QtObject {
    property var screens: []
    property var ran: []
    function env(name) { return name === "HOME" ? "/nonexistent-test-home" : "" }
    function execDetached(cmd) { ran = ran.concat([cmd.join(" ")]) }
}

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs

// the Backdrop panel's background: the cover, blurred across the whole panel,
// under a scrim dark enough for the text on top. nothing without a cover
ClippingRectangle {
    id: backdrop

    property string source: ""

    color: "transparent"

    Image {
        id: art

        anchors.fill: parent
        source: backdrop.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 256
        sourceSize.height: 256
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: art
        visible: art.status === Image.Ready
        blurEnabled: true
        blur: 1
        blurMax: 64
        saturation: 0.2
    }

    Rectangle {
        anchors.fill: parent
        visible: art.status === Image.Ready
        color: Theme.alpha(Theme.bgOpaque, 0.6)
    }

}

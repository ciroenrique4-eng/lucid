import QtQuick
import qs

Column {
    id: dev

    required property var modelData
    property bool expanded: false

    readonly property string devId: dev.modelData.id
    readonly property bool reachable: dev.modelData.reachable
    readonly property bool paired: dev.modelData.paired
    readonly property bool asking: dev.modelData.pairRequestedByPeer
    readonly property bool waiting: dev.modelData.pairRequested
    readonly property bool opens: dev.paired && dev.reachable
    readonly property var battery: dev.modelData.battery
    readonly property var sig: dev.modelData.signal

    readonly property string status: {
        if (dev.asking)
            return I18n.tr("Wants to pair with this machine");

        if (dev.waiting)
            return I18n.tr("Waiting for the other device to accept…");

        if (!dev.paired)
            return I18n.tr("Nearby, not paired");

        if (!dev.reachable)
            return I18n.tr("Paired · offline");

        const via = dev.modelData.links.length > 0 ? dev.modelData.links.join(", ") : "";
        return via !== "" ? I18n.tr("Connected over %1", via) : I18n.tr("Connected");
    }

    signal opened()
    signal expandRequested()

    width: parent ? parent.width : 400

    Rectangle {
        id: head

        width: parent.width
        height: 62
        radius: Theme.radiusMd
        color: dev.expanded ? Theme.bgHover : (headArea.containsMouse ? Theme.alpha(Theme.text, Theme.stateHover) : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: Theme.durQuick
            }

        }

        Item {
            id: iconTile

            width: 40
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 11
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Theme.rad(13)
                color: Theme.alpha(dev.asking ? Theme.warning : Theme.accent, dev.reachable || dev.asking ? 0.24 : 0.11)

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durShort
                    }

                }

            }

            DeviceGlyph {
                anchors.centerIn: parent
                size: 21
                kind: Bt.glyphKind(dev.modelData.type)
                color: dev.asking ? Theme.warning : Theme.accent
            }

            Rectangle {
                width: 11
                height: 11
                radius: 5.5
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: -2
                visible: dev.opens
                color: Theme.success
                border.width: 2
                border.color: Theme.bgTile
            }

        }

        Column {
            anchors.left: iconTile.right
            anchors.leftMargin: 14
            anchors.right: trailing.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                text: dev.modelData.name
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTitle
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: dev.status
                color: dev.asking ? Theme.warning : (dev.opens ? Theme.accent : Theme.subtext)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabel
                elide: Text.ElideRight
            }

        }

        Row {
            id: trailing

            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Row {
                anchors.verticalCenter: parent.verticalCenter
                visible: dev.sig !== undefined && dev.sig.strength >= 0
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: dev.sig ? dev.sig.type : ""
                    color: Theme.subtextDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLabel
                }

                SignalBars {
                    anchors.verticalCenter: parent.verticalCenter
                    unit: 3
                    strength: dev.sig ? dev.sig.strength * 25 : 0
                }

            }

            BatteryPip {
                anchors.verticalCenter: parent.verticalCenter
                charge: dev.battery ? dev.battery.charge : -1
                charging: !!(dev.battery && dev.battery.charging)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: dev.opens ? "›" : "▾"
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fs(16)
                rotation: !dev.opens && dev.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Theme.easeStandard
                    }

                }

            }

        }

        MouseArea {
            id: headArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (dev.opens)
                    dev.opened();
                else
                    dev.expandRequested();
            }
        }

    }

    // everything a device that is not ready to open can still do
    Item {
        id: drawer

        width: parent.width
        height: !dev.opens && dev.expanded ? body.implicitHeight : 0
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.durMedium
                easing.type: Theme.easeStandard
            }

        }

        Column {
            id: body

            width: parent.width
            leftPadding: 65
            rightPadding: 14
            topPadding: 4
            bottomPadding: 16
            spacing: 12
            opacity: dev.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.durShort
                }

            }

            Text {
                width: parent.width - 79
                text: {
                    if (dev.asking)
                        return I18n.tr("Check that %1 is showing key %2, then accept.", dev.modelData.name, dev.modelData.key);

                    if (dev.waiting)
                        return I18n.tr("Accept the request on %1. Both should be showing key %2.", dev.modelData.name, dev.modelData.key);

                    if (!dev.paired)
                        return I18n.tr("Pairing asks the other device to confirm. Both will show the same key, and they must match.");

                    return I18n.tr("This device is paired but not on the network right now. Open KDE Connect on it and make sure you are both on the same Wi-Fi.");
                }
                color: Theme.subtext
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabel
                wrapMode: Text.WordWrap
            }

            Row {
                spacing: 10

                M3Button {
                    variant: "filled"
                    visible: dev.asking
                    text: I18n.tr("Accept")
                    onClicked: KdeConnect.accept(dev.devId)
                }

                M3Button {
                    variant: "filled"
                    visible: !dev.paired && !dev.asking && !dev.waiting
                    text: I18n.tr("Pair")
                    onClicked: KdeConnect.pair(dev.devId)
                }

                M3Button {
                    variant: "text"
                    destructive: true
                    visible: dev.asking || dev.waiting
                    text: dev.asking ? I18n.tr("Reject") : I18n.tr("Cancel")
                    onClicked: KdeConnect.cancel(dev.devId)
                }

                M3Button {
                    variant: "text"
                    destructive: true
                    visible: dev.paired && !dev.asking && !dev.waiting
                    text: I18n.tr("Unpair")
                    onClicked: Prefs.askConfirm(I18n.tr("Unpair %1?", dev.modelData.name), I18n.tr("This machine and that device stop trusting each other. Nothing on either is deleted, and you can pair them again whenever you like."), I18n.tr("Unpair"), "kde-unpair:" + dev.devId)
                }

            }

            Text {
                text: dev.devId
                color: Theme.subtextDim
                font.family: "monospace"
                font.features: ({
                    "liga": 0,
                    "calt": 0
                })
                font.pixelSize: Theme.fontLabel
            }

        }

    }

}

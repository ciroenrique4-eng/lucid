import QtQuick
import QtQuick.Shapes
import Quickshell.Io
import qs

// the World panel: the time here, large, then a row for each city of the set
// picked on the clock's card (Settings > Bar), with how far it is from here
Column {
    id: world

    property var now: new Date()
    property bool live: false
    readonly property var zones: Loc.zoneSets[Prefs.clockPanelZones] !== undefined ? Loc.zoneSets[Prefs.clockPanelZones] : Loc.zoneSets["eu"]
    // minutes east of UTC, one per city, filled in by the probe
    property var offsets: []

    function timeText(d) {
        const h = d.getHours();
        const hs = Prefs.clock24h ? String(h).padStart(2, "0") : String(h % 12 === 0 ? 12 : h % 12);
        return hs + ":" + String(d.getMinutes()).padStart(2, "0") + (Prefs.clock24h ? "" : " " + d.toLocaleTimeString(I18n.locale, "AP"));
    }

    function probe() {
        probeProc.running = false;
        probeProc.command = ["sh", "-c", world.zones.map((z) => {
            return "TZ=" + z.tz + " date +%z";
        }).join("; ")];
        probeProc.running = true;
    }

    spacing: 6
    onLiveChanged: {
        if (world.live)
            world.probe();

    }
    onZonesChanged: {
        if (world.live)
            world.probe();

    }

    Process {
        id: probeProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                const lines = this.text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const m = /([+-])(\d{2})(\d{2})/.exec(lines[i].trim());
                    out.push(m ? (m[1] === "-" ? -1 : 1) * (parseInt(m[2]) * 60 + parseInt(m[3])) : 0);
                }
                world.offsets = out;
            }
        }

    }

    Text {
        width: world.width
        text: world.timeText(world.now)
        color: Theme.text
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fs(40)
    }

    Text {
        width: world.width
        text: world.now.toLocaleDateString(I18n.locale, I18n.tr("dddd, MMMM d")) + (Loc.place !== "" ? " · " + Loc.place : "")
        color: Theme.subtext
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fs(12)
        elide: Text.ElideRight
    }

    Item {
        width: 1
        height: 6
    }

    Repeater {
        model: world.zones.length

        Rectangle {
            id: city

            required property int index
            readonly property var zone: world.zones[city.index]
            readonly property bool known: world.offsets.length > city.index
            readonly property var at: city.known ? Loc.timeAt(world.now, world.offsets[city.index]) : null
            readonly property bool day: city.at ? (city.at.getHours() >= 6 && city.at.getHours() < 18) : true

            width: world.width
            height: 48
            radius: Theme.rad(14)
            color: Theme.bgTile

            Shape {
                id: sky

                x: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                scale: 18 / 24
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: city.day ? Theme.accent : Theme.subtext
                    strokeWidth: 0

                    PathSvg {
                        path: city.day ? "M12 7a5 5 0 1 0 0 10 5 5 0 0 0 0-10zM11 1h2v3h-2zM11 20h2v3h-2zM1 11h3v2H1zM20 11h3v2h-3zM4.22 5.64l1.42-1.42 2.12 2.12-1.42 1.42zM16.24 17.66l1.42-1.42 2.12 2.12-1.42 1.42zM4.22 18.36l2.12-2.12 1.42 1.42-2.12 2.12zM16.24 6.34l2.12-2.12 1.42 1.42-2.12 2.12z" : "M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36a5.39 5.39 0 0 1-4.4 2.26 5.4 5.4 0 0 1-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"
                    }

                }

            }

            Column {
                anchors.left: sky.right
                anchors.leftMargin: 10
                anchors.right: clockText.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    width: parent.width
                    text: city.zone.city
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: Theme.fs(13)
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: city.known ? Loc.offsetLabel(world.offsets[city.index]) : ""
                    color: Theme.subtextDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fs(11)
                    elide: Text.ElideRight
                }

            }

            Text {
                id: clockText

                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: city.at ? world.timeText(city.at) : "–"
                color: Theme.text
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: Theme.fs(18)
            }

        }

    }

}

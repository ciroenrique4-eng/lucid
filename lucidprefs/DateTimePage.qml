import QtQuick
import qs

Column {
    id: page

    property int tick: 0

    readonly property string positionText: {
        page.tick;
        var bits = [];
        if (Loc.place !== "")
            bits.push(Loc.place);

        bits.push(Loc.coordText);
        if (Loc.fixedAt > 0)
            bits.push(I18n.tr("found %1", page.agoText(Date.now() - Loc.fixedAt)));

        return bits.join("  ·  ");
    }

    function agoText(ms) {
        var mins = Math.floor(ms / 60000);
        if (mins < 1)
            return I18n.tr("just now");

        if (mins < 60)
            return I18n.trn("%1 minute ago", "%1 minutes ago", mins);

        var hrs = Math.round(mins / 60);
        if (hrs < 24)
            return I18n.trn("%1 hour ago", "%1 hours ago", hrs);

        var days = Math.round(hrs / 24);
        return I18n.trn("%1 day ago", "%1 days ago", days);
    }

    spacing: 26

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: page.tick++
    }

    SettingCard {
        title: I18n.tr("LOCATION")

        SettingRow {
            title: I18n.tr("Auto-detect location")
            resetKey: "gpsEnabled"
            description: I18n.tr("Works out roughly where you are from your network connection, and keeps checking every few hours. This is the same switch as the GPS tile in the bar's system panel.")
            warning: Prefs.gpsEnabled ? I18n.tr("Your address is sent to ipapi.co to be turned into a position.") : ""

            M3Switch {
                checked: Prefs.gpsEnabled
                onToggled: (v) => {
                    return Prefs.gpsEnabled = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Place")
            enabled: !Prefs.gpsEnabled
            disabledReason: I18n.tr("Auto-detect is choosing the place for you. Turn it off to name one yourself.")
            description: I18n.tr("A town or city to sit the shell in. Press Enter to look it up.")

            M3TextField {
                width: 260
                enabled: !Prefs.gpsEnabled
                placeholder: I18n.tr("Poznań")
                text: Prefs.locationName
                onAccepted: (v) => {
                    Prefs.locationName = v;
                    Loc.lookup(v);
                }
            }

        }

        SettingRow {
            title: I18n.tr("Position")
            description: page.positionText
            warning: Loc.lastError
            showDivider: false

            M3Button {
                text: Loc.busy ? I18n.tr("Looking…") : (Prefs.gpsEnabled ? I18n.tr("Detect now") : I18n.tr("Look up"))
                variant: "tonal"
                enabled: !Loc.busy
                onClicked: Loc.refresh()
            }

        }

    }

    SettingCard {
        title: I18n.tr("TIME ZONE")

        SettingRow {
            title: I18n.tr("Time zone")
            description: I18n.tr("The machine's own zone, shared with every application on it. Changing it here is the same as running timedatectl, so it asks for your password.")
            warning: Loc.zoneError !== "" ? I18n.tr("Unchanged — %1", Loc.zoneError) : ""

            Row {
                spacing: 14

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: Loc.zone !== "" ? Loc.zone.replace(/_/g, " ") : I18n.tr("Reading…")
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTitle
                        font.bold: true
                    }

                    Text {
                        text: Loc.offsetText
                        color: Theme.subtextDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLabel
                    }

                }

                M3Button {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Loc.zoneBusy ? I18n.tr("Setting…") : I18n.tr("Change…")
                    variant: "tonal"
                    enabled: !Loc.zoneBusy
                    onClicked: Prefs.timeZonePickerRequested()
                }

            }

        }

        SettingRow {
            title: I18n.tr("Set it from my location")
            resetKey: "timeZoneAuto"
            description: {
                if (Loc.zoneFromLocation === "")
                    return I18n.tr("Your location has not named a zone yet. Find a place above and the machine can follow it.");

                if (Loc.locationAgrees)
                    return I18n.tr("The machine already keeps the time of %1.", Loc.zoneFromLocation.replace(/_/g, " "));

                return I18n.tr("Your location sits in %1, which the machine is not on.", Loc.zoneFromLocation.replace(/_/g, " "));
            }
            showDivider: Loc.stale

            M3Switch {
                checked: Prefs.timeZoneAuto
                onToggled: (v) => {
                    return Prefs.timeZoneAuto = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Applications opened before the change")
            visible: Loc.stale
            description: {
                page.tick;
                return I18n.tr("A program reads the time zone once, when it starts, so anything already running is still on the old one. Lucid corrects for that itself and shows %1 either way — restart the others, or log out, to bring them across.", Loc.now().toLocaleTimeString(I18n.locale, "HH:mm"));
            }
            showDivider: false
        }

    }

    SettingCard {
        title: I18n.tr("CLOCK")

        SettingRow {
            title: I18n.tr("24-hour time")
            resetKey: "clock24h"
            description: I18n.tr("Show 14:30 instead of 02:30 PM.")

            M3Switch {
                checked: Prefs.clock24h
                onToggled: (v) => {
                    return Prefs.clock24h = v;
                }
            }

        }

        SettingRow {
            title: I18n.tr("Show date")
            resetKey: "clockShowDate"
            description: I18n.tr("Keep the weekday and day-of-month beside the time in the bar.")
            showDivider: false

            M3Switch {
                checked: Prefs.clockShowDate
                onToggled: (v) => {
                    return Prefs.clockShowDate = v;
                }
            }

        }

    }

}

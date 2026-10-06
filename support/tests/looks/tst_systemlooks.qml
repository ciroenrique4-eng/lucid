import QtQuick
import QtTest
import "../../../lucidbar/SystemLooks.js" as Looks

TestCase {
    name: "SystemLooks"

    function test_face_known_styles() {
        compare(Looks.face("values", true), "values");
        compare(Looks.face("icons", true), "icons");
        compare(Looks.face("rings", true), "rings");
        compare(Looks.face("accent", true), "accent");
        compare(Looks.face("battery", true), "battery");
    }

    function test_face_battery_without_battery_is_icons() {
        compare(Looks.face("battery", false), "icons");
    }

    function test_face_unknown_is_values() {
        compare(Looks.face("bogus", true), "values");
        compare(Looks.face("", true), "values");
    }

    function test_level_wifi() {
        compare(Looks.level("wifi", { connected: true, strength: 70 }), 0.7);
        compare(Looks.level("wifi", { connected: false, strength: 70 }), 0);
        compare(Looks.level("wifi", { connected: true, strength: 140 }), 1);
    }

    function test_level_volume() {
        compare(Looks.level("volume", { muted: false, percent: 55 }), 0.55);
        compare(Looks.level("volume", { muted: true, percent: 55 }), 0);
        compare(Looks.level("volume", { muted: false, percent: 150 }), 1);
    }

    function test_level_mic() {
        compare(Looks.level("mic", { muted: false }), 1);
        compare(Looks.level("mic", { muted: true }), 0);
    }

    function test_level_battery() {
        compare(Looks.level("battery", { percent: 8 }), 0.08);
    }
}

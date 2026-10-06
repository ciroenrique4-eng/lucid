import QtQuick
import QtTest
import "../../../lucidbar/MediaLooks.js" as Looks

TestCase {
    name: "MediaLooks"

    function test_face() {
        compare(Looks.face("playing"), "playing");
        compare(Looks.face("progress"), "progress");
        compare(Looks.face("ring"), "ring");
        compare(Looks.face("controls"), "controls");
        compare(Looks.face("nonsense"), "playing");
    }

    function test_fill_is_empty_without_progress() {
        compare(Looks.fillWidth(200, 0, 20), 0);
        compare(Looks.fillWidth(200, -0.3, 20), 0);
    }

    function test_fill_never_thinner_than_its_height() {
        compare(Looks.fillWidth(200, 0.01, 20), 20);
    }

    function test_fill_follows_progress() {
        compare(Looks.fillWidth(200, 0.5, 20), 100);
        compare(Looks.fillWidth(200, 1.4, 20), 200);
    }

    function test_vinyl_spins_only_open_and_playing() {
        compare(Looks.spinning(true, true), true);
        compare(Looks.spinning(true, false), false);
        compare(Looks.spinning(false, true), false);
    }
}

import QtQuick
import QtTest
import "../../../lucidbar/WindowLooks.js" as Looks

TestCase {
    name: "WindowLooks"

    function test_no_marks_for_a_plain_window() {
        compare(Looks.marks({ floating: false, pinned: false, fullscreen: 0 }), []);
        compare(Looks.marks({}), []);
        compare(Looks.marks(null), []);
    }

    function test_marks_in_order() {
        compare(Looks.marks({ floating: true, pinned: true, fullscreen: 2 }), ["floating", "pinned", "fullscreen"]);
        compare(Looks.marks({ floating: false, pinned: false, fullscreen: 1 }), ["fullscreen"]);
        compare(Looks.marks({ floating: true }), ["floating"]);
    }

    function test_stacked_lines() {
        compare(Looks.stackedLines("Inbox — Mail", "Thunderbird"), ["Inbox — Mail", "Thunderbird"]);
        compare(Looks.stackedLines("", "Thunderbird"), ["Thunderbird", ""]);
        compare(Looks.stackedLines("Thunderbird", "Thunderbird"), ["Thunderbird", ""]);
    }

    function test_refresh_on_state_events_and_new_windows() {
        compare(Looks.refreshOn("changefloatingmode"), true);
        compare(Looks.refreshOn("pin"), true);
        compare(Looks.refreshOn("fullscreen"), true);
        compare(Looks.refreshOn("openwindow"), true);
        compare(Looks.refreshOn("activewindowv2"), true);
        compare(Looks.refreshOn("workspace"), false);
    }

    function test_tile_caption() {
        compare(Looks.tileCaption("Inbox — Mail", "Thunderbird"), "Inbox — Mail");
        compare(Looks.tileCaption("", "Thunderbird"), "Thunderbird");
    }
}

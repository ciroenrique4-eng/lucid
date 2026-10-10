import QtQuick
import QtTest
import qs
import "../../../lucidprefs"

Item {
    width: 760; height: 600
    Item { id: other; focus: true; anchors.fill: parent; Keys.onPressed: (e) => {
            // like Settings' own: printable keys open the search, Escape closes
            if (e.key === Qt.Key_Escape || (e.text.length === 1 && e.text.charCodeAt(0) > 32)) {
                typed = typed.concat([e.key]); e.accepted = true
            }
        } }
    MonitorMap { id: m; width: 700; onPicked: (k) => { last = k; selected = k } property string last: "" }

    SignalSpy { id: picks; target: m; signalName: "picked" }
    SignalSpy { id: opens; target: m; signalName: "opened" }
    // what reaches the item that had the keyboard before the map took it
    property var typed: []
    Keys.forwardTo: []

    TestCase {
        name: "MonitorMap"; when: windowShown

        function plate(k) {
            const f = m.children[0];
            for (let i = 0; i < f.children.length; i++)
                if (f.children[i].modelData === k) return f.children[i];
            return null;
        }
        function init() { Monitors.reset(); picks.clear(); opens.clear(); typed = []; m.selected = ""; other.forceActiveFocus(); mouseMove(m, 5, 5); wait(300) }

        function test_drag_keeps_box_under_pointer_and_view_still() {
            const p = plate("B");
            const fit0 = m.fit, h0 = m.height;
            const sx = p.x + p.width / 2, sy = p.y + p.height / 2;
            mousePress(m, sx, sy);
            for (let i = 1; i <= 20; i++) {
                mouseMove(m, sx + i * 10, sy + i * 6);
                // box follows the pointer exactly (no clamping this close)
                fuzzyCompare(p.x + p.width / 2, sx + i * 10, 0.6);
                fuzzyCompare(p.y + p.height / 2, sy + i * 6, 0.6);
            }
            compare(m.fit, fit0); compare(m.height, h0);
            compare(Monitors.placeCalls, 0);           // nothing applied mid-drag
            mouseRelease(m, sx + 200, sy + 120);
            compare(Monitors.placeCalls, 1);
            const a = Monitors.placed.A, b = Monitors.placed.B;
            // touching, not stacked, corner at 0,0
            verify(b.x === a.x + 1920 || b.y === a.y + 1080, JSON.stringify(Monitors.placed));
            compare(Math.min(a.x, b.x), 0); compare(Math.min(a.y, b.y), 0);
            compare(picks.count, 0);
        }

        function test_drop_on_top_does_not_stack() {
            const a = plate("A"), b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;
            mousePress(m, sx, sy);
            for (let i = 1; i <= 10; i++) mouseMove(m, sx - (sx - (a.x + a.width / 2)) * i / 10, sy);
            mouseRelease(m, a.x + a.width / 2, sy);
            const pa = Monitors.placed.A, pb = Monitors.placed.B;
            verify(pb.x >= pa.x + 1920 || pb.x + 1920 <= pa.x || pb.y >= pa.y + 1080 || pb.y + 1080 <= pa.y, JSON.stringify(Monitors.placed));
        }

        function test_far_diagonal_leaves_no_gap() {
            const b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;
            mousePress(m, sx, sy);
            for (let i = 1; i <= 10; i++) mouseMove(m, sx + i * 6, sy + i * 8);
            mouseRelease(m, sx + 60, sy + 80);
            const pa = Monitors.placed.A, pb = Monitors.placed.B;
            compare(pb.x, pa.x + 1920);                 // still against the edge
            verify(pb.y < pa.y + 1080 && pb.y + 1080 > pa.y);
        }

        function test_escape_cancels() {
            const b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;
            mousePress(m, sx, sy);
            for (let i = 1; i <= 5; i++) mouseMove(m, sx + i * 20, sy + i * 20);
            verify(m.dragging, "dragging");
            keyClick(Qt.Key_Escape);
            verify(!m.dragging, "not dragging");
            verify(other.activeFocus, "focus back");                  // keyboard handed back
            mouseRelease(m, sx + 100, sy + 100);
            compare(Monitors.placeCalls, 0); compare(picks.count, 0);
        }

        function test_click_is_a_pick() {
            const b = plate("B");
            mouseClick(m, b.x + b.width / 2 + 1, b.y + b.height / 2 + 1);
            compare(picks.count, 1); compare(m.last, "B"); compare(Monitors.placeCalls, 0);
        }

        function test_tiny_jitter_is_still_a_pick() {
            const b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;
            mousePress(m, sx, sy); mouseMove(m, sx + 2, sy + 1); mouseRelease(m, sx + 2, sy + 1);
            compare(picks.count, 1); compare(Monitors.placeCalls, 0);
        }

        function test_drop_where_it_started_changes_nothing() {
            const b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;

            mousePress(m, sx, sy); mouseMove(m, sx + 20, sy); mouseMove(m, sx + 2, sy); mouseRelease(m, sx, sy);
            compare(Monitors.placeCalls, 0);
        }

        function test_put_below() {
            const a = plate("A"), b = plate("B");
            const sx = b.x + b.width / 2, sy = b.y + b.height / 2;
            const tx = a.x + a.width / 2, ty = a.y + a.height * 1.5;
            mousePress(m, sx, sy);
            for (let i = 1; i <= 20; i++) mouseMove(m, sx + (tx - sx) * i / 20, sy + (ty - sy) * i / 20);
            mouseRelease(m, tx, ty);
            compare(JSON.stringify(Monitors.placed), JSON.stringify({ "A": { "x": 0, "y": 0 }, "B": { "x": 0, "y": 1080 } }));
        }

        function test_escape_without_drag_is_not_taken() {
            verify(!m.activeFocus);
        }

        function centre(k) { const p = plate(k); return [p.x + p.width / 2, p.y + p.height / 2] }

        function test_double_click_opens() {
            const c = centre("B");
            mouseDoubleClickSequence(m, c[0], c[1]);
            compare(opens.count, 1);
            compare(Monitors.placeCalls, 0);
        }

        function test_click_takes_the_keys_and_passes_the_rest_on() {
            const c = centre("B");
            mouseClick(m, c[0], c[1]);
            verify(m.activeFocus);
            keyClick(Qt.Key_S);
            compare(typed, [Qt.Key_S]);
            keyClick(Qt.Key_Escape);                    // not moving: the window's
            compare(typed, [Qt.Key_S, Qt.Key_Escape]);
        }

        function test_arrows_move_round_and_enter_applies() {
            const c = centre("B");
            mouseClick(m, c[0], c[1]);
            keyClick(Qt.Key_Left); keyClick(Qt.Key_Left);
            verify(m.dragging && m.byKeys);
            compare(Monitors.placeCalls, 0);
            compare(m.landPos, Qt.point(0, -1080));    // over the laptop
            keyClick(Qt.Key_Left);
            compare(m.landPos, Qt.point(-1920, 0));    // round to its left
            keyClick(Qt.Key_Return);
            compare(Monitors.placeCalls, 1);
            compare(JSON.stringify(Monitors.placed), JSON.stringify({ "A": { "x": 1920, "y": 0 }, "B": { "x": 0, "y": 0 } }));
            verify(m.activeFocus);                      // ready for another move
            compare(typed, []);
        }

        function test_shift_arrow_slides_along_the_edge() {
            const c = centre("B");
            mouseClick(m, c[0], c[1]);
            keyClick(Qt.Key_Down, Qt.ShiftModifier);
            compare(m.landPos, Qt.point(1920, 54));
            keyClick(Qt.Key_Escape);
            verify(!m.dragging);
            compare(Monitors.placeCalls, 0);
            compare(typed, []);                         // Escape mid-move is the map's
        }

        function test_pointing_shows_the_real_display() {
            const c = centre("B");
            mouseMove(m, c[0], c[1]);
            compare(Monitors.pointedAt, "");            // not straight away
            tryCompare(Monitors, "pointedAt", "B", 1000);
            mouseMove(m, 3, 3);
            compare(Monitors.pointedAt, "");
        }

        function test_off_and_mirrored_are_left_out() {
            Monitors.offKeys = ["B"];
            wait(50);
            verify(!plate("B").visible);
            verify(!m.movable);
            Monitors.offKeys = [];
            Monitors.mirrors = { "B": "eDP-1" };
            wait(50);
            verify(!plate("B").visible);
            Monitors.mirrors = {};
            wait(50);
            verify(plate("B").visible);
        }

        function test_names_on_the_boxes() {
            const p = plate("A");
            let found = false;
            const walk = (it) => { for (let i = 0; i < it.children.length; i++) { const c = it.children[i]; if (c.text === "Built-in") found = true; walk(c); } };
            walk(p);
            verify(found);
        }
    }
}

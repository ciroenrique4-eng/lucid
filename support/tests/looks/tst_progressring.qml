import QtQuick
import QtTest
import "../../../lucidbar"

TestCase {
    name: "ProgressRing"

    ProgressRing {
        id: ring

        duration: 0
    }

    function test_sweep_follows_value() {
        ring.value = 0.25;
        compare(ring.sweep, 90);
    }

    function test_sweep_clamps_below() {
        ring.value = -1;
        compare(ring.sweep, 0);
    }

    function test_sweep_clamps_above() {
        ring.value = 2;
        compare(ring.sweep, 360);
    }

    function test_no_arc_at_zero() {
        ring.value = 0;
        compare(ring.arcVisible, false);
        ring.value = 0.5;
        compare(ring.arcVisible, true);
    }

    ProgressRing {
        id: holder

        width: 30
        height: 30

        Rectangle {
            id: inner

            width: 10
            height: 10
        }

    }

    function test_children_centred() {
        compare(inner.mapToItem(holder, 0, 0).x, 10);
        compare(inner.mapToItem(holder, 0, 0).y, 10);
    }
}

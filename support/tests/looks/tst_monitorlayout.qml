import QtQuick
import QtTest
import "../../../lucidprefs/MonitorLayout.js" as L

TestCase {
    name: "MonitorLayout"

    readonly property var fhd: ({ "w": 1920, "h": 1080 })
    readonly property var laptop: ({ "x": 0, "y": 0, "w": 1920, "h": 1080 })

    function test_alone_goes_where_it_is_put() {
        compare(L.land(fhd, { "x": 300.4, "y": -20 }, [], 60), { "x": 300, "y": -20 });
    }

    function test_near_the_right_edge_lands_on_it() {
        compare(L.land(fhd, { "x": 1950, "y": 30 }, [laptop], 60), { "x": 1920, "y": 0 });
    }

    function test_far_away_still_lands_touching() {
        // dropped off to the right and below: no gap left behind
        compare(L.land(fhd, { "x": 2500, "y": 900 }, [laptop], 60), { "x": 1920, "y": 864 });
    }

    function test_dropped_on_top_never_stacks() {
        const r = L.land(fhd, { "x": 0, "y": 0 }, [laptop], 60);
        verify(r !== null);
        verify(!L.overlaps({ "x": r.x, "y": r.y, "w": 1920, "h": 1080 }, laptop));
    }

    function test_mostly_on_top_goes_out_the_nearest_side() {
        compare(L.land(fhd, { "x": 1500, "y": 0 }, [laptop], 60), { "x": 1920, "y": 0 });
        compare(L.land(fhd, { "x": 0, "y": -900 }, [laptop], 60), { "x": 0, "y": -1080 });
    }

    function test_a_corner_alone_is_not_enough() {
        // the pointer could not get across a single shared point
        const r = L.land(fhd, { "x": 1920, "y": 1080 }, [laptop], 60);
        verify(r.y <= 1080 - 216 || r.x <= 1920 - 384);
    }

    function test_lines_up_middles() {
        const small = { "w": 1280, "h": 720 };
        compare(L.land(small, { "x": 1920, "y": 200 }, [laptop], 60), { "x": 1920, "y": 180 });
    }

    function test_lines_up_bottoms() {
        const small = { "w": 1280, "h": 720 };
        compare(L.land(small, { "x": 1920, "y": 340 }, [laptop], 60), { "x": 1920, "y": 360 });
    }

    function test_out_of_reach_stays_where_dropped() {
        compare(L.land(fhd, { "x": 1920, "y": 400 }, [laptop], 60), { "x": 1920, "y": 400 });
    }

    function test_between_two_takes_the_free_side() {
        const right = { "x": 1920, "y": 0, "w": 1920, "h": 1080 };
        const r = L.land(fhd, { "x": 1000, "y": 100 }, [laptop, right], 60);
        verify(r !== null);
        verify(!L.overlaps({ "x": r.x, "y": r.y, "w": 1920, "h": 1080 }, laptop));
        verify(!L.overlaps({ "x": r.x, "y": r.y, "w": 1920, "h": 1080 }, right));
        compare(r.y, 1080);
    }

    function test_normalise_moves_the_corner_to_zero() {
        compare(L.normalise({ "a": { "x": -1920, "y": 0 }, "b": { "x": 0, "y": 120 } }),
                { "a": { "x": 0, "y": 0 }, "b": { "x": 1920, "y": 120 } });
    }

    function test_normalise_nothing() {
        compare(L.normalise({}), {});
    }
}

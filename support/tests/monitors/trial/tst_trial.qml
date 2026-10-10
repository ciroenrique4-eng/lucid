import QtQuick
import QtTest
import qs

TestCase {
    name: "MonitorsTrial"

    function init() {
        Monitors.keepTrial();
        Prefs.monitorSetups = JSON.stringify({ "B": { "x": 1920, "y": 0 } });
        Monitors.outputs = [
            { "key": "A", "name": "eDP-1", "make": "", "model": "", "description": "LG Display 0x0738", "width": 1920, "height": 1080, "refresh": 120, "x": 0, "y": 0, "scale": 1, "transform": 0, "vrr": false, "disabled": false, "focused": true, "mirrorOf": "", "modes": [] },
            { "key": "B", "name": "HDMI-A-1", "make": "LG Electronics", "model": "M2262D", "description": "LG Electronics M2262D", "width": 1920, "height": 1080, "refresh": 60, "x": 1920, "y": 0, "scale": 1, "transform": 0, "vrr": false, "disabled": false, "focused": false, "mirrorOf": "", "modes": [] }
        ];
    }

    function setups() { return JSON.parse(Prefs.monitorSetups) }

    function test_a_change_goes_on_trial() {
        Monitors.setTransform("B", 1);
        verify(Monitors.onTrial);
        compare(Monitors.trialLeft, 15);
        compare(setups().B.transform, 1);
    }

    function test_keep_keeps_it() {
        Monitors.setScale("B", 1.25);
        Monitors.keepTrial();
        verify(!Monitors.onTrial);
        compare(setups().B.scale, 1.25);
    }

    function test_go_back_restores_only_what_it_touched() {
        Monitors.setTransform("B", 1);
        Monitors.setScale("A", 1.5);
        // a drag in the meantime is not part of the trial
        Monitors.place({ "A": { "x": 0, "y": 0 }, "B": { "x": 0, "y": 1080 } });
        Monitors.revertTrial();
        verify(!Monitors.onTrial);
        const s = setups();
        compare(s.B.transform, undefined);
        compare(s.A.scale, undefined);
        compare(s.B.y, 1080);
        compare(s.A.x, 0);
    }

    function test_runs_out_by_itself() {
        Monitors.setTransform("B", 3);
        Monitors.trialLeft = 2;
        tryCompare(Monitors, "onTrial", false, 3500);
        compare(setups().B.transform, undefined);
        compare(setups().B.x, 1920);
    }

    function test_picking_the_old_value_again_ends_it() {
        Monitors.setTransform("B", 1);
        verify(Monitors.onTrial);
        Monitors.setTransform("B", 0);
        // 0 was never set, so it is a change to an explicit 0 — still on trial
        verify(Monitors.onTrial);
        Monitors.revertTrial();
        compare(setups().B.transform, undefined);
    }

    function test_second_change_restarts_the_clock_and_keeps_the_first_undo() {
        Monitors.setScale("B", 1.25);
        Monitors.trialLeft = 3;
        Monitors.setScale("B", 1.5);
        compare(Monitors.trialLeft, 15);
        Monitors.revertTrial();
        compare(setups().B.scale, undefined);
    }

    function test_mirror_goes_back_to_its_place() {
        Monitors.setMirror("B", "eDP-1");
        compare(setups().B.mirror, "eDP-1");
        compare(setups().B.x, undefined);
        Monitors.revertTrial();
        compare(setups().B.mirror, undefined);
        compare(setups().B.x, 1920);
        compare(setups().B.y, 0);
    }

    function test_names() {
        compare(Monitors.shortLabel("A"), "Built-in");
        compare(Monitors.shortLabel("B"), "LG Electronics M2262D");
        verify(Monitors.isBuiltIn("A"));
        verify(!Monitors.isBuiltIn("B"));
    }
}

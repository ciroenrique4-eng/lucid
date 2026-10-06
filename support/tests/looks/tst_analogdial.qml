import QtQuick
import QtTest
import "../../../lucidbar"

TestCase {
    name: "AnalogDial"

    AnalogDial {
        id: dial

        width: 24
        height: 24
    }

    function test_hand_angles() {
        dial.date = new Date(2026, 9, 5, 15, 30, 20);
        compare(dial.hourAngle, 105);
        compare(dial.minuteAngle, 182);
        compare(dial.secondAngle, 120);
    }

    function test_midnight_and_noon_point_up() {
        dial.date = new Date(2026, 9, 5, 0, 0, 0);
        compare(dial.hourAngle, 0);
        dial.date = new Date(2026, 9, 5, 12, 0, 0);
        compare(dial.hourAngle, 0);
    }

    function test_simple_face_has_four_marks() {
        dial.detail = false;
        compare(dial.marks, 4);
        dial.detail = true;
        compare(dial.marks, 12);
    }
}

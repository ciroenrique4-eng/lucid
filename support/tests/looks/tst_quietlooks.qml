import QtQuick
import QtTest
import "../../../lucidbar/QuietLooks.js" as Looks

TestCase {
    name: "QuietLooks"

    function test_chip_text() {
        compare(Looks.chipText("Microphone", ["Discord"]), "Microphone · Discord");
        compare(Looks.chipText("Microphone", ["Discord", "Zen"]), "Microphone · Discord +1");
        compare(Looks.chipText("Microphone", []), "Microphone");
    }

    function test_os_logo() {
        compare(Looks.osLogo('NAME="Arch Linux"\nLOGO=archlinux-logo\n'), "archlinux-logo");
        compare(Looks.osLogo('LOGO="fedora-logo-icon"\nID=fedora'), "fedora-logo-icon");
        compare(Looks.osLogo('NAME=Something'), "");
        compare(Looks.osLogo(""), "");
    }

    function test_stack_spacing() {
        compare(Looks.stackSpacing(30, false, 4), -14);
        compare(Looks.stackSpacing(30, true, 4), 4);
    }
}

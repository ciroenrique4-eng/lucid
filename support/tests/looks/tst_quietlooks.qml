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

    function test_chip_parts_keep_the_count_apart() {
        const p = Looks.chipParts("Screen", ["Lucid's recording", "OBS Studio"]);
        compare(p.head, "Screen · ");
        compare(p.app, "Lucid's recording");
        compare(p.more, "+1");
        const q = Looks.chipParts("Microphone", []);
        compare(q.head, "Microphone");
        compare(q.app, "");
        compare(q.more, "");
    }
}

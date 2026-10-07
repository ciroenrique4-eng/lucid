import QtQuick
import QtTest
import "../../../lucidprefs/WallTransitions.js" as WT

TestCase {
    name: "WallTransitions"

    readonly property var plain: ({
        "type": "fade",
        "duration": 1,
        "angle": 45,
        "origin": "center",
        "bezier": ".54,0,.34,.99",
        "wave": "20,20"
    })

    function test_builtin_ids() {
        compare(WT.builtIn.map(p => p.id).join(","), "suave,circulo,barrido,ola,instantaneo,aleatorio");
    }

    function test_builtin_suave_is_todays_fade() {
        const p = WT.builtIn[0];
        compare(p.type, "fade");
        compare(p.duration, 1);
    }

    function test_circulo_is_grow() {
        compare(WT.presetById("circulo", "").type, "grow");
    }

    function test_conf_text_defaults() {
        compare(WT.confText(plain), "TYPE=fade\nDURATION=1\nANGLE=45\nORIGIN=center\nBEZIER=.54,0,.34,.99\nWAVE=20,20\n");
    }

    function test_conf_text_drops_values_with_newlines() {
        const v = Object.assign({}, plain, {"type": "fade\nTYPE=grow"});
        compare(WT.confText(v).indexOf("grow"), -1);
        compare(WT.confText(v).indexOf("TYPE=fade\n"), 0);
    }

    function test_corrupt_custom_json_keeps_builtins() {
        compare(WT.presets("{not json").length, 6);
        compare(WT.presets("").length, 6);
        compare(WT.presets("[1, null, {\"id\": 3}]").length, 6);
    }

    function test_custom_presets_roundtrip() {
        const json = WT.addCustom("", "Mi barrido", Object.assign({}, plain, {"type": "wipe"}));
        const all = WT.presets(json);
        compare(all.length, 7);
        compare(all[6].name, "Mi barrido");
        compare(all[6].type, "wipe");
        compare(all[6].custom, true);
        compare(WT.presets(WT.removeCustom(json, all[6].id)).length, 6);
    }

    function test_matches_finds_the_preset_whose_values_equal_the_prefs() {
        compare(WT.matchingId(WT.builtIn[1], ""), "circulo");
        compare(WT.matchingId(Object.assign({}, WT.builtIn[1], {"duration": 9}), ""), "custom");
    }
}

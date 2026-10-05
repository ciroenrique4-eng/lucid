import QtQuick
import Quickshell
import Quickshell.Io
import "I18nCore.js" as Core
pragma Singleton

// what every label goes through. the catalogues are i18n/<code>.json keyed by
// the English text, and English itself has none: it is the text in the code.
// tr() reads `strings`, so any binding that calls it is redone when the
// language changes or the file is edited, with no restart
Singleton {
    id: root

    readonly property string envCode: Core.envLocale(Quickshell.env("LC_ALL") || "", Quickshell.env("LC_MESSAGES") || "", Quickshell.env("LANG") || "")
    readonly property string pref: Prefs.language || "auto"
    // [{ code, name, locale }] read from the catalogues' _meta, English first
    property var catalogues: []
    readonly property var available: root.catalogues.map((c) => {
        return c.code;
    })
    readonly property string language: Core.resolve(root.pref, root.envCode, root.available)
    readonly property var languages: [{
        "code": "en",
        "name": "English"
    }].concat(root.catalogues.map((c) => {
        return {
            "code": c.code,
            "name": c.name
        };
    }))
    readonly property string autoName: root.nameOf(Core.resolve("auto", root.envCode, root.available))
    property var strings: ({})
    property var meta: ({})
    // the environment's own region when it speaks the same language (es_MX for
    // es, picked or automatic), else the catalogue's; dates and numbers follow it
    readonly property var locale: Qt.locale(root.envCode !== "" && root.envCode.split("_")[0] === root.language.split("_")[0] ? root.envCode : (root.language === "en" ? "en_US" : (root.meta.locale || root.language)))

    function tr(text, ...args) {
        return Core.tr(root.strings, text, args);
    }

    function trc(ctx, text, ...args) {
        return Core.trc(root.strings, ctx, text, args);
    }

    function trn(singular, plural, n, ...args) {
        return Core.trn(root.strings, singular, plural, n, args);
    }

    function nameOf(code) {
        var l = root.languages.find((x) => {
            return x.code === code;
        });
        return l ? l.name : code;
    }

    onLanguageChanged: {
        if (root.language === "en") {
            root.strings = {};
            root.meta = {};
        }
    }

    Process {
        id: scan

        running: true
        command: ["python3", "-c", "import json,glob,os,sys\nout=[]\nfor f in sorted(glob.glob(os.path.join(sys.argv[1],'*.json'))):\n    try: m=json.load(open(f,encoding='utf-8')).get('_meta',{})\n    except Exception: continue\n    c=os.path.basename(f)[:-5]\n    out.append({'code':c,'name':m.get('name',c),'locale':m.get('locale',c)})\nprint(json.dumps(out))", Quickshell.shellPath("i18n")]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.catalogues = JSON.parse(this.text);
                } catch (e) {
                    console.warn("i18n: could not list the catalogues: " + e);
                }
            }
        }

    }

    FileView {
        path: root.language === "en" ? "" : Quickshell.shellPath("i18n/" + root.language + ".json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                var d = JSON.parse(text());
                root.meta = d._meta || {};
                delete d._meta;
                root.strings = d;
            } catch (e) {
                // a half-written or broken file keeps what was there
                console.warn("i18n: " + path + ": " + e);
            }
        }
    }

}

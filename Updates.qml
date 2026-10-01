import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// asks github once a day whether a newer CirOShell release is out, and says so
// once per version. a release is tagged v<lucid version>-ciro.<revision>, e.g.
// v1.10.5-ciro.1. it also looks at upstream Lucid, only to say when it moved.
// off switch: Prefs.updateCheck
Singleton {
    id: root

    readonly property string repo: "ciroenrique4-eng/lucid"
    readonly property string upstreamRepo: "Sn3akyy1/lucid"
    readonly property string releasesUrl: "https://github.com/" + root.repo + "/releases"
    readonly property string upstreamUrl: "https://github.com/" + root.upstreamRepo + "/releases"
    readonly property int everyMs: 86400000 // test-marker

    // the installer copies a VERSION file in beside shell.qml
    // VERSION is the Lucid release this is built on, FORK the CirOShell revision on top of it
    property string base: ""
    property string rev: ""
    readonly property string current: root.base === "" ? "" : root.base + (root.rev !== "" && root.rev !== "0" ? "-ciro." + root.rev : "")
    property string upstreamLatest: ""
    property string upstreamUrlLatest: root.upstreamUrl
    property string latest: ""
    property string latestName: ""
    property string latestUrl: root.releasesUrl
    // the version already announced, so an ignored update stays quiet
    property string notified: ""
    property real checkedAt: 0
    property bool busy: false
    // "" | "offline" | "ratelimited" | "norelease" | "unreadable"
    property string problem: ""
    property bool gotResponse: false

    readonly property string currentLabel: root.current === "" ? "unknown" : "v" + root.current
    readonly property bool available: root.current !== "" && root.latest !== "" && root.isNewer(root.latest, root.current)
    // upstream Lucid is ahead of the version this is built on
    readonly property bool upstreamAhead: root.base !== "" && root.upstreamLatest !== "" && root.isNewer(root.upstreamLatest, root.base)
    readonly property bool wanted: Prefs.loaded && Prefs.updateCheck && root.current !== ""

    function revision(v) {
        var m = /-ciro\.(\d+)/i.exec(String(v));
        return m ? parseInt(m[1], 10) : 0;
    }

    function numbers(v) {
        return String(v).trim().replace(/^v/i, "").split("-")[0].split(".").map((n) => {
            return parseInt(n, 10) || 0;
        });
    }

    function isNewer(a, b) {
        var x = root.numbers(a);
        var y = root.numbers(b);
        for (var i = 0; i < Math.max(x.length, y.length); i++) {
            var d = (x[i] || 0) - (y[i] || 0);
            if (d !== 0)
                return d > 0;

        }
        return root.revision(a) > root.revision(b);
    }

    function ago(ts) {
        var m = Math.max(0, Math.round((Date.now() - ts) / 60000));
        if (m < 2)
            return "just now";

        if (m < 60)
            return m + " minutes ago";

        var h = Math.round(m / 60);
        if (h < 24)
            return h === 1 ? "an hour ago" : h + " hours ago";

        var d = Math.round(h / 24);
        return d === 1 ? "yesterday" : d + " days ago";
    }

    readonly property string status: {
        if (root.current === "")
            return "CirOShell cannot tell which version it is — there is no VERSION file beside shell.qml.";

        if (root.busy)
            return "Asking GitHub…";

        if (root.problem === "offline")
            return "Could not reach GitHub. CirOShell tries again later.";

        if (root.problem === "ratelimited")
            return "GitHub is rate-limiting this address. CirOShell tries again later.";

        if (root.problem === "norelease")
            return "No release has been published yet.";

        if (root.problem === "unreadable")
            return "GitHub answered with something CirOShell could not read.";

        if (root.available)
            return (root.latestName !== "" ? root.latestName + ". " : "") + "Pull the integrated branch and run ./install.sh to update.";

        // a saved timestamp outlives the reason for it, so an empty latest after
        // a real check means nothing is published rather than up to date
        if (root.checkedAt > 0 && root.latest === "")
            return "No release has been published yet.";

        if (root.checkedAt > 0)
            return "Up to date — checked " + root.ago(root.checkedAt) + ".";

        return Prefs.updateCheck ? "Not checked yet." : "The daily check is off.";
    }

    function check() {
        if (root.busy || root.current === "")
            return ;

        root.busy = true;
        root.gotResponse = false;
        fetcher.running = true;
        upstream.running = true;
    }

    function maybeCheck() {
        if (root.wanted && Date.now() - root.checkedAt >= root.everyMs)
            root.check();

    }

    function openUpstream() {
        Quickshell.execDetached(["xdg-open", root.upstreamUrlLatest]);
    }

    function openLatest() {
        Quickshell.execDetached(["xdg-open", root.latestUrl]);
    }

    // one notification per version, with a button onto the release notes
    function announce() {
        if (!root.available || root.notified === root.latest)
            return ;

        root.notified = root.latest;
        root.save();
        var body = "You have v" + root.current + ". Pull the repo and run ./install.sh to update.";
        if (root.latestName !== "" && root.latestName.trim().replace(/^v/i, "") !== root.latest)
            body = root.latestName + "\n" + body;

        Quickshell.execDetached(["sh", "-c", "A=$(notify-send -a CirOShell -i \"$1\" \"$2\" \"$3\" -A \"open=What's new\" --wait) && [ \"$A\" = open ] && xdg-open \"$4\"; true", "sh", root.iconPath, "CirOShell v" + root.latest + " is out", body, root.latestUrl]);
    }

    readonly property string iconPath: Qt.resolvedUrl("assets/logo-mark.svg").toString().replace("file://", "")

    function take(body) {
        var d = JSON.parse(body);
        var tag = String(d.tag_name || "").trim().replace(/^v/i, "");
        if (tag === "") {
            root.problem = "unreadable";
            return ;
        }
        root.latest = tag;
        root.latestName = String(d.name || "").trim().replace(/^(ciroshell|lucid)\s+/i, "");
        root.latestUrl = String(d.html_url || root.releasesUrl);
        root.checkedAt = Date.now();
        root.problem = "";
        root.save();
        root.announce();
    }

    function save() {
        stateFile.setText(JSON.stringify({
            "checkedAt": root.checkedAt,
            "latest": root.latest,
            "name": root.latestName,
            "url": root.latestUrl,
            "notified": root.notified,
            "repo": root.repo,
            "upstream": root.upstreamLatest,
            "upstreamUrl": root.upstreamUrlLatest
        }));
    }

    onWantedChanged: {
        if (root.wanted)
            root.maybeCheck();

    }

    IpcHandler {
        target: "updates"

        function check(): void {
            root.check();
        }

        function status(): string {
            return root.currentLabel + " — " + root.status;
        }

        function probe(): string {
            return root.repo + " | latest=" + root.latest + " | url=" + root.latestUrl + " | upstream=" + root.upstreamLatest;
        }

    }

    Process {
        id: fetcher

        // no -f: the http code is wanted even when it is an error
        command: ["curl", "-s", "--max-time", "15", "-H", "Accept: application/vnd.github+json", "-w", "\n%{http_code}", "https://api.github.com/repos/" + root.repo + "/releases/latest"]
        onExited: {
            root.busy = false;
            if (!root.gotResponse)
                root.problem = "offline";

        }

        stdout: StdioCollector {
            onStreamFinished: {
                var t = this.text.trim();
                var cut = t.lastIndexOf("\n");
                var code = parseInt(cut === -1 ? t : t.slice(cut + 1), 10);
                var body = cut === -1 ? "" : t.slice(0, cut);
                if (!code)
                    return ;

                root.gotResponse = true;
                if (code === 404) {
                    // a real answer, not a failure: nothing is published yet
                    root.problem = "norelease";
                    root.checkedAt = Date.now();
                    root.save();
                } else if (code === 403 || code === 429)
                    root.problem = "ratelimited";
                else if (code !== 200)
                    root.problem = "offline";
                else
                    try {
                        root.take(body);
                    } catch (e) {
                        root.problem = "unreadable";
                    }
            }
        }

    }

    // upstream Lucid, for the "based on" line only; failing quietly is fine
    Process {
        id: upstream

        command: ["curl", "-s", "--max-time", "15", "-H", "Accept: application/vnd.github+json", "https://api.github.com/repos/" + root.upstreamRepo + "/releases/latest"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var d = JSON.parse(this.text);
                    var tag = String(d.tag_name || "").trim().replace(/^v/i, "");
                    if (tag === "")
                        return ;

                    root.upstreamLatest = tag;
                    root.upstreamUrlLatest = String(d.html_url || root.upstreamUrl);
                    root.save();
                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 3600000
        repeat: true
        running: true
        onTriggered: root.maybeCheck()
    }

    // let the session get a network up before the first look
    Timer {
        id: firstLook

        interval: 30000
        onTriggered: root.maybeCheck()
    }

    Component.onCompleted: firstLook.start()

    FileView {
        path: Qt.resolvedUrl("VERSION").toString().replace("file://", "")
        blockLoading: true
        printErrors: false
        onLoaded: root.base = text().trim().replace(/^v/i, "")
    }

    FileView {
        path: Qt.resolvedUrl("FORK").toString().replace("file://", "")
        blockLoading: true
        printErrors: false
        onLoaded: root.rev = text().trim()
    }

    FileView {
        id: stateFile

        path: Quickshell.env("HOME") + "/.cache/quickshell/lucid-updates.json"
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                var p = JSON.parse(text());
                root.upstreamLatest = p.upstream || "";
                root.upstreamUrlLatest = p.upstreamUrl || root.upstreamUrl;
                // a cache from before the fork had its own releases points at Lucid
                if (p.repo !== root.repo)
                    return ;

                root.checkedAt = p.checkedAt || 0;
                root.latest = p.latest || "";
                root.latestName = p.name || "";
                root.latestUrl = p.url || root.releasesUrl;
                root.notified = p.notified || "";
            } catch (e) {
            }
        }
    }

}

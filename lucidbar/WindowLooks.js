.pragma library

// what the Active window module's Status and Stacked looks read out, kept apart
// from ActiveWindow.qml so it can be tested

// the window's states worth a mark, in the order they're drawn
function marks(info) {
    const out = [];
    if (!info)
        return out;
    if (info.floating === true)
        out.push("floating");
    if (info.pinned === true)
        out.push("pinned");
    if ((info.fullscreen || 0) > 0)
        out.push("fullscreen");
    return out;
}

// [top, bottom]: the title over the app's name; with no title (or a title that
// is just the app's name) the name goes on top and the second line stays empty
function stackedLines(title, app) {
    const t = String(title || "").trim();
    const a = String(app || "").trim();
    if (t === "" || t === a)
        return [a, ""];
    return [t, a];
}

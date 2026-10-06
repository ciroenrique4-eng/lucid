.pragma library

// the media module's looks: which face it draws, how far the Progress look's
// fill reaches, and when the Vinyl panel's record turns

var faces = ["playing", "cover", "compact", "progress", "ring", "controls"];

function face(style) {
    return faces.indexOf(style) === -1 ? "playing" : style;
}

// the fill is a capsule: nothing at all before the song starts, then never
// thinner than it is tall so its ends stay round
function fillWidth(total, progress, minWidth) {
    if (!(progress > 0))
        return 0;
    return Math.max(minWidth, total * Math.min(1, progress));
}

// a record only turns while you can see it and the music plays
function spinning(open, playing) {
    return open === true && playing === true;
}

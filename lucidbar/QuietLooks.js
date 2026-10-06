.pragma library

// small pieces of the looks for the modules without a panel of their own
// (tray, privacy, start, show desktop, apps), kept apart so they can be tested

// Privacy's Chip: what is in use and by whom, "Microphone · Discord +1"
function chipText(noun, apps) {
    const list = apps || [];
    if (list.length === 0)
        return noun;
    return noun + " · " + list[0] + (list.length > 1 ? " +" + (list.length - 1) : "");
}

// Start's Distro: the icon name /etc/os-release gives as LOGO, quoted or not
function osLogo(text) {
    const m = /^LOGO=("?)([^"\n]*)\1\s*$/m.exec(String(text || ""));
    return m ? m[2].trim() : "";
}

// Apps' Stack: the icons overlap by about half a slot until the pointer opens
// them out to the usual spacing
function stackSpacing(slot, open, normal) {
    return open ? normal : -Math.round(slot * 0.45);
}

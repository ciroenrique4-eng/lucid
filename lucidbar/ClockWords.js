.pragma library

// the time in words, to the nearest five minutes: "quarter past ten",
// "las once menos cuarto". English and Spanish; any other language reads English

var enHours = ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"];
var enMinutes = { "5": "five", "10": "ten", "15": "quarter", "20": "twenty", "25": "twenty-five", "30": "half" };
var esHours = ["doce", "una", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once"];
var esMinutes = { "5": "cinco", "10": "diez", "15": "cuarto", "20": "veinte", "25": "veinticinco", "30": "media" };

function english(h, r) {
    if (r === 0) {
        if (h === 0)
            return "midnight";
        if (h === 12)
            return "noon";
        return enHours[h % 12] + " o'clock";
    }
    if (r <= 30)
        return enMinutes[r] + " past " + enHours[h % 12];
    return enMinutes[60 - r] + " to " + enHours[(h + 1) % 12];
}

function esHour(h) {
    return (h % 12 === 1 ? "la " : "las ") + esHours[h % 12];
}

// hours/minutes as read; h/r rounded to the five minutes
function spanish(hours, minutes, h, r) {
    // the last few minutes before the hour read as "almost"
    if (minutes >= 56) {
        const next = (hours + 1) % 24;
        if (next === 0)
            return "casi medianoche";
        if (next === 12)
            return "casi mediodía";
        return "casi " + esHour(next);
    }
    if (r === 0) {
        if (h === 0)
            return "medianoche";
        if (h === 12)
            return "mediodía";
        return esHour(h) + " en punto";
    }
    if (r <= 30)
        return esHour(h) + " y " + esMinutes[r];
    return esHour((h + 1) % 24) + " menos " + esMinutes[60 - r];
}

// hours 0–23, minutes 0–59, lang a locale name ("es", "es_MX", "en_US")
function words(hours, minutes, lang) {
    let h = hours;
    let r = Math.round(minutes / 5) * 5;
    if (r === 60) {
        h = (h + 1) % 24;
        r = 0;
    }
    if (String(lang).indexOf("es") === 0)
        return spanish(hours, minutes, h, r);
    return english(h, r);
}

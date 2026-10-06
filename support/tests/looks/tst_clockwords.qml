import QtQuick
import QtTest
import "../../../lucidbar/ClockWords.js" as Words

TestCase {
    name: "ClockWords"

    function test_english() {
        compare(Words.words(17, 0, "en"), "five o'clock");
        compare(Words.words(17, 2, "en"), "five o'clock");
        compare(Words.words(17, 3, "en"), "five past five");
        compare(Words.words(10, 5, "en"), "five past ten");
        compare(Words.words(10, 15, "en"), "quarter past ten");
        compare(Words.words(10, 30, "en"), "half past ten");
        compare(Words.words(10, 45, "en"), "quarter to eleven");
        compare(Words.words(10, 58, "en"), "eleven o'clock");
        compare(Words.words(0, 0, "en"), "midnight");
        compare(Words.words(12, 0, "en"), "noon");
        compare(Words.words(23, 40, "en"), "twenty to twelve");
    }

    function test_spanish() {
        compare(Words.words(17, 0, "es_MX"), "las cinco en punto");
        compare(Words.words(13, 0, "es"), "la una en punto");
        compare(Words.words(10, 5, "es"), "las diez y cinco");
        compare(Words.words(10, 15, "es"), "las diez y cuarto");
        compare(Words.words(10, 30, "es"), "las diez y media");
        compare(Words.words(10, 45, "es"), "las once menos cuarto");
        compare(Words.words(0, 50, "es"), "la una menos diez");
        compare(Words.words(0, 0, "es"), "medianoche");
        compare(Words.words(12, 0, "es"), "mediodía");
        compare(Words.words(16, 57, "es"), "casi las cinco");
    }

    function test_unknown_language_is_english() {
        compare(Words.words(10, 30, "de_DE"), "half past ten");
    }

    function test_midnight_wraps() {
        compare(Words.words(23, 58, "en"), "midnight");
        compare(Words.words(11, 58, "en"), "noon");
        compare(Words.words(23, 57, "es"), "casi medianoche");
    }
}

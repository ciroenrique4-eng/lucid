pragma Singleton
import QtQuick
QtObject {
    function tr(s) { let out = s; for (let i = 1; i < arguments.length; i++) out = out.replace("%" + i, arguments[i]); return out }
    function trn(one, many, n) { return tr(n === 1 ? one : many, n) }
}

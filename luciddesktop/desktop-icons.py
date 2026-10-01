#!/usr/bin/env python3
# the desktop folder for the icon layer.
#
#   desktop-icons.py watch [--hidden]
#       prints the folder as one JSON line, then a fresh line each time it or
#       the trash changes, for as long as the shell runs
#   desktop-icons.py new-folder
#       makes "New Folder" (or "New Folder 2"...) and prints its name
#   desktop-icons.py put copy|move|auto <dest-dir> <uri>...
#       copies or moves into dest-dir, never over an existing name, and prints
#       one "<uri>\t<new name>" line per item. auto moves within a filesystem
#       and copies across, the way a file manager's drag does
#   desktop-icons.py add-app <desktop-id>
#       drops an application's launcher on the desktop, ready to launch
#   desktop-icons.py rename <path> <new name>
#       renames a file; a launcher keeps its file name and gets a new Name=
#   desktop-icons.py trust <path>
#       marks a launcher as allowed to run
import ctypes
import json
import os
import signal
import stat
import subprocess
import sys

import gi

gi.require_version("Gio", "2.0")
gi.require_version("GLib", "2.0")
from gi.repository import Gio, GLib  # noqa: E402

# newer glib moved the desktop entry reader to GioUnix and left a deprecated
# alias behind; take whichever this system has
try:
    gi.require_version("GioUnix", "2.0")
    from gi.repository import GioUnix  # noqa: E402
    DesktopAppInfo = GioUnix.DesktopAppInfo
except (ValueError, ImportError):
    DesktopAppInfo = Gio.DesktopAppInfo

ATTRS = ",".join([
    "standard::name", "standard::display-name", "standard::type", "standard::icon",
    "standard::content-type", "standard::size", "standard::is-hidden", "standard::is-backup",
    "standard::is-symlink", "time::modified", "thumbnail::path", "access::can-execute",
])


def desktop_dir():
    d = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_DESKTOP)
    # with no user-dirs.dirs at all glib answers $HOME, and the home folder
    # spread across the desktop is never what anyone wants
    if not d or os.path.realpath(d) == os.path.realpath(GLib.get_home_dir()):
        d = os.path.join(GLib.get_home_dir(), "Desktop")
    return d


def trash_dir():
    return os.path.join(GLib.get_user_data_dir(), "Trash", "files")


def icon_names(icon):
    if icon is None:
        return []
    if isinstance(icon, Gio.ThemedIcon):
        return list(icon.get_names())
    if isinstance(icon, Gio.FileIcon):
        p = icon.get_file().get_path()
        return [p] if p else []
    return []


def entry(folder, info):
    name = info.get_name()
    path = os.path.join(folder, name)
    gfile = Gio.File.new_for_path(path)
    ctype = info.get_content_type() or ""
    is_dir = info.get_file_type() == Gio.FileType.DIRECTORY
    item = {
        "name": name,
        "label": info.get_display_name() or name,
        "path": path,
        "uri": gfile.get_uri(),
        "kind": "dir" if is_dir else "file",
        "mime": "inode/directory" if is_dir else ctype,
        "icons": icon_names(info.get_icon()),
        "thumb": info.get_attribute_byte_string("thumbnail::path") or "",
        "size": info.get_size(),
        "mtime": info.get_attribute_uint64("time::modified"),
        "link": info.get_is_symlink(),
        "exec": False,
    }
    if not is_dir and name.endswith(".desktop"):
        try:
            app = DesktopAppInfo.new_from_filename(path)
        except TypeError:
            app = None
        if app is not None:
            item["kind"] = "app"
            item["label"] = app.get_name() or name[:-8]
            item["icons"] = icon_names(app.get_icon()) or ["application-x-executable"]
            # the same rule KDE uses: a launcher only runs once it is marked
            # executable, so one that arrived in a download cannot fire on a click
            item["exec"] = info.get_attribute_boolean("access::can-execute")
    return item


def snapshot(folder, hidden):
    items = []
    if os.path.isdir(folder):
        try:
            en = Gio.File.new_for_path(folder).enumerate_children(ATTRS, Gio.FileQueryInfoFlags.NONE, None)
            for info in en:
                if not hidden and (info.get_is_hidden() or info.get_is_backup()):
                    continue
                items.append(entry(folder, info))
        except GLib.Error:
            pass
    try:
        trash = len(os.listdir(trash_dir()))
    except OSError:
        trash = 0
    return {"dir": folder, "exists": os.path.isdir(folder), "items": items, "trash": trash}


def watch(hidden):
    # follow the shell down instead of lingering after a reload
    try:
        ctypes.CDLL("libc.so.6").prctl(1, signal.SIGTERM)
    except OSError:
        pass
    folder = desktop_dir()
    loop = GLib.MainLoop()
    pending = [0]

    def emit():
        pending[0] = 0
        sys.stdout.write(json.dumps(snapshot(folder, hidden)) + "\n")
        sys.stdout.flush()
        return False

    def changed(*_):
        # a copy is a burst of events; one line once it settles
        if pending[0]:
            GLib.source_remove(pending[0])
        pending[0] = GLib.timeout_add(150, emit)

    monitors = []
    for d in (folder, trash_dir()):
        try:
            m = Gio.File.new_for_path(d).monitor_directory(Gio.FileMonitorFlags.WATCH_MOVES, None)
            m.connect("changed", changed)
            monitors.append(m)
        except GLib.Error:
            pass
    # the folder itself may come and go (or not exist yet): watch its parent too
    try:
        pm = Gio.File.new_for_path(os.path.dirname(folder)).monitor_directory(Gio.FileMonitorFlags.NONE, None)
        pm.connect("changed", lambda _m, f, _o, _e: changed() if f.get_path() == folder else None)
        monitors.append(pm)
    except GLib.Error:
        pass
    emit()
    signal.signal(signal.SIGTERM, lambda *_: loop.quit())
    loop.run()


def free_name(dest, name):
    if not os.path.lexists(os.path.join(dest, name)):
        return name
    stem, ext = name, ""
    if not name.startswith(".") and "." in name:
        stem, ext = name.rsplit(".", 1)
        ext = "." + ext
        # keep a double extension together: photos.tar.gz -> photos (2).tar.gz
        if stem.endswith(".tar"):
            stem, ext = stem[:-4], ".tar" + ext
    n = 2
    while os.path.lexists(os.path.join(dest, "%s (%d)%s" % (stem, n, ext))):
        n += 1
    return "%s (%d)%s" % (stem, n, ext)


def new_folder():
    folder = desktop_dir()
    os.makedirs(folder, exist_ok=True)
    name = "New Folder"
    n = 2
    while os.path.lexists(os.path.join(folder, name)):
        name = "New Folder %d" % n
        n += 1
    os.mkdir(os.path.join(folder, name))
    print(name)


def put(mode, dest, uris):
    os.makedirs(dest, exist_ok=True)
    dest_dev = os.stat(dest).st_dev
    for uri in uris:
        src = Gio.File.new_for_uri(uri)
        base = src.get_basename() or "file"
        spath = src.get_path()
        # dropping something where it already is does nothing
        if spath and os.path.dirname(os.path.abspath(spath)) == os.path.abspath(dest):
            print("%s\t%s" % (uri, base))
            continue
        name = free_name(dest, base)
        target = Gio.File.new_for_path(os.path.join(dest, name))
        how = mode
        if how == "auto":
            try:
                how = "move" if spath and os.stat(spath).st_dev == dest_dev else "copy"
            except OSError:
                how = "copy"
        try:
            if how == "move":
                src.move(target, Gio.FileCopyFlags.NOFOLLOW_SYMLINKS, None, None, None)
            elif spath and os.path.isdir(spath) and not os.path.islink(spath):
                # Gio copies files only
                subprocess.run(["cp", "-a", "--", spath, target.get_path()], check=True)
            else:
                src.copy(target, Gio.FileCopyFlags.NOFOLLOW_SYMLINKS, None, None, None)
            print("%s\t%s" % (uri, name), flush=True)
        except (GLib.Error, subprocess.CalledProcessError) as e:
            print("error\t%s\t%s" % (uri, e), file=sys.stderr, flush=True)


def app_file(desktop_id):
    # the shell knows apps by id with or without ".desktop"; the constructor
    # raises rather than answering None when there is no such entry
    for cand in (desktop_id, desktop_id + ".desktop"):
        try:
            app = DesktopAppInfo.new(cand)
        except TypeError:
            app = None
        if app is not None and app.get_filename():
            return app.get_filename()
    # a hidden or odd entry the lookup skips: find the file itself
    name = desktop_id if desktop_id.endswith(".desktop") else desktop_id + ".desktop"
    for d in [GLib.get_user_data_dir()] + list(GLib.get_system_data_dirs()):
        p = os.path.join(d, "applications", name)
        if os.path.isfile(p):
            return p
    return None


def add_app(desktop_id):
    src = app_file(desktop_id)
    if src is None:
        sys.exit("no such application: " + desktop_id)
    folder = desktop_dir()
    os.makedirs(folder, exist_ok=True)
    name = free_name(folder, os.path.basename(src))
    path = os.path.join(folder, name)
    with open(src, "rb") as f, open(path, "wb") as out:
        out.write(f.read())
    trust(path)
    print(name)


def trust(path):
    mode = os.stat(path).st_mode
    os.chmod(path, mode | stat.S_IXUSR)


def rename(path, new):
    new = new.strip()
    if not new or "/" in new:
        sys.exit("bad name")
    if path.endswith(".desktop") and os.path.isfile(path):
        kf = GLib.KeyFile()
        kf.load_from_file(path, GLib.KeyFileFlags.KEEP_COMMENTS | GLib.KeyFileFlags.KEEP_TRANSLATIONS)
        kf.set_string("Desktop Entry", "Name", new)
        # a translated name would win over the one just typed
        for key in kf.get_keys("Desktop Entry")[0]:
            if key.startswith("Name["):
                kf.remove_key("Desktop Entry", key)
        kf.save_to_file(path)
        print(os.path.basename(path))
        return
    dest = os.path.join(os.path.dirname(path), new)
    if os.path.lexists(dest):
        sys.exit("exists")
    os.rename(path, dest)
    print(new)


def peek(path, n=3):
    # what a folder holds, for the fan its icon opens on hover: the first few
    # (folders first, by name) and how many there are
    items = []
    try:
        en = Gio.File.new_for_path(path).enumerate_children(ATTRS, Gio.FileQueryInfoFlags.NONE, None)
        for info in en:
            if info.get_is_hidden() or info.get_is_backup():
                continue
            items.append(entry(path, info))
    except GLib.Error:
        pass
    items.sort(key=lambda e: (e["kind"] != "dir", e["label"].lower()))
    print(json.dumps({"count": len(items), "items": items[:n]}))


def main():
    a = sys.argv[1:]
    cmd = a[0] if a else "watch"
    if cmd == "watch":
        watch("--hidden" in a)
    elif cmd == "new-folder":
        new_folder()
    elif cmd == "put":
        dest = a[2] if a[2] else desktop_dir()
        put(a[1], dest, a[3:])
    elif cmd == "add-app":
        add_app(a[1])
    elif cmd == "rename":
        rename(a[1], a[2])
    elif cmd == "peek":
        peek(a[1])
    elif cmd == "trust":
        trust(a[1])
    else:
        sys.exit("unknown command " + cmd)


if __name__ == "__main__":
    main()

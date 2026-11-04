#!/usr/bin/env python3
"""Build the browsable catalogue: out/site/.

Reads components/<part>/catalog.json, renders every model a view lists to
out/site/models/<part>/<name>.stl, copies each part's fit piece into
out/site/downloads/, and writes out/site/catalog.json for the pages in site/.

    python3 tools/build_site.py [--openscad PATH] [part ...]

Only re-renders a model when a .scad in its part folder or util/ is newer.
"""
import argparse
import glob
import json
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "out", "site")


def newest(paths):
    return max((os.path.getmtime(p) for p in paths), default=0)


def render(openscad, src, dst, defines, deps):
    if os.path.exists(dst) and os.path.getmtime(dst) >= newest(deps):
        return
    args = [openscad, "--backend=manifold", "--hardwarnings", "--export-format", "binstl", "-o", dst]
    for k, v in defines.items():
        args += ["-D", f"{k}={json.dumps(v)}"]
    print("render", os.path.relpath(dst, ROOT), flush=True)
    subprocess.run(args + [src], check=True, stdout=subprocess.DEVNULL)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--openscad", default="openscad")
    ap.add_argument("parts", nargs="*")
    a = ap.parse_args()

    os.makedirs(os.path.join(OUT, "downloads"), exist_ok=True)
    for f in glob.glob(os.path.join(ROOT, "site", "*")):
        shutil.copy2(f, OUT)

    catalog = []
    for cat in sorted(glob.glob(os.path.join(ROOT, "components", "*", "catalog.json"))):
        pdir = os.path.dirname(cat)
        part = os.path.basename(pdir)
        if a.parts and part not in a.parts:
            continue
        with open(cat) as f:
            entry = json.load(f)
        entry["id"] = part
        deps = glob.glob(os.path.join(pdir, "**", "*.scad"), recursive=True) + \
            glob.glob(os.path.join(ROOT, "util", "*.scad"))
        mdir = os.path.join(OUT, "models", part)
        os.makedirs(mdir, exist_ok=True)
        for view in entry["views"]:
            for p in view["parts"]:
                dst = os.path.join(mdir, p["name"] + ".stl")
                render(a.openscad, os.path.join(pdir, p["scad"]), dst, p.get("defines", {}), deps)
                p["file"] = f"models/{part}/{p['name']}.stl"
                p.pop("scad"), p.pop("defines", None)
        entry["downloads"] = []
        for ext in ("3mf", "stl"):
            fit = os.path.join(ROOT, "out", f"{part}_fit.{ext}")
            if os.path.exists(fit):
                shutil.copy2(fit, os.path.join(OUT, "downloads"))
                entry["downloads"].append(f"downloads/{part}_fit.{ext}")
        entry["updated"] = subprocess.run(
            ["git", "log", "-1", "--format=%cs", "--", pdir], cwd=ROOT,
            capture_output=True, text=True).stdout.strip()
        catalog.append(entry)

    with open(os.path.join(OUT, "catalog.json"), "w") as f:
        json.dump(catalog, f, indent=1, ensure_ascii=False)
    print(f"{len(catalog)} components → {os.path.relpath(OUT, ROOT)}")


if __name__ == "__main__":
    sys.exit(main())

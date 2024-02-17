import argparse
import os
import shutil
import subprocess
import sys


CURR_DIR = os.path.dirname(__file__)
BUILD_DIR = os.path.join(CURR_DIR, "build")
SOURCE_DIR = os.path.join(CURR_DIR, "source")
ASSETS_DIR = os.path.join(CURR_DIR, "source", "assets")
ASSETS_DIR_IN_BUILD = os.path.join(BUILD_DIR, "assets")
ELISP_SCRIPT = os.path.join(CURR_DIR, "build-site.el")


def clean():
    if os.path.exists(BUILD_DIR) and os.path.isdir(BUILD_DIR):
        shutil.rmtree(BUILD_DIR, ignore_errors=True)


def build() -> bool:
    cmd = f"emacs -Q --script {ELISP_SCRIPT!r}"
    proc = subprocess.run(cmd, capture_output=False, shell=True)
    return proc.returncode == 0


def refresh_assets():
    if os.path.exists(ASSETS_DIR_IN_BUILD):
        shutil.rmtree(ASSETS_DIR_IN_BUILD)
        shutil.copytree(ASSETS_DIR, ASSETS_DIR_IN_BUILD, dirs_exist_ok=True)
        


def run_server():
    try:
        cmd = [sys.executable, "-m", "http.server", "-d", BUILD_DIR, "3001"]
        proc = subprocess.run(cmd, shell=False)
    except KeyboardInterrupt:
        exit()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", action="store_true", help="build the site")
    ap.add_argument("--assets", action="store_true", help="copy over the assets from source to build dir")
    ap.add_argument("--server", action="store_true", help="run http server in build dir")

    args = ap.parse_args()

    if args.build:
        build()
    elif args.assets:
        refresh_assets()
    if args.server:
        run_server()


    

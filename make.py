import argparse
import os
import shutil
import subprocess
import sys


CURR_DIR = os.path.dirname(__file__)
BUILD_DIR = os.path.join(CURR_DIR, "build")
SOURCE_DIR = os.path.join(CURR_DIR, "source")
ELISP_SCRIPT = os.path.join(CURR_DIR, "build-site.el")


def clean():
    """Delete the build directory recursively."""
    if os.path.exists(BUILD_DIR) and os.path.isdir(BUILD_DIR):
        shutil.rmtree(BUILD_DIR, ignore_errors=True)


def build() -> bool:
    """Build the site by running the emacs lisp script."""
    cmd = f"emacs -Q --script {ELISP_SCRIPT!r}"
    proc = subprocess.run(cmd, capture_output=False, shell=True)
    return proc.returncode == 0


def refresh_assets():
    """Copy assets from source to build directory."""
    assets_build = os.path.join(BUILD_DIR, "assets")
    assets_source = os.path.join(SOURCE_DIR, "assets")
    if os.path.exists(assets_build):
        shutil.rmtree(assets_build)
        shutil.copytree(assets_source, assets_build, dirs_exist_ok=True)


def run_server(port: str = "8000"):
    """Start a http server in the build directory."""
    try:
        cmd = [sys.executable, "-m", "http.server", "-d", BUILD_DIR, port]
        proc = subprocess.run(cmd, shell=False)
    except KeyboardInterrupt:
        exit()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", action="store_true", help="build the site")
    ap.add_argument(
        "--assets",
        action="store_true",
        help="copy over the assets from source to build dir",
    )
    ap.add_argument(
        "--server", action="store_true", help="run http server in build dir"
    )
    ap.add_argument(
        "--port", type=str, default="8000", help="run http server in build dir"
    )
    ap.add_argument("--clean", action="store_true", help="delete the build dir")
    args = ap.parse_args()

    if args.build:
        build()
    elif args.assets:
        refresh_assets()
    elif args.clean:
        clean()

    if args.server:
        run_server(port=args.port)

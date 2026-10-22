"""
Render every diagram to svg/ and png/.

    python build.py            # all diagrams
    python build.py usecase    # only those whose name contains "usecase"

PNG rendering uses the Edge (Chromium) browser that ships with Windows, headless,
at twice the size for print.
"""
import shutil
import subprocess
import sys
from pathlib import Path

import d1_model
import d2_usecase
import d3_activity
import d4_sequence
import d5_database
import d6_app
import d6_class
import d7_er

HERE = Path(__file__).resolve().parent
OUT = HERE.parent
EDGE = Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
PROFILE = Path.home() / "AppData" / "Local" / "Temp" / "uml-edge-profile"

DIAGRAMS = [*d1_model.ALL, *d2_usecase.ALL, *d3_activity.ALL, *d4_sequence.ALL,
            *d5_database.ALL, *d6_class.ALL, *d6_app.ALL, *d7_er.ALL]


def render(name: str, canvas) -> None:
    svg = OUT / "svg" / f"{name}.svg"
    png = OUT / "png" / f"{name}.png"
    canvas.save(svg)
    subprocess.run([str(EDGE), "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    f"--user-data-dir={PROFILE}", "--force-device-scale-factor=2",
                    f"--window-size={int(canvas.w)},{int(canvas.h)}",
                    f"--screenshot={png}", svg.as_uri()],
                   check=True, capture_output=True)
    print(f"{name}: {canvas.w}x{canvas.h}")


def main(argv: list[str]) -> None:
    (OUT / "svg").mkdir(exist_ok=True)
    (OUT / "png").mkdir(exist_ok=True)
    wanted = argv[1:]
    for name, make in DIAGRAMS:
        if not wanted or any(w in name for w in wanted):
            render(name, make())
    shutil.rmtree(PROFILE, ignore_errors=True)


if __name__ == "__main__":
    main(sys.argv)

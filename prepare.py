"""Export MATPOWER cases and label DC OPF feasibility (requires Optimization Toolbox)."""

import argparse
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def matlab_string(path: Path) -> str:
    return "'" + str(path.resolve()).replace("'", "''") + "'"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--engine", choices=["octave", "matlab"], default="matlab")
    parser.add_argument("--output", type=Path, default=ROOT / "data")
    args = parser.parse_args()
    command = (
        f"addpath({matlab_string(ROOT)}); "
        f"export_cases({matlab_string(ROOT / 'matpower')}, "
        f"{matlab_string(args.output)});"
    )
    flags = ["-batch"] if args.engine == "matlab" else ["--quiet", "--no-gui", "--eval"]
    subprocess.run([args.engine, *flags, command], check=True)


if __name__ == "__main__":
    main()

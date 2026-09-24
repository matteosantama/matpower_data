"""Load an exported MATPOWER case, preserving matrix dimensions and fields."""

from pathlib import Path
from typing import Any

from scipy.io import loadmat


def load_case(path: str | Path) -> dict[str, Any]:
    mpc = loadmat(path, struct_as_record=False)["mpc"][0, 0]
    case = {name: getattr(mpc, name) for name in mpc._fieldnames}
    case["baseMVA"] = float(case["baseMVA"].item())
    case["version"] = str(case["version"].item())
    return case

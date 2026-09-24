From the repository root:

```bash
git submodule update --init
uv sync
module load matlab/r2024b
uv run --no-sync python prepare.py --engine matlab
```

Exports the pinned MATPOWER cases to `data/*.mat`.

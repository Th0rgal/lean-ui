#!/usr/bin/env python3
"""Golden judge: compare candidate PNGs against reference PNGs.

Usage: diff_goldens.py REF_DIR CAND_DIR [--out DIR] [--threshold 0.985] [--require N]

Every `*.png` in REF_DIR must have a same-named, same-sized file in CAND_DIR.
Prints one JSON object; exit 0 only if every pair has SSIM >= threshold, no reference is
missing a candidate, and at least `--require` pairs were compared. A missing or
mis-sized candidate is a failure, never a skip.

SSIM is the standard single-scale index (Wang et al. 2004): 11x11 Gaussian window,
sigma 1.5, K1=0.01, K2=0.03, on 8-bit BT.601 luma, averaged over the valid region.
Needs numpy and Pillow only.
"""
import argparse, json, pathlib, sys
import numpy as np
from PIL import Image

def luma(path):
    rgb = np.asarray(Image.open(path).convert("RGB"), dtype=np.float64)
    return rgb @ np.array([0.299, 0.587, 0.114])

def blur(a, k):
    a = np.apply_along_axis(lambda v: np.convolve(v, k, mode="valid"), 0, a)
    return np.apply_along_axis(lambda v: np.convolve(v, k, mode="valid"), 1, a)

def ssim_map(x, y):
    g = np.exp(-((np.arange(11) - 5) ** 2) / (2 * 1.5 ** 2)); g /= g.sum()
    c1, c2 = (0.01 * 255) ** 2, (0.03 * 255) ** 2
    mx, my = blur(x, g), blur(y, g)
    vx, vy, cxy = blur(x * x, g) - mx * mx, blur(y * y, g) - my * my, blur(x * y, g) - mx * my
    return ((2 * mx * my + c1) * (2 * cxy + c2)) / ((mx * mx + my * my + c1) * (vx + vy + c2))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ref"); ap.add_argument("cand")
    ap.add_argument("--out"); ap.add_argument("--threshold", type=float, default=0.985)
    ap.add_argument("--require", type=int, default=1)
    a = ap.parse_args()
    ref, cand = pathlib.Path(a.ref), pathlib.Path(a.cand)
    out = pathlib.Path(a.out) if a.out else None
    if out: out.mkdir(parents=True, exist_ok=True)
    rows = []
    for r in sorted(ref.glob("*.png")):
        c = cand / r.name
        row = {"name": r.name, "ssim": None, "pass": False}
        if not c.exists():
            row["error"] = "missing candidate"
        else:
            x, y = luma(r), luma(c)
            if x.shape != y.shape:
                row["error"] = f"size {y.shape[1]}x{y.shape[0]} != reference {x.shape[1]}x{x.shape[0]}"
            else:
                m = ssim_map(x, y)
                row["ssim"] = round(float(m.mean()), 6)
                row["max_abs_diff"] = int(np.abs(x - y).max())
                row["pass"] = row["ssim"] >= a.threshold
                if out:
                    heat = np.clip((1 - m) * 255, 0, 255).astype(np.uint8)
                    Image.fromarray(heat).save(out / f"heat_{r.name}")
        rows.append(row)
    ok = len(rows) >= a.require and all(x["pass"] for x in rows)
    scores = [x["ssim"] for x in rows if x["ssim"] is not None]
    print(json.dumps({"ok": ok, "threshold": a.threshold, "compared": len(rows),
                      "required": a.require, "error_count": sum(not x["pass"] for x in rows),
                      "min_ssim": min(scores) if scores else None, "results": rows}, indent=1))
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()

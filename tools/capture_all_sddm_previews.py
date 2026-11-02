#!/usr/bin/env python3
import glob
import os
import subprocess
import sys
import time
from PIL import Image

def main():
    repo_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    theme_dir = os.path.join(repo_dir, "themes", "sm1tee")
    meta_path = os.path.join(theme_dir, "metadata.desktop")
    configs_dir = os.path.join(theme_dir, "configs")
    previews_dir = os.path.join(repo_dir, "docs", "previews")
    os.makedirs(previews_dir, exist_ok=True)

    configs = sorted([os.path.splitext(os.path.basename(f))[0] for f in glob.glob(os.path.join(configs_dir, "*.conf"))])
    total = len(configs)
    print(f"Starting SDDM real screen capture for {total} themes...")

    with open(meta_path, "r", encoding="utf-8") as f:
        original_meta = f.readlines()

    success_count = 0
    start_all = time.time()

    for idx, theme in enumerate(configs, 1):
        t0 = time.time()
        print(f"[{idx}/{total}] Capturing theme: {theme}...", end="", flush=True)

        # Update metadata.desktop to use this theme config
        with open(meta_path, "w", encoding="utf-8") as f:
            for line in original_meta:
                if line.startswith("ConfigFile=configs/"):
                    f.write(f"ConfigFile=configs/{theme}.conf\n")
                else:
                    f.write(line)

        # Launch SDDM greeter in test-mode
        p = subprocess.Popen(
            ["sddm-greeter-qt6", "--test-mode", "--theme", theme_dir],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        # Give greeter enough time to render background video/image & UI controls
        time.sleep(1.2)

        cap_path = "/tmp/sddm_batch_cap.png"
        res = subprocess.run(["grim", cap_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # Terminate greeter
        p.terminate()
        try:
            p.wait(timeout=1.5)
        except Exception:
            p.kill()

        if res.returncode != 0 or not os.path.exists(cap_path):
            print(" FAILED to capture grim!")
            continue

        try:
            im = Image.open(cap_path).convert("RGB")
            if im.size != (1920, 1080):
                im = im.resize((1920, 1080), Image.Resampling.LANCZOS)
            
            out_file = os.path.join(previews_dir, f"{theme}.jpg")
            im.save(out_file, "JPEG", quality=93, optimize=True)
            elapsed = time.time() - t0
            size_kb = os.path.getsize(out_file) / 1024
            print(f" Done ({elapsed:.1f}s, {size_kb:.1f} KB)")
            success_count += 1
        except Exception as e:
            print(f" ERROR: {e}")

    # Restore metadata.desktop to default
    with open(meta_path, "w", encoding="utf-8") as f:
        for line in original_meta:
            if line.startswith("ConfigFile=configs/"):
                f.write("ConfigFile=configs/dark_knight_storm.conf\n")
            else:
                f.write(line)

    if os.path.exists("/tmp/sddm_batch_cap.png"):
        os.remove("/tmp/sddm_batch_cap.png")

    total_time = time.time() - start_all
    print(f"\nAll done! Successfully captured {success_count}/{total} themes in {total_time:.1f}s.")

if __name__ == "__main__":
    main()

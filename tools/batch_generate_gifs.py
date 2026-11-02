#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import re
import glob
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed
from PIL import Image, ImageDraw, ImageFont

os.makedirs("docs/previews", exist_ok=True)
os.makedirs("/tmp/ui_overlays", exist_ok=True)

SPECIAL_FONTS = {
    "edo sz hq": "themes/sm1tee/fonts/edoszhq_regular.ttf",
    "sdk_jp_web": "themes/sm1tee/fonts/ja-jp.ttf",
    "moscow metro": "themes/sm1tee/fonts/aa_haymaker.ttf",
    "cattedrale": "themes/sm1tee/fonts/Cattedrale[RUSbyPenka220]-Sliced_0.ttf",
    "mason chronicles": "themes/sm1tee/fonts/Chronicles_font.ttf",
    "harry potter": "themes/sm1tee/fonts/harrypotterrussianversionofgfdtk.ttf",
    "bulbasaur": "themes/sm1tee/fonts/BulbasaurSP.otf",
}
fonts_on_disk = {os.path.basename(f).lower(): f for f in glob.glob("themes/sm1tee/fonts/*")}

def find_font(name):
    low = name.strip().lower()
    for k, v in SPECIAL_FONTS.items():
        if k in low:
            return v
    clean = re.sub(r"[^a-z0-9]", "", low)
    for fn, path in fonts_on_disk.items():
        fn_clean = re.sub(r"[^a-z0-9]", "", fn)
        if clean in fn_clean or fn_clean in clean:
            return path
    for w in low.split():
        if len(w) >= 4:
            for fn, path in fonts_on_disk.items():
                if w in fn:
                    return path
    return "themes/sm1tee/fonts/Trajan Pro 3 Regular.otf"

def hex_to_rgb(hex_str, default=(255, 255, 255)):
    hex_str = hex_str.strip().lstrip("#")
    if len(hex_str) == 3:
        hex_str = "".join([c*2 for c in hex_str])
    if len(hex_str) == 6:
        try:
            return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))
        except ValueError:
            return default
    return default

# 1. Base key icon
svg_pass = open("themes/sm1tee/icons/password.svg").read().replace("#fff", "#ffffff")
with open("/tmp/pass_temp.svg", "w") as f:
    f.write(svg_pass)
subprocess.run(["rsvg-convert", "-w", "26", "-h", "26", "/tmp/pass_temp.svg", "-o", "/tmp/pass_white.png"], check=True)
pass_icon = Image.open("/tmp/pass_white.png").convert("RGBA")

# Avatar base
av_raw = Image.open("themes/sm1tee/icons/user-default.png").convert("RGBA")
av_size = 190
av_raw = av_raw.resize((av_size, av_size), Image.Resampling.LANCZOS)
mask = Image.new("L", (av_size, av_size), 0)
m_draw = ImageDraw.Draw(mask)
m_draw.ellipse((0, 0, av_size, av_size), fill=255)
avatar_base = Image.new("RGBA", (av_size, av_size), (0, 0, 0, 0))
avatar_base.paste(av_raw, (0, 0), mask)

def render_theme_gif(theme):
    try:
        conf_path = f"themes/sm1tee/configs/{theme}.conf"
        if not os.path.exists(conf_path):
            return f"[ERROR] Config not found: {conf_path}"
        txt = open(conf_path, encoding="utf-8").read()
        
        pos_m = re.search(r"\[LoginScreen\.LoginArea\][\s\S]*?position\s*=\s*([a-z]+)", txt)
        margin_m = re.search(r"\[LoginScreen\.LoginArea\][\s\S]*?margin\s*=\s*(-?[0-9]+)", txt)
        pos = pos_m.group(1) if pos_m else "left"
        margin = int(margin_m.group(1)) if margin_m else 160
        
        acc_m = re.search(r"\[LoginScreen\.LoginArea\.PasswordInput\][\s\S]*?border-color\s*=\s*([^\n]+)", txt)
        accent_rgb = hex_to_rgb(acc_m.group(1) if acc_m else "#93c5fd")
        
        btn_m = re.search(r"\[LoginScreen\.LoginArea\.LoginButton\][\s\S]*?background-color\s*=\s*([^\n]+)", txt)
        btn_rgb = hex_to_rgb(btn_m.group(1) if btn_m else "#93c5fd", default=accent_rgb)
        
        btn_c_m = re.search(r"\[LoginScreen\.LoginArea\.LoginButton\][\s\S]*?content-color\s*=\s*([^\n]+)", txt)
        btn_c_rgb = hex_to_rgb(btn_c_m.group(1) if btn_c_m else "#090714", default=(9, 7, 20))
        
        inp_m = re.search(r"\[LoginScreen\.LoginArea\.PasswordInput\][\s\S]*?background-color\s*=\s*([^\n]+)", txt)
        inp_rgb = hex_to_rgb(inp_m.group(1) if inp_m else "#080b12", default=(8, 11, 18))
        
        font_m = re.search(r"font-family\s*=\s*([^\n]+)", txt)
        font_name = font_m.group(1).strip() if font_m else "Trajan Pro 3"
        font_file = find_font(font_name)
        
        # Arrow icon
        svg_arrow = open("themes/sm1tee/icons/arrow-right.svg").read().replace("#fff", f"#{btn_c_rgb[0]:02x}{btn_c_rgb[1]:02x}{btn_c_rgb[2]:02x}")
        arrow_svg_path = f"/tmp/ui_overlays/arrow_{theme}.svg"
        with open(arrow_svg_path, "w") as f:
            f.write(svg_arrow)
        arrow_png_path = f"/tmp/ui_overlays/arrow_{theme}.png"
        subprocess.run(["rsvg-convert", "-w", "22", "-h", "22", arrow_svg_path, "-o", arrow_png_path], check=True)
        arrow_icon = Image.open(arrow_png_path).convert("RGBA")
        
        # Build overlay
        ui = Image.new("RGBA", (1920, 1080), (0, 0, 0, 0))
        avatar = avatar_base.copy()
        av_draw = ImageDraw.Draw(avatar)
        av_draw.ellipse((2, 2, av_size - 3, av_size - 3), outline=accent_rgb + (255,), width=4)
        
        font_user = ImageFont.truetype(font_file, 48)
        font_inp = ImageFont.truetype(font_file, 22)
        
        inp_w, inp_h = 360, 54
        btn_w = 54
        total_inp_w = inp_w + btn_w
        
        draw_tmp = ImageDraw.Draw(ui)
        bbox = draw_tmp.textbbox((0, 0), "SM1TEE", font=font_user)
        u_text_w = bbox[2] - bbox[0]
        
        if pos == "left":
            x_av = margin if margin > 0 else 160
            y_av = 540 - av_size // 2
            x_layout = x_av + av_size + 24
            y_u = 540 - 45
            y_inp = y_u + 60
            x_btn = x_layout + inp_w
            x_text = x_layout
        elif pos == "right":
            m = margin if margin > 0 else 160
            x_av = 1920 - m - av_size
            y_av = 540 - av_size // 2
            x_layout = x_av - 24 - total_inp_w
            y_u = 540 - 45
            y_inp = y_u + 60
            x_btn = x_layout + inp_w
            x_text = x_layout + total_inp_w - u_text_w
        else: # center
            x_av = 960 - av_size // 2
            if margin <= 0 or margin == 160:
                y_av = 540 - 150
            elif margin > 600:
                y_av = int(margin * 1080 / 1440)
            else:
                y_av = margin
            x_layout = 960 - total_inp_w // 2
            y_u = y_av + av_size + 16
            y_inp = y_u + 60
            x_btn = x_layout + inp_w
            x_text = 960 - u_text_w // 2
            
        ui.paste(avatar, (x_av, y_av), avatar)
        draw = ImageDraw.Draw(ui)
        draw.text((x_text, y_u), "SM1TEE", font=font_user, fill=(255, 255, 255, 255))
        
        # Password box
        pass_layer = Image.new("RGBA", (1920, 1080), (0, 0, 0, 0))
        p_draw = ImageDraw.Draw(pass_layer)
        p_draw.rounded_rectangle([x_layout, y_inp, x_layout + inp_w + 16, y_inp + inp_h], radius=16, fill=inp_rgb + (217,))
        p_draw.rectangle([x_layout + inp_w, y_inp, x_layout + inp_w + 16, y_inp + inp_h], fill=(0, 0, 0, 0))
        p_draw.rounded_rectangle([x_layout, y_inp, x_layout + inp_w + 16, y_inp + inp_h], radius=16, outline=accent_rgb + (255,), width=2)
        p_draw.line([(x_layout + inp_w, y_inp), (x_layout + inp_w, y_inp + inp_h)], fill=(0, 0, 0, 0), width=3)
        ui = Image.alpha_composite(ui, pass_layer)
        
        # Paste password key icon & placeholder text
        y_icon = y_inp + (inp_h - 26) // 2
        ui.paste(pass_icon, (x_layout + 16, y_icon), pass_icon)
        draw = ImageDraw.Draw(ui)
        draw.text((x_layout + 16 + 26 + 12, y_inp + 14), "Пароль", font=font_inp, fill=(255, 255, 255, 180))
        
        # Button
        btn_layer = Image.new("RGBA", (1920, 1080), (0, 0, 0, 0))
        b_draw = ImageDraw.Draw(btn_layer)
        b_draw.rounded_rectangle([x_btn - 16, y_inp, x_btn + btn_w, y_inp + inp_h], radius=16, fill=btn_rgb + (255,))
        b_draw.rectangle([x_btn - 16, y_inp, x_btn, y_inp + inp_h], fill=(0, 0, 0, 0))
        ui = Image.alpha_composite(ui, btn_layer)
        
        x_arrow = x_btn + (btn_w - 22) // 2
        y_arrow = y_inp + (inp_h - 22) // 2
        ui.paste(arrow_icon, (x_arrow, y_arrow), arrow_icon)
        
        ov_path = f"/tmp/ui_overlays/ui_{theme}.png"
        ui.save(ov_path)
        
        # Ffmpeg render
        gif_out = f"docs/previews/{theme}.gif"
        mp4_in = f"themes/sm1tee/backgrounds/{theme}.mp4"
        cmd = [
            "ffmpeg", "-y", "-ss", "00:00:01", "-t", "3.5",
            "-i", mp4_in, "-i", ov_path,
            "-filter_complex", "[0:v]scale=720:405[bg];[1:v]scale=720:405[fg];[bg][fg]overlay=0:0[v];[v]fps=15,split[s0][s1];[s0]palettegen=max_colors=128:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3",
            gif_out
        ]
        res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode != 0:
            return f"[ERROR] ffmpeg failed for {theme}"
        size_mb = os.path.getsize(gif_out) / (1024 * 1024)
        return f"[OK] {theme}: {size_mb:.2f} MB"
    except Exception as e:
        return f"[EXCEPTION] {theme}: {e}"

if __name__ == "__main__":
    with open("README.md") as f:
        themes = re.findall(r"### `([^`]+)`", f.read())
    
    print(f"Starting batch generation of {len(themes)} animated GIFs with 4 parallel workers...")
    with ProcessPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(render_theme_gif, t): t for t in themes}
        for i, fut in enumerate(as_completed(futures), 1):
            res = fut.result()
            print(f"[{i}/{len(themes)}] {res}")
    print("All animated GIF previews generated successfully!")

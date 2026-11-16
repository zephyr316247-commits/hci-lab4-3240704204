# -*- coding: utf-8 -*-
"""把到点触发录屏的帧合成 GIF，并生成时间线。"""
import os
from PIL import Image

root = r"C:\Users\12807\Desktop\3240704204_王志远_实验4"
frames_dir = os.path.join(root, "evidence", "recording", "frames")
out_gif = os.path.join(root, "evidence", "recording", "timer_trigger.gif")
files = sorted(f for f in os.listdir(frames_dir) if f.lower().endswith(".jpg"))
print("frames:", len(files))

frames = []
for f in files:
    im = Image.open(os.path.join(frames_dir, f)).convert("RGB")
    w, h = im.size
    nw = 1280
    nh = int(h * nw / w)
    frames.append(im.resize((nw, nh), Image.LANCZOS))

# 每帧 0.5 秒
frames[0].save(out_gif, save_all=True, append_images=frames[1:], duration=500, loop=0, optimize=True)
print("gif:", out_gif, os.path.getsize(out_gif) // 1024, "KB", frames[0].size)

# 时间线（帧号 + 文件修改时间）
with open(os.path.join(root, "evidence", "recording", "frames_timeline.txt"), "w", encoding="utf-8") as fp:
    fp.write("帧号\t文件修改时间\n")
    for f in files:
        t = os.path.getmtime(os.path.join(frames_dir, f))
        import datetime
        fp.write("%s\t%s\n" % (f, datetime.datetime.fromtimestamp(t).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]))
print("timeline written")

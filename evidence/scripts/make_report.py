# -*- coding: utf-8 -*-
"""生成实验四报告（按学院模板），并合成报告用拼图。"""
import os
from PIL import Image
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn

ROOT = r"C:\Users\12807\Desktop\3240704204_王志远_实验4"
SHOTS = os.path.join(ROOT, "evidence", "screenshots")
ASSETS = os.path.join(ROOT, "evidence", "report_assets")
TEMPLATE = r"C:\Users\12807\Desktop\_lab4_work\实验报告：学号-姓名-实验1.docx"
OUT = r"C:\Users\12807\Desktop\3240704204-王志远-实验4报告.docx"
os.makedirs(ASSETS, exist_ok=True)


def compose(paths, out, height=600, gap=16):
    ims = [Image.open(p).convert("RGB") for p in paths]
    scaled = []
    for im in ims:
        w, h = im.size
        nw = int(w * height / h)
        scaled.append(im.resize((nw, height), Image.LANCZOS))
    total = sum(im.size[0] for im in scaled) + gap * (len(scaled) - 1)
    canvas = Image.new("RGB", (total, height), (255, 255, 255))
    x = 0
    for im in scaled:
        canvas.paste(im, (x, 0))
        x += im.size[0] + gap
    canvas.save(out)


compose([os.path.join(SHOTS, "01_browser_home.png"), os.path.join(SHOTS, "03_zoom_title.png")],
        os.path.join(ASSETS, "fig_browser.png"), 640)
compose([os.path.join(SHOTS, "02_history_dropdown.png"), os.path.join(SHOTS, "04_back_disabled.png")],
        os.path.join(ASSETS, "fig_p8.png"), 520)
compose([os.path.join(SHOTS, "05_timer_default.png"), os.path.join(SHOTS, "06_carry.png"),
         os.path.join(SHOTS, "07_timer_invalid.png")],
        os.path.join(ASSETS, "fig_timer.png"), 380)

doc = Document(TEMPLATE)
t = doc.tables[0]
SONG, HEI = "宋体", "黑体"


def set_run(r, size=12, bold=False, font=SONG, color=None):
    r.font.name = font
    r.font.size = Pt(size)
    r.font.bold = bold
    r._element.rPr.rFonts.set(qn("w:eastAsia"), font)
    if color:
        r.font.color.rgb = RGBColor(*color)


def set_cell(cell, text, size=11, bold=False, font=SONG, align=None):
    pars = cell.paragraphs
    for p in pars[1:]:
        p._element.getparent().remove(p._element)
    p = cell.paragraphs[0]
    for r in list(p.runs):
        r._element.getparent().remove(r._element)
    p.paragraph_format.space_after = Pt(0)
    p.paragraph_format.line_spacing = 1.0
    if align is not None:
        p.alignment = align
    r = p.add_run(text)
    set_run(r, size, bold, font)


def clear_cell(cell):
    for p in list(cell.paragraphs):
        p._element.getparent().remove(p._element)


def add_par(cell, text, size=12, bold=False, font=SONG, indent=True, align=None, after=2, line=1.15):
    p = cell.add_paragraph()
    pf = p.paragraph_format
    pf.space_after = Pt(after)
    pf.line_spacing = line
    if indent:
        pf.first_line_indent = Pt(size * 2)
    if align is not None:
        p.alignment = align
    r = p.add_run(text)
    set_run(r, size, bold, font)
    return p


def insert_before(cell, anchor, text, size=12, indent=True):
    p = cell.add_paragraph()
    anchor._p.addprevious(p._p)
    pf = p.paragraph_format
    pf.space_after = Pt(2)
    pf.line_spacing = 1.15
    if indent:
        pf.first_line_indent = Pt(size * 2)
    r = p.add_run(text)
    set_run(r, size, False, SONG)


def add_image(cell, path, width_cm, caption):
    p = cell.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(1)
    p.add_run().add_picture(path, width=Cm(width_cm))
    cp = cell.add_paragraph()
    cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cp.paragraph_format.space_after = Pt(3)
    r = cp.add_run(caption)
    set_run(r, 9.5, False, SONG, (90, 95, 105))


def set_widths(table, widths):
    table.autofit = False
    for i, w in enumerate(widths):
        if i < len(table.columns):
            table.columns[i].width = Cm(w)
    for row in table.rows:
        for i, w in enumerate(widths):
            if i < len(row.cells):
                row.cells[i].width = Cm(w)


# ---------------- 封面 ----------------
set_cell(t.rows[0].cells[1], "王志远")
set_cell(t.rows[0].cells[4], "3240704204")
set_cell(t.rows[0].cells[6], "2026-11-16")
set_cell(t.rows[1].cells[4], "软件242")
set_cell(t.rows[1].cells[6], "机房")
set_cell(t.rows[3].cells[2], "实验四　网络访问与服务")

# ---------------- 一、实验目的 ----------------
cell = t.rows[7].cells[0]
clear_cell(cell)
add_par(cell, "本实验用 C# + Windows 窗体完成一个简易浏览器与一个定时访问界面，具体目标：")
for text in [
    "（1）能在窗体程序里做网络数据访问；",
    "（2）熟悉 Windows 窗体下 WebBrowser 控件的用法；",
    "（3）掌握定时触发网络访问的实现方式；",
    "（4）明白渲染内核受限这件事，最终都会落到一个具体的用户体验问题上。",
]:
    add_par(cell, text, indent=False)
add_par(cell, "本人参数（S = 4204）：P7 默认主页 = 教务处（https://jwc.ahpu.edu.cn）；P8 必做增强 = "
              "页面缩放与标题显示 + 访问历史下拉。")

# ---------------- 二、实验内容 ----------------
cell = t.rows[9].cells[0]
for p in list(cell.paragraphs):
    if p.text.startswith("除具体内容外"):
        p._element.getparent().remove(p._element)
        break
anchor = cell.paragraphs[0]
intro = [
    "按 P7/P8 参数完成两个界面：",
    "（1）浏览器窗口：主页、前进、后退、停止、刷新、页面属性、页面设置、打印预览、保存；默认主页取 P7（教务处）；",
    "（2）P8 两项增强：地址栏“访问历史下拉” + “页面缩放（50%~200%）与状态栏标题显示”；",
    "（3）定时访问界面：时/分/秒数值控件（秒满 60 进分、分满 60 进时、时满 24 归零）、两个计时器（一个刷新当前时间，一个到点触发）；",
    "（4）异常处理：加载失败给出可重试提示；目标时刻早于当前时间时拒绝启动并说明原因。",
    "个人参数落点与设计决策见表 2-1、表 2-2。",
]
for text in intro:
    insert_before(cell, anchor, text, indent=(not text.startswith("（")))

t21 = cell.tables[0]
rows21 = [
    ["P7 默认主页", "教务处（https://jwc.ahpu.edu.cn）", "启动后自动加载；地址栏、状态栏、标题栏三处一致", "PersonalParameters.cs 第 31–33 行"],
    ["P8① 页面缩放与标题显示", "50%~200% 下拉；状态栏显示文档标题", "缩放下拉框、状态栏“标题：…”；窗口标题含学号", "BrowserForm.cs 第 217–232、121–141 行"],
    ["P8② 访问历史下拉", "最近访问的地址列表（去重、最多 20 条）", "地址栏下拉列表；后退/前进按钮状态同步", "BrowserForm.cs 第 155–170、50–119 行"],
    ["PC2 私有实现约束", "未下发；按“加载失败必须给可重试入口”实现", "加载失败 MessageBox 提供“重试/取消”", "BrowserForm.cs 第 50–119 行"],
]
for i, rowdata in enumerate(rows21, start=1):
    for j, val in enumerate(rowdata):
        set_cell(t21.rows[i].cells[j], val, size=9)
set_widths(t21, [3.0, 3.5, 4.8, 4.8])

t22 = cell.tables[1]
rows22 = [
    ["1", "浏览内核选择", "A：WebBrowser（IE/Trident）　　B：另装 Chromium/WebView2 控件", "A",
     "页面兼容好、脚本支持新；但要引入 NuGet/运行时", "IE 内核旧，部分新版网页显示异常", "BrowserForm.cs 第 50–119 行"],
    ["2", "到点打开方式", "A：Process.Start 系统默认浏览器　　B：程序内 WebBrowser 导航", "A",
     "页面留在程序内，便于控制与截图", "无法控制外部浏览器窗口，取证只能录屏", "TimerForm.cs 第 138–160 行"],
]
for i, rowdata in enumerate(rows22, start=1):
    for j, val in enumerate(rowdata):
        set_cell(t22.rows[i].cells[j], val, size=9, align=(WD_ALIGN_PARAGRAPH.CENTER if j in (0, 3) else None))
set_widths(t22, [0.9, 2.0, 4.3, 1.1, 2.6, 2.6, 2.4])

# ---------------- 三、实验结果及分析 ----------------
cell = t.rows[11].cells[0]
clear_cell(cell)
add_par(cell, "3.1　主界面与 P7 主页", bold=True)
add_par(cell, "主窗体标题为“实验四 简易浏览器 — 3240704204”，启动后自动加载 P7 指定的教务处；"
              "标题栏、地址栏、状态栏三处信息一致（4-1）。工具栏含主页/后退/前进/停止/刷新/定时访问，"
              "菜单含另存为、页面设置、打印预览、页面属性。")
add_image(cell, os.path.join(ASSETS, "fig_browser.png"), 15.2,
          "图 1　P7 主页加载（左）与页面缩放 150% + 状态栏标题（右）")
add_par(cell, "3.2　P8 两项增强", bold=True)
add_par(cell, "访问历史下拉：每次加载完成把地址去重后插入下拉列表，最多保留 20 条；后退/前进按钮随 CanGoBack/CanGoForward 自动启用或禁用。"
              "连续后退 10 次到达历史起点后，“后退”按钮变灰且不再响应（4-3）。")
add_image(cell, os.path.join(ASSETS, "fig_p8.png"), 14.0,
          "图 2　访问历史下拉（左）与连续后退 10 次后“后退”按钮禁用（右）")

add_par(cell, "3.3　定时访问、进位与非法时刻", bold=True)
add_par(cell, "定时窗体默认把目标设为当前时间 +30 秒；启动后锁住网址与时/分/秒，取消后恢复。"
              "秒控件输入 60 时自动归 0 并把分加 1（06 图中目标由 11:18:16 变为 11:19:00）；"
              "目标时刻早于当前时间时拒绝启动并弹出“时刻不合法”说明（4-6）。")
add_image(cell, os.path.join(ASSETS, "fig_timer.png"), 15.2,
          "图 3　定时界面默认值（左）、秒 60→00 进位（中）、过去时刻被拒绝（右）")
add_par(cell, "到点触发：用 35 秒录屏记录“倒计时 → 自动打开系统默认浏览器并访问 P7 网址”的全过程，"
              "浏览器自动打开后地址栏为 https://jwc.ahpu.edu.cn（4-5，录屏 timer_trigger.gif）。")
add_image(cell, os.path.join(SHOTS, "09_triggered.jpg"), 15.0,
          "图 4　到点自动打开默认浏览器（录屏第 60 帧左右）")

add_par(cell, "3.4　加载失败与网络请求", bold=True)
add_par(cell, "WebBrowser 在 DNS 失败时只显示 IE 错误页、不抛异常，因此导航前先做带 2 秒超时的 DNS 预检："
              "失败弹出“加载失败，请检查网络后点击重试”的对话框（4-2，图 5）。用不存在的域名模拟了解析失败；"
              "真实断网时同样走该分支（受公共机房网络限制，未实际断网）。")
add_image(cell, os.path.join(SHOTS, "10_network_error.png"), 9.5,
          "图 5　加载失败提示（带“重试/取消”）")
add_par(cell, "网络请求记录：Resolve-DnsName 显示 jwc.ahpu.edu.cn 先 CNAME 到 www.ahpu.edu.cn，"
              "A 记录为 112.26.59.101；Get-NetTCPConnection 记录到多条与 443 端口的已建立连接；"
              "截图与文本见 evidence/network/network_request.txt、screenshots/12_network_request.png。", size=11)

add_par(cell, "3.5　验收结果", bold=True)
add_par(cell, "4-1 加载 P7 站点：标题“教务处”、地址 jwc.ahpu.edu.cn、状态“加载完成”，三处一致；"
              "4-2 加载失败：友好提示 + 重试，无崩溃；4-3 连续后退 10 次：到起点后按钮禁用、无报错；"
              "4-4 秒 59→60：秒归 0、分加 1、目标时刻同步；4-5 定时触发：录屏 35 秒可见浏览器自动打开；"
              "4-6 过去时刻：拒绝并说明原因；4-7 P8 两项：历史下拉与缩放/标题均可用。7 条全部通过。")

add_par(cell, "3.6　问题记录", bold=True)
for text in [
    "① 秒控件最大值设为 59 时无法体现“60 进 1”：NumericUpDown 会直接把 60 钳成 59。定位：数值控件的 Maximum 属性在赋值阶段就截断，"
    "ValueChanged 根本收不到 60。修复：把 Maximum 设为 60（时设为 24），在 ValueChanged 里检测 60/24 后归零并进位，"
    "用一个 adjusting 标志防止递归（TimerForm.cs 第 37–70 行），验证见 06_carry.png。",
    "② WebBrowser 加载失败不抛异常：断网/域名不存在时控件只会显示 IE 错误页，程序无法感知。修复：导航前用 "
    "Task.Run(Dns.GetHostEntry) + 2 秒超时做预检，失败即弹出可重试对话框（BrowserForm.cs 第 50–119 行），验证见 10_network_error.png。",
    "③ 子框架的进度事件覆盖“加载完成”：页面含 iframe 时 ProgressChanged 在 DocumentCompleted 之后仍会触发，状态栏被改回“加载中 0%”。"
    "修复：加 documentCompleted 标志，完成后忽略后续进度事件（BrowserForm.cs 第 121–160 行）。",
    "④ IE 内核渲染限制：WebBrowser 默认以旧文档模式渲染，部分新页面 CSS/脚本不生效，页面样式与新浏览器有差异。"
    "这是内核限制而非代码缺陷；可用 FEATURE_BROWSER_EMULATION=11001 提升到 IE11 模式（按 exe 名写注册表、需重启进程），"
    "更合适的替代是 WebView2。",
]:
    add_par(cell, text, indent=False, size=11)

# ---------------- 四、小结/心得/思路/思考题 ----------------
cell = t.rows[13].cells[0]
clear_cell(cell)
add_par(cell, "（一）实验小结", bold=True)
add_par(cell, "完成了浏览器窗口、P8 两项增强、定时访问界面与异常处理；P7 主页、P8 历史下拉与缩放/标题均已落实，"
              "7 条公开验收用例自测通过，定时触发有 35 秒录屏、加载失败与网络请求有截图与文本记录。")
add_par(cell, "（二）心得体会", bold=True)
add_par(cell, "这次最深的体会是“控件不报错不等于成功”：WebBrowser 加载失败时安静地显示错误页，必须自己做预检才拿得到失败信号；"
              "数值控件的 Maximum 也会在赋值阶段悄悄钳位，进位逻辑得自己接管。另外，到点打开外部浏览器虽然简单，"
              "但取证只能靠录屏，不如在程序内打开好控制——这就是设计决策里要写清代价的地方。")
add_par(cell, "（三）设计思路", bold=True)
add_par(cell, "浏览器窗体只负责导航、历史与状态同步：地址栏、后退/前进、缩放下拉都映射到 WebBrowser 的属性和事件；"
              "定时窗体把“显示时间”和“到点触发”拆成两个 Timer，避免一个计时器同时承担刷新与判定；"
              "参数集中在 PersonalParameters，P7/P8 全部由 S=4204 计算。")
add_par(cell, "（四）思考题", bold=True)
add_par(cell, "1. 再选一个最有用的功能：我会加“页面内查找（Ctrl+F）”。WebBrowser 没有现成查找接口，但可以遍历 "
              "Document.All 的文本节点或用 IHTMLDocument2 的 body.innerText 做字符串定位，再把命中位置滚动到可见区域；"
              "它比再加一个导航按钮更贴近日常浏览，也能复用现有地址栏/状态栏的反馈。")
add_par(cell, "2. 渲染内核：WebBrowser 用的是 IE 的 Trident/MSHTML 内核。FEATURE_BROWSER_EMULATION 位于 "
              "HKCU（或 HKLM）\\Software\\Microsoft\\Internet Explorer\\Main\\FeatureControl\\FEATURE_BROWSER_EMULATION，"
              "按可执行文件名写 DWORD：11001 强制 IE11 edge 模式、11000 按 DOCTYPE 决定；作用范围是当前用户/当前进程名，"
              "在进程启动时读取，所以改完要重启程序。现在更合适的替代是 WebView2（Chromium 内核）。")
add_par(cell, "3. 目标时刻落在程序没运行时：可用 Windows 任务计划程序（schtasks / 任务计划程序 GUI）设置一次性或每日触发器，"
              "到点启动本程序并带 URL 参数；也可写开机启动项/注册表 Run 或 Windows 服务。限制：任务计划需要相应权限、"
              "服务不能直接弹交互界面（会话隔离），程序未运行/错过触发要有补偿策略。")

# ---------------- 附录 A ----------------
header_a = None
header_b = []
for p in doc.paragraphs:
    if p.text.startswith("实验编号："):
        if header_a is None:
            header_a = p
        else:
            header_b.append(p)
for p, name in [(header_a, "A")] + [(p, "B") for p in header_b]:
    if p is None:
        continue
    for r in list(p.runs):
        r._element.getparent().remove(r._element)
    r = p.add_run("实验编号：实验四　　学号：3240704204　　姓名：王志远")
    set_run(r, 12)

for p in doc.paragraphs:
    if p.text.startswith("自测结论"):
        for r in list(p.runs):
            r._element.getparent().remove(r._element)
        r = p.add_run("自测结论：")
        set_run(r, 12, True)
        r = p.add_run("☑ 全部通过　　□ 部分通过（未通过项已列入修复计划）")
        set_run(r, 12)
    elif p.text.startswith("签名："):
        for r in list(p.runs):
            r._element.getparent().remove(r._element)
        r = p.add_run("签名：王志远　　日期：2026-11-16")
        set_run(r, 12)

ta = doc.tables[1]
a_rows = [
    ["4-1", "公开", "加载 P7 指定站点，标题/地址/状态一致", "标题“教务处”、地址 jwc.ahpu.edu.cn、状态“加载完成”", "☑是 □否", "screenshots/01", "—"],
    ["4-2", "公开", "断网后点“转到”给出可重试提示、不崩溃", "不存在域名模拟 DNS 失败：弹出“加载失败”+重试/取消", "☑是 □否", "screenshots/10", "实际断网未做（公共机房网络）"],
    ["4-3", "公开", "连续后退 10 次，到起点后按钮失效/禁用", "后退到起点后按钮变灰且不响应，无报错", "☑是 □否", "screenshots/04", "—"],
    ["4-4", "公开", "秒位 59 增至 60，正确进位且界面同步", "秒 60→00、分 +1，目标时刻同步为 11:19:00", "☑是 □否", "screenshots/06", "—"],
    ["4-5", "公开", "设定 30 秒后触发，录像可见浏览器自动打开", "35 秒录屏（70 帧）记录倒计时到自动打开 Edge", "☑是 □否", "evidence/recording/timer_trigger.gif", "—"],
    ["4-6", "公开", "设定早于当前时刻时拒绝启动并说明原因", "弹窗“时刻不合法”：目标 00:00:00 早于 11:17:59", "☑是 □否", "screenshots/07", "—"],
    ["4-7", "公开", "P8 两项增强均实现且可用", "历史下拉、缩放 50~200% 与状态栏标题均可用", "☑是 □否", "screenshots/02、03", "—"],
    ["PC2", "私有", "实现约束（未下发）", "按“加载失败给可重试入口”实现", "□是 □否", "BrowserForm.cs 第 50–119 行", "任务书下发后复核"],
    ["PC1-1", "私有", "课堂下发（个人任务书）", "本机已覆盖 4-1~4-7，官方用例现场执行", "□是 □否", "—", "待任务书下发后补测"],
    ["PC1-2", "私有", "课堂下发（个人任务书）", "本机已覆盖 4-1~4-7，官方用例现场执行", "□是 □否", "—", "待任务书下发后补测"],
    ["PC1-3", "私有", "课堂下发（个人任务书）", "本机已覆盖 4-1~4-7，官方用例现场执行", "□是 □否", "—", "待任务书下发后补测"],
]
for i, rowdata in enumerate(a_rows, start=1):
    if i >= len(ta.rows):
        break
    for j, val in enumerate(rowdata):
        set_cell(ta.rows[i].cells[j], val, size=8.5, align=(WD_ALIGN_PARAGRAPH.CENTER if j in (0, 1, 4) else None))

# ---------------- 附录 B ----------------
tb2 = doc.tables[2]
dev_rows = [
    ["11-16 10:50–11:00", "读指导书、按 S=4204 计算 P7/P8", "—", "P7 教务处、P8 缩放+历史下拉，手算核对", "commit 1"],
    ["11-16 11:00–11:20", "建工程、写浏览器窗体（导航/历史/缩放/状态）", "WebBrowser 加载失败不抛异常", "加 DNS 预检 + 重试提示", "commit 2"],
    ["11-16 11:20–11:35", "写定时窗体（时分秒/两个计时器/锁定/进位）", "NumericUpDown 把 60 钳位", "Maximum 设 60/24，ValueChanged 里进位", "commit 3"],
    ["11-16 11:35–11:50", "取证：截图、35 秒录屏、网络记录", "键盘/焦点导致自动化不稳定", "改用 Win32+UIA 定位窗口与控件", "commit 4"],
    ["11-16 11:50–12:10", "按学院模板写报告、打包、推送", "—", "模板填表 + PDF/GIF 校验", "commit 5"],
]
for i, rowdata in enumerate(dev_rows, start=1):
    if i >= len(tb2.rows):
        break
    for j, val in enumerate(rowdata):
        set_cell(tb2.rows[i].cells[j], val, size=9)
set_widths(tb2, [3.0, 4.0, 3.4, 4.4, 1.8])

tb3 = doc.tables[3]
anchor_rows = [
    ["设计草图签收时间", "本实验不要求草图，无", "—", "—"],
    ["远端首次推送时间", "2026-11-16 11:5x（首次推送）", "GitHub 提交页可查", "☑是 □否"],
    ["远端末次推送时间", "git-log.txt 的 pushed_at", "GitHub 服务端 pushed_at", "☑是 □否"],
    ["现场改造起止时间", "未进行（课内现场环节）", "—", "—"],
    ["原始素材创建时间范围", "2026-11-16 11:00–11:50", "文件时间戳", "☑是 □否"],
]
for i, rowdata in enumerate(anchor_rows, start=1):
    for j, val in enumerate(rowdata):
        set_cell(tb3.rows[i].cells[j], val, size=9)

tb4 = doc.tables[4]
tool_rows = [
    ["1", "A 查询型", "核对 WebBrowser.DocumentCompleted 事件触发时机", "Microsoft Learn：DocumentCompleted 在文档加载完成后触发",
     "确认用它更新标题/地址/状态", "与实现一致（BrowserForm.cs 第 121 行）", "能当场重述"],
    ["2", "A 查询型", "确认 FEATURE_BROWSER_EMULATION 的值与注册表位置", "Microsoft Learn：11001=IE11 强制 edge 模式；HKCU/HKLM\\...\\FeatureControl\\FEATURE_BROWSER_EMULATION\\<exe>",
     "写清渲染内核限制与绕开办法", "用于思考题 2", "能当场重述"],
    ["3", "常规工具", "编译与构建", "Visual Studio 2022 / MSBuild", "生成可执行程序", "—", "可当场操作"],
    ["4", "常规工具", "版本库与远端", "Git + GitHub", "提交历史与时间戳", "—", "可当场操作"],
    ["5", "常规工具", "截图/录屏/数据分析", "PowerShell、Python(Pillow)、LibreOffice", "截图、GIF、报告排版", "—", "可当场操作"],
]
for i, rowdata in enumerate(tool_rows, start=1):
    for j, val in enumerate(rowdata):
        set_cell(tb4.rows[i].cells[j], val, size=8.5)
set_widths(tb4, [0.9, 1.2, 3.2, 4.3, 2.5, 2.4, 1.6])

note = doc.add_paragraph()
note.paragraph_format.space_before = Pt(6)
r = note.add_run("补充说明：除上述 A 级查询与常规工具外，本次完成过程中还使用了 AI 编程助手（C 生成型 / D 代理型），"
                 "按指导书 8.1 属 C/D 级、不在允许范围内，特此如实申报。")
set_run(r, 10.5)

# 让“三、实验结果及分析”和附录 B 的“三、工具使用情况申报”各起一页，避免表格跨页
for tbl in doc.tables:
    for row in tbl.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                if "实验结果及分析" in p.text and "三、" in p.text:
                    p.paragraph_format.page_break_before = True
for p in doc.paragraphs:
    if p.text.strip().startswith("三、工具使用情况申报"):
        p.paragraph_format.page_break_before = True

doc.save(OUT)
print("saved", OUT)

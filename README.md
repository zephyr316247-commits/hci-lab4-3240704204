# 人机交互的软件工程方法 · 实验四（网络访问与服务）

- 学号：3240704204
- 姓名：王志远
- 班级：软件242
- 日期：2026-11-16

## 参数落点

| 项 | 取值 |
| --- | --- |
| S | 4204 |
| P7（S mod 6 = 4） | 教务处，https://jwc.ahpu.edu.cn |
| P8（(S/2) mod 3 = 2） | 页面缩放与标题显示；访问历史下拉 |

## 工程结构

```
src/
  实验4_3240704204.sln
  Lab4_3240704204/
    Program.cs
    PersonalParameters.cs
    BrowserForm.cs / BrowserForm.Designer.cs
    TimerForm.cs / TimerForm.Designer.cs
evidence/
  screenshots/   运行截图（01~12）
  recording/     35 秒触发录屏 GIF + 原始帧
  network/       DNS / TCP 443 网络请求记录
  scripts/       取证与报告生成脚本
report/          实验报告（docx / doc）
```

## 运行

用 Visual Studio 2022 打开 `src/实验4_3240704204.sln` 并生成（.NET Framework 4.8），
或直接运行 `src/Lab4_3240704204/bin/Release/实验4_3240704204.exe`。

- Ctrl+L：定位地址栏；Ctrl+T：打开定时访问
- 定时访问：时/分/秒允许 60/60/24 进位与归零，启动后锁定输入
- 到点后调用系统默认浏览器打开目标网址
- 加载失败（DNS 预检 2 秒超时）弹出可重试提示
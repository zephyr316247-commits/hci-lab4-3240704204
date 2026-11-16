@echo off
title 网络请求记录
echo ==== DNS 解析 jwc.ahpu.edu.cn ====
nslookup jwc.ahpu.edu.cn
echo.
echo ==== 与 443 端口已建立的连接 ====
powershell -NoProfile -Command "Get-NetTCPConnection -State Established -RemotePort 443 | Select-Object RemoteAddress,RemotePort,OwningProcess | Format-Table -AutoSize"
echo.
echo ==== 程序进程 ====
tasklist /fi "imagename eq 实验4_3240704204.exe"
pause
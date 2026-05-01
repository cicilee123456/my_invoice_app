@echo off
REM 發票App 數據庫快速設置腳本

echo =========================================
echo 發票App - 數據庫初始化
echo =========================================
echo.

REM 檢查 XAMPP MySQL 是否在 Path 中
where mysql >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [!] 找不到 MySQL，請確認 XAMPP 已安裝並配置到系統路徑
    echo 或嘗試手動路徑：C:\xampp\mysql\bin\
    pause
    exit /b 1
)

echo [✓] 找到 MySQL
echo.

REM 取得當前腳本所在目錄
set SCRIPT_DIR=%~dp0php

echo [*] 讀取 SQL 初始化文件...
if not exist "%SCRIPT_DIR%\init_database.sql" (
    echo [!] 找不到 init_database.sql
    echo     路徑: %SCRIPT_DIR%\init_database.sql
    pause
    exit /b 1
)

echo [✓] 找到初始化文件
echo.

echo [*] 執行 SQL 初始化腳本...
mysql -u root < "%SCRIPT_DIR%\init_database.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =========================================
    echo [✓] 數據庫初始化成功！
    echo =========================================
    echo.
    echo 接下來請：
    echo 1. 訪問 http://localhost/phpmyadmin
    echo 2. 驗證 invoice_db 數據庫和表結構
    echo 3. 確認 winning_numbers 表中有中獎號碼
    echo 4. 在 Flutter 應用中測試對獎功能
    echo.
    echo 詳細信息請參考 DATABASE_SETUP.md
) else (
    echo.
    echo [!] 初始化失敗
    echo    請檢查：
    echo    - XAMPP MySQL 服務是否正在運行
    echo    - 是否有正確的 MySQL 訪問權限
    echo    - SQL 文件是否完整無誤
)

pause

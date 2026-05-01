# 發票App 數據庫遷移說明

## 📋 概要

你的發票App已從 **JSON 文件存儲** 遷移到 **MySQL 數據庫存儲**，現在使用以下兩個表進行對獎：
- `invoice_db.invoices` - 存儲用戶的發票數據
- `invoice_db.winning_numbers` - 存儲官方中獎號碼

---

## 🚀 快速開始（3步）

### 第1步：初始化數據庫
**運行以下腳本之一：**

#### 方案A：自動腳本（推薦 Windows 用戶）
1. 確保 XAMPP MySQL 已啟動
2. 雙擊 `setup_database.bat`
3. 等待完成

#### 方案B：手動使用 phpMyAdmin
1. 訪問 http://localhost/phpmyadmin
2. 點擊上方「SQL」選項卡
3. 複製 `php/init_database.sql` 全部內容
4. 粘貼到 SQL 輸入框
5. 點擊「執行」

#### 方案C：命令行
```bash
cd C:\xampp\mysql\bin
mysql -u root < C:\Users\liyachun\my_invoice_app\php\init_database.sql
```

### 第2步：驗證數據庫

在 phpMyAdmin 中查看：
- **發票表**: http://localhost/phpmyadmin/index.php?route=/sql&pos=0&db=invoice_db&table=invoices
- **中獎號碼表**: http://localhost/phpmyadmin/index.php?route=/sql&pos=0&db=invoice_db&table=winning_numbers

應該看到 3 條預設中獎號碼：
- WU90043278 (特獎)
- AB12345678 (特獎)
- CD87654321 (特獎)

### 第3步：重啟應用並測試

1. 在 Flutter 中按 **⚡ (熱啟動)**
2. 掃描或添加發票
3. 點擊右上角 **獎杯圖標** 進行對獎

---

## 📁 新增/修改文件

### 新增文件：
```
php/
  ├── db_config.php           ← 數據庫連接配置
  └── init_database.sql       ← 數據庫初始化腳本

setup_database.bat            ← Windows 一鍵初始化腳本
DATABASE_SETUP.md             ← 詳細設置文檔
```

### 修改文件：
```
php/
  └── invoices.php            ← 改為使用 PDO 連接數據庫

lib/
  ├── models/
  │   └── invoice.dart        ← 新增 prizeLevel 字段
  ├── services/
  │   └── api_service.dart    ← 改進日誌記錄
  └── pages/
      └── list_page.dart      ← 顯示獎級信息
```

---

## 🔧 關鍵改動

### PHP 後端
- **invoices.php**: 使用 MySQL 數據庫代替 JSON 文件
  - GET: 從 `invoices` 表查詢所有發票
  - POST action=save: 保存/更新發票
  - POST action=check_winning: **INNER JOIN** 兩表查詢中獎發票
  - POST action=delete: 刪除發票
  - DELETE: 備選刪除方式

### 對獎邏輯（核心改進）
```sql
-- 舊邏輯：在內存中硬編碼的中獎號碼
SELECT * FROM invoices WHERE number IN ('WU90043278', 'AB12345678', ...)

-- 新邏輯：數據庫查詢
SELECT i.* FROM invoices i
INNER JOIN winning_numbers w ON i.invoice_number = w.invoice_number
```

### Flutter 模型
- `Invoice.prizeLevel`: 新增可選字段，用於顯示獎級（特獎、頭獎等）

---

## 🎯 對獎流程

```
用戶點擊「一鍵對獎」
    ↓
Flutter 發送 POST 請求: { "action": "check_winning" }
    ↓
PHP 執行 SQL JOIN 查詢
    ↓
返回匹配的發票列表（包含獎級）
    ↓
顯示「中獎了！🎉」對話框
```

---

## 📊 數據庫表結構

### invoices (發票表)
```sql
CREATE TABLE invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,      -- 發票號碼
    period VARCHAR(30) DEFAULT '115年03-04月',      -- 期數
    amount INT DEFAULT 0,                            -- 金額
    invoice_date VARCHAR(20),                        -- 發票日期
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 建立時間
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP   -- 更新時間
);
```

### winning_numbers (中獎號碼表)
```sql
CREATE TABLE winning_numbers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,  -- 中獎發票號碼
    period VARCHAR(30),                          -- 期數
    prize_level VARCHAR(20),                     -- 獎級（特獎、頭獎等）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔐 數據庫連接設置

文件：`php/db_config.php`

```php
define('DB_HOST', 'localhost');      // XAMPP 伺服器
define('DB_USER', 'root');           // XAMPP 預設用戶
define('DB_PASSWORD', '');           // XAMPP 預設無密碼
define('DB_NAME', 'invoice_db');     // 數據庫名稱
```

如果需要修改，請更新上述文件。

---

## ⚠️ 常見問題

### Q: 對獎返回 400 錯誤？
**A:** 
- 檢查 XAMPP MySQL 是否正在運行
- 確認 `db_config.php` 中的連接設置正確
- 查看 XAMPP PHP 錯誤日誌

### Q: 看不到中獎號碼？
**A:**
- 確認 `winning_numbers` 表已初始化
- 檢查發票號碼是否完全匹配（區分大小寫）
- 在 phpMyAdmin 中手動測試 SQL 查詢

### Q: 舊的 invoices.json 還會用到嗎？
**A:**
- 不會。所有數據現在存儲在 MySQL 中
- 可以刪除 `php/invoices.json`（備份一份以防萬一）

### Q: 如何添加新的中獎號碼？
**A:**
在 phpMyAdmin 中執行：
```sql
INSERT INTO winning_numbers (invoice_number, period, prize_level) 
VALUES ('新號碼', '115年03-04月', '獎級名稱');
```

---

## 🧪 測試對獎功能

### 步驟 1：添加測試發票
在 phpMyAdmin 執行：
```sql
INSERT INTO invoices (invoice_number, period, amount, invoice_date) VALUES 
('AB12345678', '115年03-04月', 500, '2026/04/15'),
('CD87654321', '115年03-04月', 299, '2026/04/20'),
('XX00000001', '115年03-04月', 150, '2026/04/25');
```

### 步驟 2：在應用中對獎
- 點擊「獎杯」按鈕
- 應看到前兩個號碼標記為「中獎」
- 第三個號碼不會顯示

---

## 📝 備註

- 所有中文使用 UTF-8 編碼
- 對獎基於 INNER JOIN，只顯示兩個表都有的記錄
- 可在 XAMPP 的 `apache/logs/error.log` 中查看 PHP 調試信息
- 發票號碼區分大小寫

---

## 需要幫助？

1. 查看 [DATABASE_SETUP.md](./DATABASE_SETUP.md) 的詳細說明
2. 檢查 XAMPP 控制面板中 MySQL 是否正在運行
3. 查看 phpMyAdmin 中是否成功創建了 `invoice_db` 數據庫

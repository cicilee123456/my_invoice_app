# 發票App 數據庫設置指南

## 第一步：初始化數據庫

### 方法1：使用 phpMyAdmin（推薦）

1. **打開 phpMyAdmin**
   - 訪問 http://localhost/phpmyadmin

2. **執行 SQL 腳本**
   - 點擊「SQL」選項卡（或「SQL」按鈕）
   - 複製 [init_database.sql](./init_database.sql) 中的所有內容
   - 粘貼到輸入框
   - 點擊「執行」

### 方法2：使用命令行

```bash
cd C:\xampp\mysql\bin
mysql -u root < C:\Users\liyachun\my_invoice_app\php\init_database.sql
```

---

## 第二步：驗證數據庫設置

### 在 phpMyAdmin 中驗證

1. **查看 invoices 表**
   - 訪問 http://localhost/phpmyadmin/index.php?route=/sql&pos=0&db=invoice_db&table=invoices
   - 應該看到空表或已存在的發票數據

2. **查看 winning_numbers 表**
   - 訪問 http://localhost/phpmyadmin/index.php?route=/sql&pos=0&db=invoice_db&table=winning_numbers
   - 應該看到3條中獎號碼：
     - WU90043278 (特獎)
     - AB12345678 (特獎)
     - CD87654321 (特獎)

---

## 第三步：測試對獎功能

### 1. 添加測試發票

在 phpMyAdmin 中執行：
```sql
INSERT INTO invoices (invoice_number, period, amount, invoice_date) VALUES 
('AB12345678', '115年03-04月', 500, '2026/04/15'),
('CD87654321', '115年03-04月', 299, '2026/04/20'),
('XX00000001', '115年03-04月', 150, '2026/04/25');
```

### 2. 在 Flutter 應用中對獎

- 打開應用
- 進入「發票清單」頁面
- 點擊右上角的獎杯圖標（一鍵對獎）
- 應該看到：
  - AB12345678 中特獎 ✓
  - CD87654321 中特獎 ✓
  - XX00000001 沒中 ✗

---

## 第四步：自定義中獎號碼

在 phpMyAdmin 中修改 winning_numbers 表：

```sql
-- 添加新的中獎號碼
INSERT INTO winning_numbers (invoice_number, period, prize_level) VALUES 
('新發票號碼', '期數', '獎級');

-- 例如：
INSERT INTO winning_numbers (invoice_number, period, prize_level) VALUES 
('AB00000001', '115年03-04月', '三獎'),
('CD00000002', '115年03-04月', '四獎');
```

---

## 第五步：數據庫連接確認

確保 [db_config.php](./db_config.php) 中的設置正確：

```php
define('DB_HOST', 'localhost');      // XAMPP 伺服器地址
define('DB_USER', 'root');            // XAMPP 默認用戶
define('DB_PASSWORD', '');            // XAMPP 默認無密碼
define('DB_NAME', 'invoice_db');      // 數據庫名稱
```

---

## 常見問題

### 問題：連接失敗 - "數據庫連接失敗"

**解決方案：**
1. 確認 XAMPP MySQL 已啟動
2. 確認數據庫 invoice_db 已創建
3. 檢查 db_config.php 中的認證信息是否正確
4. 查看 XAMPP 的 PHP 錯誤日誌

### 問題：對獎返回空結果

**解決方案：**
1. 確認 winning_numbers 表中有數據
2. 確認 invoices 表中有發票數據
3. 確保發票號碼完全匹配（區分大小寫）
4. 在 phpMyAdmin 中測試 SQL 查詢：
   ```sql
   SELECT i.* FROM invoices i
   INNER JOIN winning_numbers w ON i.invoice_number = w.invoice_number;
   ```

---

## 數據庫表結構

### invoices (發票表)
| 欄位 | 類型 | 說明 |
|-----|------|------|
| id | INT | 主鍵，自動遞增 |
| invoice_number | VARCHAR(50) | 發票號碼（唯一） |
| period | VARCHAR(30) | 開獎期數 |
| amount | INT | 金額 |
| invoice_date | VARCHAR(20) | 發票日期 |
| created_at | TIMESTAMP | 創建時間 |
| updated_at | TIMESTAMP | 更新時間 |

### winning_numbers (中獎號碼表)
| 欄位 | 類型 | 說明 |
|-----|------|------|
| id | INT | 主鍵，自動遞增 |
| invoice_number | VARCHAR(50) | 中獎發票號碼（唯一） |
| period | VARCHAR(30) | 開獎期數 |
| prize_level | VARCHAR(20) | 獎級（特獎、頭獎等） |
| created_at | TIMESTAMP | 創建時間 |

---

## 備註

- 所有中文數據都使用 UTF-8 編碼存儲
- 對獎是通過 INNER JOIN 實現的，只返回同時存在於兩個表中的記錄
- 可以在 XAMPP 的 PHP 錯誤日誌中查看詳細的調試信息

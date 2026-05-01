# 📋 發票小助手 - 完整項目說明

**開發日期**: 2026年5月1日  
**版本**: 1.0.0  
**框架**: Flutter + PHP + MySQL  
**用途**: 掃描發票、管理發票清單、自動對獎

---

## 📊 項目架構

```
my_invoice_app/
├── lib/                          # Flutter Dart 程式碼
│   ├── main.dart                 # 應用入口
│   ├── models/
│   │   └── invoice.dart          # 發票數據模型
│   ├── pages/
│   │   ├── list_page.dart        # 發票清單頁面
│   │   ├── scan_page.dart        # 掃描發票頁面
│   │   └── debug_page.dart       # 調試頁面
│   ├── services/
│   │   └── api_service.dart      # API 服務層
│   ├── utils/                    # 工具函數
│   ├── core/                     # 核心邏輯
│   ├── features/                 # 功能模塊
│   └── shared/                   # 共享資源
├── php/                          # 後端 PHP 代碼
│   ├── invoices.php              # ⭐ 主要 API 文件
│   ├── db_config.php             # 數據庫配置
│   ├── init_database.sql         # 數據庫初始化腳本
│   ├── save_invoice.php          # 舊的儲存文件（已棄用）
│   ├── delete.php                # 舊的刪除文件（已棄用）
│   ├── get_invoices.php          # 舊的讀取文件（已棄用）
│   └── invoices.json             # 舊的 JSON 數據文件（已棄用）
├── android/                      # Android 特定配置
├── ios/                          # iOS 特定配置
├── pubspec.yaml                  # Flutter 依賴配置
├── analysis_options.yaml         # 代碼分析選項
├── DATABASE_SETUP.md             # 數據庫設置說明
├── MIGRATION_GUIDE.md            # 數據遷移指南
└── PROJECT_OVERVIEW.md           # 本文檔

```

---

## 🚀 功能概述

| 功能 | 說明 | 狀態 |
|-----|------|------|
| 📸 掃描發票 | 使用手機攝像頭拍攝發票，AI 自動識別號碼、金額、日期 | ✅ 完成 |
| 📋 發票清單 | 查看所有已保存的發票 | ✅ 完成 |
| 🎯 一鍵對獎 | 向數據庫查詢，自動對比中獎號碼 | ✅ 完成 |
| 🗑️ 刪除發票 | 從清單中刪除不需要的發票 | ✅ 完成 |
| 💰 發票管理 | 添加、修改、查詢發票 | ✅ 完成 |
| 🎊 獎級顯示 | 對獎結果中顯示具體獎級（特獎、頭獎等） | ✅ 完成 |

---

## 📱 Flutter 前端結構

### 1. main.dart - 應用入口
```dart
// 應用配置
title: '發票小助手'
theme: Colors.pink (粉紅色主題)
initialRoute: '/scan'
路由配置:
  - /scan   → ScanPage (掃描發票)
  - /list   → ListPage (發票清單)
  - /debug  → DebugPage (調試信息)
```

**關鍵特點**:
- 不顯示 Debug Banner
- 粉紅色主題設計

---

### 2. models/invoice.dart - 數據模型

```dart
class Invoice {
  final String invoiceNumber;      // 發票號碼 (如: AB12345678)
  final String period;             // 開獎期數 (如: 115年03-04月)
  final int amount;                // 消費金額 (單位: 元)
  final String invoiceDate;        // 消費日期 (如: 2026/04/30)
  final String? prizeLevel;        // 🆕 獎級 (如: 特獎、頭獎)
}
```

**JSON 映射**:
```json
{
  "invoice_number": "AB12345678",
  "period": "115年03-04月",
  "amount": 500,
  "invoice_date": "2026/04/30",
  "prize_level": "特獎"  // 對獎時才有此字段
}
```

---

### 3. services/api_service.dart - API 服務層

#### 基礎配置
```dart
baseUrl = 'http://10.0.2.2/invoice_scanner'
useMockData = false  // 使用真實 XAMPP API
```

#### 核心方法

##### ✅ fetchInvoices() - 獲取所有發票
```dart
// 請求
GET /invoices.php

// 回應
[
  { "invoice_number": "AB12345678", "amount": 500, ... },
  { "invoice_number": "CD87654321", "amount": 299, ... },
  ...
]
```

##### ✅ checkWinningInvoices() - 對獎
```dart
// 請求
POST /invoices.php
Content-Type: application/json
{ "action": "check_winning" }

// 回應 (成功)
[
  {
    "invoice_number": "AB12345678",
    "prize_level": "特獎",
    "amount": 500,
    "invoice_date": "2026/04/30"
  },
  ...
]

// 回應 (無中獎)
[]
```

##### ✅ deleteInvoice(invoiceNumber) - 刪除發票
```dart
// 請求
POST /invoices.php
{
  "action": "delete",
  "invoice_number": "AB12345678"
}

// 回應
{ "success": true, "message": "刪除成功" }
```

##### ✅ saveInvoice(invoice) - 保存發票
```dart
// 請求
POST /invoices.php
{
  "invoice_number": "AB12345678",
  "period": "115年03-04月",
  "amount": 500,
  "invoice_date": "2026/04/30"
}

// 回應
{ "success": true, "message": "儲存成功" }
```

---

### 4. pages/list_page.dart - 發票清單頁面

#### 功能
- 顯示所有發票列表
- 實時刷新
- 快速操作按鈕

#### UI 結構
```
┌─ AppBar
│  ├─ 標題: "我的發票清單"
│  ├─ 按鈕: 🏆 一鍵對獎
│  └─ 按鈕: 📷 掃描新發票
├─ Body
│  └─ ListView
│     └─ 發票卡片 (可滑動刪除)
│        ├─ 發票號碼
│        ├─ 金額 | 日期
│        └─ 🗑️ 刪除按鈕
```

#### 對獎對話框
```
┌─ Dialog: "中獎了！🎉"
├─ 中獎發票列表
│  └─ 發票 #1
│     ├─ 🧾 發票號碼: AB12345678
│     ├─ 💰 消費金額: $500
│     ├─ 📅 消費日期: 2026/04/30
│     └─ 🎊 獲得獎別: 特獎 (紅色粗體)
└─ 按鈕: [確定]
```

#### 核心代碼片段
```dart
// 對獎按鈕
IconButton(
  icon: const Icon(Icons.emoji_events, color: Colors.amber),
  onPressed: () async {
    final winners = await ApiService.checkWinningInvoices();
    // 顯示結果對話框
  }
)

// 删除按鈕
IconButton(
  icon: const Icon(Icons.delete_outline, color: Colors.red),
  onPressed: () async {
    bool ok = await ApiService.deleteInvoice(inv.invoiceNumber);
    _loadData(); // 刷新列表
  }
)
```

---

### 5. pages/scan_page.dart - 掃描發票頁面

#### 功能
- 🤳 拍照或選擇圖片
- 🔤 AI 自動識別發票號碼
- 💯 智慧修正誤識別
- 💾 保存到數據庫

#### AI 識別邏輯

##### 文本提取
```dart
// 使用 Google ML Kit 進行 OCR 文本識別
RecognizedText recognizedText = await textRecognizer.processImage(image);
String fullContent = recognizedText.text
  .toUpperCase()
  .replaceAll(' ', '')
  .replaceAll('-', '');
```

##### 智慧提取
```dart
// 1. 提取發票號碼 (正則: 2英+7-8數字)
RegExp numReg = RegExp(r'[A-Z0-9]{2}\d{7,8}');
String number = numReg.stringMatch(fullContent);

// 2. 提取日期 (格式: YYYY/MM/DD 或 YYYY-MM-DD)
RegExp dateReg = RegExp(r'\d{3,4}[/\-]\d{2}[/\-]\d{2}');
String date = dateReg.stringMatch(fullContent);

// 3. 提取金額 (過濾年份、過小的值)
int amount = matches
  .where((n) => n > 10 && n < 90000 && n != 2026)
  .max();
```

##### 誤識別修正
```dart
String _aiSmartFix(String input) {
  String clean = input.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  // 常見誤認修正
  // 0 ↔ O, 1 ↔ I, 8 ↔ B, 5 ↔ S
  String letters = clean.substring(0, 2)
    .replaceAll('0', 'O')
    .replaceAll('1', 'I')
    .replaceAll('8', 'B')
    .replaceAll('5', 'S');
  String digits = clean.substring(2, 10)
    .replaceAll('O', '0')
    .replaceAll('I', '1')
    .replaceAll('B', '8')
    .replaceAll('S', '5');
  return letters + digits;
}
```

#### UI 元素
```
┌─ AppBar: "掃描發票"
├─ Image 顯示區 (預覽已選擇的照片)
├─ Form 輸入區
│  ├─ 📄 發票號碼 (自動填充)
│  ├─ 💰 消費金額 (自動填充)
│  ├─ 🏪 店家名稱 (手動填入)
│  └─ 📅 消費日期 (自動填充)
├─ 按鈕區
│  ├─ [📷 拍照]
│  ├─ [🖼️ 相冊]
│  └─ [💾 儲存]
```

---

### 6. pubspec.yaml - 依賴配置

```yaml
dependencies:
  flutter: ^3.x
  http: ^1.1.0              # HTTP 網絡請求
  image_picker: ^1.0.4      # 照片選擇
  google_mlkit_text_recognition: ^0.11.0  # OCR 文本識別
  image: ^4.1.3             # 圖像處理

dev_dependencies:
  flutter_test
  flutter_lints: ^6.0.0     # 代碼規範檢查
```

---

## 🔌 PHP 後端結構

### 1. db_config.php - 數據庫配置

```php
// 連接參數
DB_HOST = 'localhost'           // XAMPP 本地伺服器
DB_USER = 'root'                // XAMPP 默認用戶
DB_PASSWORD = ''                // XAMPP 默認無密碼
DB_NAME = 'invoice_db'          // 數據庫名稱

// 連接使用 PDO (PHP Data Objects)
charset = 'utf8mb4'             // Unicode 字符集，支持中文
```

**連接示例**:
```php
$pdo = new PDO(
  'mysql:host=localhost;dbname=invoice_db;charset=utf8mb4',
  'root',
  '',
  [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
  ]
);
```

---

### 2. invoices.php - 主要 API 文件 ⭐

#### 請求類型

##### GET 請求 - 獲取所有發票
```
GET /invoices.php

回應 (200 OK):
[
  {
    "id": 1,
    "invoice_number": "AB12345678",
    "period": "115年03-04月",
    "amount": 500,
    "invoice_date": "2026/04/30"
  },
  ...
]
```

##### POST 請求 - 對獎/儲存/刪除

###### 🎯 對獎 (最優先執行)
```
POST /invoices.php
Content-Type: application/json

{
  "action": "check_winning"
}

PHP 執行 SQL:
SELECT i.invoice_number, i.period, i.amount, i.invoice_date, w.prize_level
FROM invoices i
INNER JOIN winning_numbers w ON i.invoice_number = w.invoice_number
ORDER BY i.created_at DESC;

回應 (200 OK):
[
  {
    "invoice_number": "AB12345678",
    "period": "115年03-04月",
    "amount": 500,
    "invoice_date": "2026/04/30",
    "prize_level": "特獎"
  },
  ...
]

回應 (無結果):
[]
```

###### 🗑️ 刪除
```
POST /invoices.php
{
  "action": "delete",
  "invoice_number": "AB12345678"
}

PHP 執行 SQL:
DELETE FROM invoices WHERE invoice_number = ?;

回應 (200 OK):
{ "success": true, "message": "刪除成功" }

回應 (缺少號碼):
400 Bad Request
{ "success": false, "message": "發票號碼不能為空" }
```

###### 💾 儲存 (默認 action)
```
POST /invoices.php
{
  "invoice_number": "AB12345678",
  "period": "115年03-04月",
  "amount": 500,
  "invoice_date": "2026/04/30"
}

PHP 執行 SQL (Upsert):
INSERT INTO invoices (...) VALUES (...)
ON DUPLICATE KEY UPDATE ...;

回應 (200 OK):
{ "success": true, "message": "儲存成功" }

回應 (缺少號碼):
400 Bad Request
{ "success": false, "message": "發票號碼不能為空" }
```

#### 核心邏輯流程

```php
// ✅ 第1步：解析 JSON 或 Form-urlencoded
$postData = getPostData();

// ✅ 第2步：優先處理對獎 (最先執行)
if ($action === 'check_winning') {
  INNER JOIN 並 exit();  // 防止進入後面的驗證
}

// ✅ 第3步：檢查發票號碼 (所有非對獎請求)
if (empty($invoiceNumber)) {
  return 400 error;
}

// ✅ 第4步：處理刪除
if ($action === 'delete') {
  DELETE 並 exit();
}

// ✅ 第5步：處理儲存 (Upsert)
INSERT ON DUPLICATE KEY UPDATE;
```

---

### 3. init_database.sql - 數據庫初始化

#### 數據庫結構

##### invoices 表 (發票)
```sql
CREATE TABLE invoices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,    -- 發票號碼
  period VARCHAR(30) DEFAULT '115年03-04月',     -- 期數
  amount INT DEFAULT 0,                          -- 金額
  invoice_date VARCHAR(20),                      -- 日期
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 樣本數據
INSERT INTO invoices VALUES
(1, 'AB12345678', '115年03-04月', 500, '2026/04/30', ...),
(2, 'CD87654321', '115年03-04月', 299, '2026/04/29', ...);
```

##### winning_numbers 表 (中獎號碼)
```sql
CREATE TABLE winning_numbers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,    -- 中獎號碼
  period VARCHAR(30),                            -- 期數
  prize_level VARCHAR(20),                       -- 獎級 (特獎、頭獎等)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 預置中獎號碼
INSERT INTO winning_numbers VALUES
(1, 'WU90043278', '115年03-04月', '特獎', ...),
(2, 'AB12345678', '115年03-04月', '特獎', ...),
(3, 'CD87654321', '115年03-04月', '特獎', ...);
```

#### 對獎查詢邏輯

```sql
-- 只返回同時存在於兩個表的發票
SELECT i.invoice_number, i.period, i.amount, i.invoice_date, w.prize_level
FROM invoices i
INNER JOIN winning_numbers w ON i.invoice_number = w.invoice_number
ORDER BY i.created_at DESC;

-- 範例結果
invoice_number | period      | amount | invoice_date | prize_level
AB12345678    | 115年03-04月 | 500    | 2026/04/30   | 特獎
CD87654321    | 115年03-04月 | 299    | 2026/04/29   | 特獎
```

---

## 🔄 數據流程圖

### 掃描並儲存發票流程
```
用戶拍照
  ↓
Google ML Kit OCR 識別
  ↓
AI 智慧修正
  ↓
用戶確認並編輯
  ↓
點擊 [儲存]
  ↓
Flutter → POST /invoices.php
  ↓
PHP 執行 INSERT OR UPDATE
  ↓
數據保存到 MySQL
  ↓
返回成功信息
  ↓
更新 UI 列表
```

### 一鍵對獎流程
```
用戶點擊 🏆 獎杯按鈕
  ↓
Flutter → POST /invoices.php?action=check_winning
  ↓
PHP 執行 INNER JOIN 查詢
  ↓
比對 invoices 與 winning_numbers 表
  ↓
返回所有中獎發票 + 獎級信息
  ↓
Flutter 顯示對話框
  ↓
格式化顯示:
  🧾 發票號碼
  💰 消費金額
  📅 消費日期
  🎊 獲得獎別 (特獎、頭獎...)
```

### 刪除發票流程
```
用戶點擊列表卡片上的 🗑️ 按鈕
  ↓
Flutter → POST /invoices.php?action=delete
  ↓
PHP 執行 DELETE FROM invoices
  ↓
數據從 MySQL 刪除
  ↓
返回成功信息
  ↓
刷新列表，移除該項
```

---

## 🛠️ 技術棧

| 層級 | 技術 | 說明 |
|-----|------|------|
| **前端** | Flutter | Dart 編程語言、Material 設計 |
| **AI/ML** | Google ML Kit | 文本識別 (OCR) |
| **API** | HTTP | RESTful 風格的網路請求 |
| **後端** | PHP 7.x+ | 服務器端邏輯 |
| **數據庫** | MySQL/MariaDB | 關係型數據庫 |
| **服務器** | XAMPP Apache | 本地開發伺服器 |
| **字符集** | UTF-8mb4 | 支持中文和 Emoji |

---

## 📋 重要設置

### 連接地址
- **Flutter 內模擬器**: `http://10.0.2.2/invoice_scanner`
- **phpMyAdmin**: `http://localhost/phpmyadmin`
- **API 端點**: `http://10.0.2.2/invoice_scanner/invoices.php`

### 文件位置
- **XAMPP 根目錄**: `C:\xampp\htdocs\invoice_scanner`
- **PHP 文件**: `php/`
- **MySQL 數據**: 存儲於本地 MySQL 服務

### 數據庫信息
- **數據庫**: `invoice_db`
- **用戶**: `root`
- **密碼**: (空)
- **主機**: `localhost`

---

## ⚙️ 配置修改

### 修改 API 地址
編輯 `lib/services/api_service.dart`:
```dart
// 改成你的服務器地址
static const String baseUrl = 'http://你的伺服器IP/invoice_scanner';
```

### 修改數據庫連接
編輯 `php/db_config.php`:
```php
define('DB_HOST', '你的數據庫主機');
define('DB_USER', '數據庫用戶名');
define('DB_PASSWORD', '數據庫密碼');
define('DB_NAME', '數據庫名稱');
```

### 修改中獎號碼
在 phpMyAdmin 中編輯 `winning_numbers` 表:
```sql
INSERT INTO winning_numbers (invoice_number, period, prize_level) 
VALUES ('新號碼', '115年03-04月', '獎級名稱');
```

---

## 📱 使用流程

### 1️⃣ 初始化
1. 啟動 XAMPP (Apache + MySQL)
2. 初始化數據庫 (執行 `init_database.sql`)
3. 在 Flutter 中 `pub get` 安裝依賴

### 2️⃣ 掃描發票
1. 打開應用，進入「掃描發票」頁面
2. 點擊 📷 或 🖼️ 選擇照片
3. AI 自動識別並填充字段
4. 點擊 💾 [儲存]

### 3️⃣ 查看清單
1. 進入「發票清單」頁面
2. 查看所有已保存的發票
3. 滑動列表項可刪除

### 4️⃣ 對獎
1. 在「發票清單」頁面
2. 點擊右上角 🏆 [一鍵對獎]
3. 查看結果對話框中的中獎發票和獎級

---

## 🐛 常見問題

### ❓ 連接失敗「無法載入 (500)」
**解決**: 
- 確認 XAMPP Apache 已啟動
- 檢查 `php/db_config.php` 中的數據庫設置

### ❓ 對獎返回空結果
**解決**:
- 確認 `winning_numbers` 表中有中獎號碼
- 確認 `invoices` 表中有發票
- 確認發票號碼完全匹配（區分大小寫）

### ❓ 中文顯示亂碼 "??"
**解決**:
- 確保所有表使用 `utf8mb4` 字符集
- 執行: `ALTER TABLE 表名 CONVERT TO CHARACTER SET utf8mb4`

### ❓ OCR 識別不準確
**解決**:
- 確保照片清晰、光線充足
- 發票號碼和日期清晰可見
- 手動修改識別結果後再保存

---

## 📚 文檔參考

- [DATABASE_SETUP.md](./DATABASE_SETUP.md) - 詳細的數據庫設置步驟
- [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) - JSON 到 MySQL 的遷移指南
- [pubspec.yaml](./pubspec.yaml) - 所有依賴版本

---

## 🎉 完成功能清單

- ✅ 發票掃描與 OCR 識別
- ✅ 發票清單管理
- ✅ 自動對獎功能
- ✅ 獎級顯示
- ✅ 發票刪除
- ✅ MySQL 數據持久化
- ✅ UTF-8 中文支持
- ✅ 錯誤處理與日誌記錄
- ✅ 響應式 UI 設計

---

**最後更新**: 2026年5月2日  
**維護者**: 開發團隊  
**授權**: 私人使用

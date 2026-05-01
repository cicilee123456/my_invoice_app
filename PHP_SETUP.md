# 發票應用程式 - PHP後端設置指南

## 📋 需要的軟體

### 1. 安裝PHP
1. 下載PHP: https://windows.php.net/download#php-8.2
2. 選擇 "VS16 x64 Thread Safe" 版本
3. 解壓縮到 `C:\php`
4. **將 `C:\php` 添加到系統PATH環境變數**

   **步驟詳解：**
   - 按 `Win + R` 鍵，打開「執行」對話框
   - 輸入 `sysdm.cpl` 並按確定
   - 點擊「進階」標籤頁
   - 點擊「環境變數」按鈕
   - 在「系統變數」區域找到 `Path` 變數
   - 選中 `Path`，點擊「編輯」
   - 點擊「新增」，輸入 `C:\php`
   - 點擊「確定」保存所有對話框
   - **重新啟動命令提示符** 或 PowerShell

### 2. 啟動PHP伺服器
在命令提示符中運行：
```
cd C:\Users\liyachun\my_invoice_app\php
php -S localhost:8000
```

### 3. 測試連接
打開瀏覽器訪問：http://localhost:8000/get_invoices.php
應該看到 `[]` 或發票數據

### 4. 切換到真實資料模式
目前 Flutter 程式預設使用模擬資料。要讓 App 真正連線到你的 PHP API，請執行以下步驟：

1. 打開 `lib/services/api_service.dart`
2. 找到：
```dart
static const bool useMockData = true;
```
3. 改成：
```dart
static const bool useMockData = false;
```
4. 儲存檔案後，重新啟動 Flutter 應用程式

完成後，App 就會使用 `http://localhost:8000` 下的 PHP API 讀寫資料。
## 🔧 故障排除

### 如果還是連接逾時：
1. 確認PHP伺服器正在運行
2. 檢查防火牆設定
3. 嘗試不同的端口：`php -S localhost:8080`

### 如果顯示錯誤：
1. 檢查PHP版本（需要8.0+）
2. 確認文件權限
3. 查看PHP錯誤日誌

## 📁 文件結構
```
php/
├── get_invoices.php    # 獲取發票列表
├── save_invoice.php    # 保存發票
├── delete.php          # 刪除發票
└── invoices.json       # 數據存儲文件
```
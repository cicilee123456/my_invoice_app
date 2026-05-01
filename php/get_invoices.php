<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 數據文件路徑
$dataFile = __DIR__ . '/invoices.json';

// 確保數據文件存在
if (!file_exists($dataFile)) {
    file_put_contents($dataFile, '[]');
}

// 讀取數據
function readInvoices() {
    global $dataFile;
    $data = file_get_contents($dataFile);
    return json_decode($data, true);
}

// 保存數據
function saveInvoices($invoices) {
    global $dataFile;
    file_put_contents($dataFile, json_encode($invoices, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

// 獲取所有發票
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $invoices = readInvoices();
        echo json_encode($invoices);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => '讀取數據失敗: ' . $e->getMessage()]);
    }
}
?>
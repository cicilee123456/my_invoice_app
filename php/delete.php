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

// 刪除發票
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $invoiceNumber = $_GET['invoice_number'] ?? '';

        if (empty($invoiceNumber)) {
            http_response_code(400);
            echo json_encode(['error' => '發票號碼不能為空']);
            exit;
        }

        // 讀取現有數據
        $invoices = readInvoices();

        // 查找並刪除
        $found = false;
        $filteredInvoices = [];
        foreach ($invoices as $invoice) {
            if ($invoice['invoice_number'] === $invoiceNumber) {
                $found = true;
            } else {
                $filteredInvoices[] = $invoice;
            }
        }

        if (!$found) {
            http_response_code(404);
            echo json_encode(['error' => '找不到發票記錄']);
            exit;
        }

        // 保存更新後的數據
        saveInvoices($filteredInvoices);

        echo json_encode(['success' => true, 'message' => '發票刪除成功']);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => '刪除失敗: ' . $e->getMessage()]);
    }
}
?>
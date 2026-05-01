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

// 保存發票
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // 獲取POST數據
        $input = file_get_contents('php://input');
        $postData = json_decode($input, true);

        if (!$postData && isset($_POST['invoice_number'])) {
            $postData = $_POST;
        }

        if (!$postData) {
            http_response_code(400);
            echo json_encode(['error' => '無效的請求數據']);
            exit;
        }

        $invoiceNumber = $postData['invoice_number'] ?? '';
        $amount = intval($postData['amount'] ?? 0);
        $invoiceDate = $postData['invoice_date'] ?? '';

        if (empty($invoiceNumber)) {
            http_response_code(400);
            echo json_encode(['error' => '發票號碼不能為空']);
            exit;
        }

        // 讀取現有數據
        $invoices = readInvoices();

        // 檢查是否已存在
        $exists = false;
        foreach ($invoices as &$invoice) {
            if ($invoice['invoice_number'] === $invoiceNumber) {
                $invoice['amount'] = $amount;
                $invoice['invoice_date'] = $invoiceDate;
                $exists = true;
                break;
            }
        }

        // 如果不存在，添加新記錄
        if (!$exists) {
            $invoices[] = [
                'invoice_number' => $invoiceNumber,
                'period' => '115年03-04月',
                'amount' => $amount,
                'invoice_date' => $invoiceDate
            ];
        }

        // 保存數據
        saveInvoices($invoices);

        echo json_encode(['success' => true, 'message' => '發票保存成功']);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => '保存失敗: ' . $e->getMessage()]);
    }
}
?>
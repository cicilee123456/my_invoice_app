<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/db_config.php';

// 處理預檢請求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { 
    http_response_code(200);
    exit; 
}

/**
 * 核心：解析請求數據
 */
function getPostData() {
    $rawInput = file_get_contents('php://input');
    if (!empty($rawInput)) {
        $jsonData = json_decode($rawInput, true);
        if (json_last_error() === JSON_ERROR_NONE) return $jsonData;
    }
    return $_POST;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postData = getPostData();
    // 【第一步】優先抓取 Action，預設為 save
    $action = $postData['action'] ?? 'save'; 

    // 【第二步】如果是對獎，必須在任何欄位檢查之前執行並 exit
    if ($action === 'check_winning') {
        try {
            // 使用 INNER JOIN 比對本地發票與中獎號碼表
            $sql = "SELECT i.invoice_number, i.period, i.amount, i.invoice_date, w.prize_level
                    FROM invoices i
                    INNER JOIN winning_numbers w ON i.invoice_number = w.invoice_number
                    ORDER BY i.created_at DESC";
            
            $stmt = $pdo->query($sql);
            $winners = $stmt->fetchAll();
            
            // 直接回傳結果並強制結束，防止跑到後面的 400 錯誤檢查
            echo json_encode($winners, JSON_UNESCAPED_UNICODE);
            exit; 
            
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => '對獎失敗'], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }

    // 【第三步】非對獎請求（如儲存、刪除），才進行發票號碼檢查
    $invoiceNumber = $postData['invoice_number'] ?? '';
    
    if (empty($invoiceNumber)) {
        http_response_code(400); // 這裡就是你一直跳出的 400 錯誤來源
        echo json_encode(['success' => false, 'message' => '儲存失敗：發票號碼不能為空'], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 處理刪除邏輯
    if ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM invoices WHERE invoice_number = ?");
        $stmt->execute([$invoiceNumber]);
        echo json_encode(['success' => true, 'message' => '刪除成功']);
        exit;
    }

    // 處理儲存邏輯 (Upsert)
    $period = $postData['period'] ?? '115年03-04月';
    $amount = intval($postData['amount'] ?? 0);
    $invoiceDate = $postData['invoice_date'] ?? '';

    $stmt = $pdo->prepare("INSERT INTO invoices (invoice_number, period, amount, invoice_date) 
                           VALUES (?, ?, ?, ?) 
                           ON DUPLICATE KEY UPDATE period=?, amount=?, invoice_date=?");
    $stmt->execute([$invoiceNumber, $period, $amount, $invoiceDate, $period, $amount, $invoiceDate]);
    
    echo json_encode(['success' => true, 'message' => '儲存成功']);
    exit;
}

// GET 請求處理
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->query("SELECT * FROM invoices ORDER BY created_at DESC");
    echo json_encode($stmt->fetchAll(), JSON_UNESCAPED_UNICODE);
    exit;
}
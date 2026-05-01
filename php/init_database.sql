-- 創建發票數據庫
CREATE DATABASE IF NOT EXISTS invoice_db;
USE invoice_db;

-- 創建發票表
CREATE TABLE IF NOT EXISTS invoices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    period VARCHAR(30) DEFAULT '115年03-04月',
    amount INT DEFAULT 0,
    invoice_date VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 創建中獎號碼表
CREATE TABLE IF NOT EXISTS winning_numbers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    period VARCHAR(30),
    prize_level VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入示例中獎號碼
INSERT IGNORE INTO winning_numbers (invoice_number, period, prize_level) VALUES
('WU90043278', '115年03-04月', '特獎'),
('AB12345678', '115年03-04月', '特獎'),
('CD87654321', '115年03-04月', '特獎');

-- 創建用戶表（用於基本認證）
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

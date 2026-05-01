import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/invoice_scanner';
  static const bool useMockData = false; // 使用真實 XAMPP API

  // 模擬數據存儲（僅在測試時使用）
  static List<Invoice> _mockInvoices = [
    Invoice(
      invoiceNumber: 'AB12345678',
      period: '115年03-04月',
      amount: 150,
      invoiceDate: '2026/04/30',
    ),
    Invoice(
      invoiceNumber: 'CD87654321',
      period: '115年03-04月',
      amount: 299,
      invoiceDate: '2026/04/29',
    ),
  ];

  static Future<List<Invoice>> fetchInvoices() async {
    if (useMockData) {
      // 模擬網路延遲
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockInvoices;
    }

    try {
      // 加入 timeout 避免無限等待
      final response = await http.get(Uri.parse('$baseUrl/invoices.php'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Invoice.fromJson(data)).toList();
      } else {
        throw Exception('無法載入 (${response.statusCode})');
      }
    } catch (e) {
      // 捕捉 TimeoutException, FormatException (JSON 解析錯誤) 等所有例外
      throw Exception('連線或解析錯誤: $e');
    }
  }

  // 🌸 刪除功能
  static Future<bool> deleteInvoice(String invoiceNumber) async {
    if (useMockData) {
      // 模擬網路延遲
      await Future.delayed(const Duration(milliseconds: 600));

      // 移除匹配的發票
      _mockInvoices.removeWhere((inv) => inv.invoiceNumber == invoiceNumber);
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'invoice_number': invoiceNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      print('API刪除回應狀態碼: ${response.statusCode}');
      print('API刪除回應內容: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('刪除請求發生錯誤: $e');
      return false;
    }
  }

  // 🌸 向伺服器請求對獎
  static Future<List<Invoice>> checkWinningInvoices() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockInvoices.where((inv) => inv.invoiceNumber.endsWith('33')).toList();
    }

    try {
      final requestBody = jsonEncode({'action': 'check_winning'});
      print('🎯 對獎請求 - URL: $baseUrl/invoices.php');
      print('🎯 對獎請求 - Body: $requestBody');
      print('🎯 對獎請求 - Content-Type: application/json');
      
      final response = await http.post(
        Uri.parse('$baseUrl/invoices.php'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      print('✓ 對獎API回應狀態碼: ${response.statusCode}');
      print('✓ 對獎API回應內容: ${response.body}');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Invoice.fromJson(data)).toList();
      } else {
        String errMsg = response.body;
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) errMsg = errorData['message'];
        } catch (_) {}
        throw Exception('伺服器錯誤 (${response.statusCode}): $errMsg');
      }
    } catch (e) {
      print('✗ 對獎請求發生錯誤: $e');
      throw Exception('對獎失敗: $e');
    }
  }

  static Future<Map<String, dynamic>> saveInvoice(Invoice invoice) async {
    if (useMockData) {
      // 模擬網路延遲
      await Future.delayed(const Duration(milliseconds: 800));

      // 檢查是否已存在
      final existingIndex = _mockInvoices.indexWhere(
        (inv) => inv.invoiceNumber == invoice.invoiceNumber,
      );

      if (existingIndex >= 0) {
        // 更新現有記錄
        _mockInvoices[existingIndex] = invoice;
      } else {
        // 添加新記錄
        _mockInvoices.add(invoice);
      }

      return {'success': true, 'message': '發票保存成功（模擬模式）'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invoice_number': invoice.invoiceNumber,
          'period': invoice.period,
          'amount': invoice.amount.toString(),
          'invoice_date': invoice.invoiceDate,
        }),
      ).timeout(const Duration(seconds: 10));

      print('API回應狀態碼: ${response.statusCode}');
      print('API回應內容: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': '儲存成功'};
      } else {
        String errMsg = response.body;
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) errMsg = errorData['message'];
        } catch (_) {}
        return {'success': false, 'message': '伺服器錯誤 (${response.statusCode}): $errMsg'};
      }
    } on TimeoutException {
      return {'success': false, 'message': '連線逾時，請檢查伺服器是否正常'};
    } catch (e) {
      return {'success': false, 'message': '網路錯誤: $e'};
    }
  }
}
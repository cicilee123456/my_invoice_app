import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/invoice.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String _output = '等待測試...';

  Future<void> _testConnection() async {
    setState(() { _output = '連接測試中...'; });
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/invoices.php')).timeout(const Duration(seconds: 5));
      setState(() {
        _output = '''✓ 連接成功！
狀態碼: ${response.statusCode}
回應: ${response.body.substring(0, 200)}...''';
      });
    } on TimeoutException {
      setState(() { _output = '✗ 連接逾時 - 伺服器未回應 (5秒)'; });
    } catch (e) {
      setState(() { _output = '✗ 連接失敗\n錯誤：$e'; });
    }
  }

  Future<void> _testSave() async {
    setState(() { _output = '儲存測試中...'; });
    try {
      // 創建測試發票
      final testInvoice = Invoice(
        invoiceNumber: 'AB12345678',
        period: '115年03-04月',
        amount: 100,
        invoiceDate: '2026/04/30',
      );
      
      final result = await ApiService.saveInvoice(testInvoice);
      setState(() { 
        _output = '''儲存測試結果：
成功: ${result['success']}
訊息: ${result['message']}'''; 
      });
    } catch (e) {
      setState(() { _output = '✗ 儲存失敗\n錯誤：$e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 診斷工具')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('測試 API 連接'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testSave,
              child: const Text('測試儲存功能'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(_output, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

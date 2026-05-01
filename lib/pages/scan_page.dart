import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';
import '../utils/image_input_helper.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _storeController = TextEditingController();
  final _dateController = TextEditingController();
  Uint8List? _displayImageBytes;

  // 🌸 核心預處理：只做灰階與輕微對比，避免斷字
  Future<InputImage> _preProcess(String path, Uint8List bytes) async {
    return prepareInputImage(path, bytes);
  }

  // 🌸 AI 格式修正邏輯
  String _aiSmartFix(String input) {
    String clean = input.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    // 常見誤認：0->O, 1->I, 8->B, 5->S
    if (clean.length >= 10) {
      String letters = clean.substring(0, 2)
          .replaceAll('0', 'O').replaceAll('1', 'I')
          .replaceAll('8', 'B').replaceAll('5', 'S');
      String digits = clean.substring(2, 10)
          .replaceAll('O', '0').replaceAll('I', '1')
          .replaceAll('B', '8').replaceAll('S', '5');
      return letters + digits;
    }
    return clean;
  }

  Future<void> _processImage(XFile image) async {
    final bytes = await image.readAsBytes();

    if (kIsWeb) {
      setState(() {
        _displayImageBytes = bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已選擇照片，請手動填寫欄位或直接儲存。')));
      return;
    }

    final processedInput = await _preProcess(image.path, bytes);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    setState(() {
      _displayImageBytes = bytes;
    });

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(processedInput);
      // 將所有區塊合併成一大串文字，方便搜尋
      String fullContent = recognizedText.text.toUpperCase().replaceAll(' ', '').replaceAll('-', '');

      // 1. 抓號碼 (只要符合 2英8數 或 相似格式)
      RegExp numReg = RegExp(r'[A-Z0-9]{2}\d{7,8}');
      String? matched = numReg.stringMatch(fullContent);
      _numberController.text = matched != null ? _aiSmartFix(matched) : "";

      // 2. 抓日期
      RegExp dateReg = RegExp(r'\d{3,4}[/\-]\d{2}[/\-]\d{2}');
      _dateController.text = dateReg.stringMatch(fullContent) ?? "";

      // 3. 抓金額 (智慧過濾，取 10-99999 之間的數字，排除年份)
      RegExp priceReg = RegExp(r'\d{2,5}');
      var matches = priceReg.allMatches(fullContent);
      if (matches.isNotEmpty) {
        var validNums = matches
            .map((m) => int.parse(m.group(0)!))
            .where((n) => n > 10 && n < 90000 && n != 2026 && n != 2025)
            .toList();
        if (validNums.isNotEmpty) {
          validNums.sort(); // 最大的通常是總額
          _amountController.text = validNums.last.toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 預處理辨識完成！🌸')));
    } catch (e) {
      print("OCR 錯誤: $e");
    } finally {
      textRecognizer.close();
    }
  }

  // --- UI 與功能按鈕 ---

  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('選取照片失敗：$e')));
      }
    }
  }

  void _handleSave() async {
    if (_numberController.text.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請輸入發票號碼！')));
      return;
    }

    // 顯示儲存中
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('儲存中...')));

    // 🌸 檢查是否為重複發票
    try {
      final existingInvoices = await ApiService.fetchInvoices();
      final isDuplicate = existingInvoices.any((inv) => inv.invoiceNumber == _numberController.text);
      if (isDuplicate) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('儲存失敗：這張發票已經掃描過囉！')));
        return;
      }
    } catch (e) {
      print('檢查重複發票失敗: $e');
    }

    final newInvoice = Invoice(
      invoiceNumber: _numberController.text,
      period: "115年03-04月",
      amount: int.tryParse(_amountController.text) ?? 0,
      invoiceDate: _dateController.text,
    );

    try {
      final result = await ApiService.saveInvoice(newInvoice);
      final success = result['success'] as bool;
      final message = result['message'] as String;

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pushNamed(context, '/list');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('儲存失敗：$message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('錯誤：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 智慧發票掃描'),
        backgroundColor: Colors.pink[50],
        leading: IconButton(
          icon: const Icon(Icons.list),
          onPressed: () => Navigator.pushNamed(context, '/list'),
          tooltip: '查看發票清單',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.pushNamed(context, '/debug'),
            tooltip: '診斷工具',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.pink[100]!), borderRadius: BorderRadius.circular(10)),
              child: _displayImageBytes == null
                  ? const Center(child: Text('請點擊右方圖示拍照'))
                  : Image.memory(_displayImageBytes!),
            ),
            const SizedBox(height: 20),
            _buildTextField(_storeController, '店家名稱 (手動輸入中文)', Icons.store),
            _buildTextField(_numberController, '發票號碼 (AI 已校正)', Icons.numbers, suffix: true),
            _buildTextField(_dateController, '消費日期', Icons.calendar_today),
            _buildTextField(_amountController, '消費金額', Icons.attach_money, isNum: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[200], minimumSize: const Size(double.infinity, 50)),
              child: const Text('確認儲存', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool suffix = false, bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink[300]),
          suffixIcon: suffix ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.photo_library), onPressed: () => _getImage(ImageSource.gallery)),
              IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => _getImage(ImageSource.camera)),
            ],
          ) : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<Invoice>> _invoices;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _invoices = ApiService.fetchInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的發票清單'),
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.amber),
            tooltip: '一鍵對獎',
            onPressed: () async {
              try {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('正在向伺服器對獎中...')),
                  );
                }
                
                final winners = await ApiService.checkWinningInvoices();

                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(winners.isNotEmpty ? '中獎了！🎉' : '這期都沒中 QQ'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: winners.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: winners.length,
                                itemBuilder: (context, index) {
                                  final winner = winners[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('🧾 發票號碼：${winner.invoiceNumber}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('💰 消費金額：\$${winner.amount}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('📅 消費日期：${winner.invoiceDate}', style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('🎊 獲得獎別：${winner.prizeLevel ?? "中獎"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                                    ],
                                  );
                                },
                              )
                            : const Text('再接再厲！目前紀錄的發票都沒有對中。'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('確定'),
                        )
                      ],
                    ),
                  );
                }
              } catch (e) {
                print('對獎發生錯誤: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('對獎發生錯誤：$e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => Navigator.pushNamed(context, '/scan'),
            tooltip: '掃描新發票',
          ),
        ],
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _invoices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('還沒有發票紀錄喔🌸'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final inv = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.pinkAccent),
                  title: Text(
                    inv.invoiceNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${inv.amount} | ${inv.invoiceDate}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      bool ok = await ApiService.deleteInvoice(inv.invoiceNumber);
                      if (ok) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已刪除！')),
                          );
                        }
                        _loadData(); // 重新整理
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('刪除失敗，請檢查伺服器或網路連線！')),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        backgroundColor: Colors.pink[200],
        child: const Icon(Icons.add_a_photo),
        tooltip: '掃描新發票',
      ),
    );
  }
}
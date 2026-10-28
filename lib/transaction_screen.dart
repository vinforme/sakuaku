import 'dart:ui';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  // Menerima data dan fungsi dari main.dart
  final List<Map<String, dynamic>> transactions;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const TransactionScreen({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = 'Semua'; // Filter aktif: Semua, Pemasukan, Pengeluaran

  // Helper format Rupiah
  String _formatCurrency(double amount) {
    String result = amount.toInt().toString();
    return result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika filter data transaksi berdasarkan state dari main.dart
    final filteredTransactions = widget.transactions.where((tx) {
      if (_selectedFilter == 'Pemasukan') return tx['isExpense'] == false;
      if (_selectedFilter == 'Pengeluaran') return tx['isExpense'] == true;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Halaman
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),

        // Tab Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterChip('Semua'),
              const SizedBox(width: 8),
              _buildFilterChip('Pemasukan'),
              const SizedBox(width: 8),
              _buildFilterChip('Pengeluaran'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List Transaksi
        Expanded(
          child: filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        'Tidak ada transaksi',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // padding bawah untuk bottom nav
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final item = filteredTransactions[index];
                    // Mencari index asli di list utama agar sinkron saat edit/hapus
                    final originalIndex = widget.transactions.indexOf(item);
                    
                    return _buildTransactionCard(item, originalIndex);
                  },
                ),
        ),
      ],
    );
  }

  // --- Widget untuk Filter Kategori ---
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF26A69A) : const Color(0xFFB0BEC5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }

  // --- Widget Card Transaksi (Gaya Glassmorphism) ---
  Widget _buildTransactionCard(Map<String, dynamic> item, int originalIndex) {
    final isExpense = item['isExpense'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: const Color(0xFFF1F8F8).withOpacity(0.6),
            child: InkWell(
              onTap: () {
                // Memicu fungsi edit di main.dart
                widget.onEdit(originalIndex);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isExpense
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE8F5E9),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isExpense
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF388E3C),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['category'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF78909C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? "-" : "+"} Rp ${_formatCurrency(item['amount'] as double)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isExpense
                                ? const Color(0xFFC62828)
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['date'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Tombol Hapus
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350), size: 20),
                      onPressed: () {
                        // Memicu dialog hapus di main.dart
                        widget.onDelete(originalIndex);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
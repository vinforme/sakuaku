import 'dart:ui';
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> budgetCategories;
  final Function(int, double) onUpdateBudget;

  const BudgetScreen({
    super.key,
    required this.transactions,
    required this.budgetCategories,
    required this.onUpdateBudget,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Helper format Rupiah
  String _formatCurrency(double amount) {
    String result = amount.toInt().toString();
    return result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Fungsi menghitung total pengeluaran per kategori
  double _getSpentByCategory(String categoryName) {
    return widget.transactions
        .where((tx) =>
            tx['isExpense'] == true &&
            (tx['category'] as String).toLowerCase() == categoryName.toLowerCase())
        .fold(0.0, (sum, tx) => sum + (tx['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total keseluruhan secara dinamis
    double totalBudget = 0;
    double totalSpent = 0;
    
    for (var item in widget.budgetCategories) {
      totalBudget += item['total'];
      totalSpent += _getSpentByCategory(item['category']);
    }
    
    // Mencegah pembagian dengan nol
    double overallProgress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Halaman
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Anggaran Bulanan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),

        // Ringkasan Anggaran Keseluruhan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildOverallBudgetCard(totalSpent, totalBudget, overallProgress),
        ),
        const SizedBox(height: 24),

        // Judul List Kategori
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Rincian Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // List Anggaran
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: widget.budgetCategories.length,
            itemBuilder: (context, index) {
              final item = widget.budgetCategories[index];
              final spent = _getSpentByCategory(item['category']);
              return _buildBudgetCategoryCard(item, spent, index);
            },
          ),
        ),
      ],
    );
  }

  // --- Widget Card Ringkasan Total ---
  Widget _buildOverallBudgetCard(double spent, double total, double progress) {
    double remaining = total - spent;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF26A69A).withOpacity(0.85),
                const Color(0xFF00897B).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00897B).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sisa Anggaran Bulan Ini',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${_formatCurrency(remaining < 0 ? 0 : remaining)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terpakai: Rp ${_formatCurrency(spent)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Total: Rp ${_formatCurrency(total)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.8 ? const Color(0xFFEF5350) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Card Kategori ---
  Widget _buildBudgetCategoryCard(Map<String, dynamic> item, double spent, int index) {
    final double total = (item['total'] as double);
    final double progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final bool isWarning = progress > 0.8;
    final double remaining = total - spent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: const Color(0xFFF1F8F8).withOpacity(0.6),
            child: InkWell(
              // Ketika card diklik, muncul form edit batas anggaran
              onTap: () => _showEditBudgetDialog(index, item['category'], total),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['category'] as String,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                  const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sisa: Rp ${_formatCurrency(remaining < 0 ? 0 : remaining)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isWarning
                                      ? const Color(0xFFD32F2F)
                                      : const Color(0xFF546E7A),
                                  fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFCFD8DC),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isWarning ? const Color(0xFFE53935) : (item['color'] as Color),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isWarning ? const Color(0xFFD32F2F) : const Color(0xFF455A64),
                          ),
                        ),
                      ],
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

  // --- Dialog Edit Anggaran ---
  void _showEditBudgetDialog(int index, String categoryName, double currentTotal) {
    final controller = TextEditingController(text: currentTotal.toInt().toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Anggaran $categoryName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Batas Anggaran (Rp)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
              onPressed: () {
                final newTotal = double.tryParse(controller.text) ?? currentTotal;
                if (newTotal > 0) {
                  widget.onUpdateBudget(index, newTotal);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
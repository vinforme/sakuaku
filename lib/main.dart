import 'dart:ui';
import 'package:flutter/material.dart';
import 'transaction_screen.dart';
import 'budget_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

void main() {
  runApp(const SakuAkuApp());
}

class SakuAkuApp extends StatelessWidget {
  const SakuAkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakuAku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26A69A),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true;
  int _currentIndex = 0;

  // ==========================================
  // 1. SENTRALISASI DATA (STATE)
  // ==========================================
  
  // Data Transaksi
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Makan Siang',
      'category': 'Makanan',
      'amount': 25000.0,
      'date': '12 Apr 2025',
      'isExpense': true,
      'icon': Icons.restaurant_outlined,
    },
    {
      'title': 'Uang Saku',
      'category': 'Pemasukan',
      'amount': 200000.0,
      'date': '12 Apr 2025',
      'isExpense': false,
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Transportasi',
      'category': 'Transportasi',
      'amount': 15000.0,
      'date': '11 Apr 2025',
      'isExpense': true,
      'icon': Icons.directions_bus_outlined,
    },
  ];

  // Data Anggaran Kategori
  final List<Map<String, dynamic>> _budgetCategories = [
    {
      'category': 'Makanan',
      'total': 1200000.0,
      'icon': Icons.restaurant_outlined,
      'color': const Color(0xFFE57373),
    },
    {
      'category': 'Transportasi',
      'total': 300000.0,
      'icon': Icons.directions_bus_outlined,
      'color': const Color(0xFF64B5F6),
    },
    {
      'category': 'Hiburan',
      'total': 500000.0,
      'icon': Icons.sports_esports_outlined,
      'color': const Color(0xFF9575CD),
    },
    {
      'category': 'Pendidikan',
      'total': 400000.0,
      'icon': Icons.menu_book_outlined,
      'color': const Color(0xFF4DB6AC),
    },
  ];

  // ==========================================
  // 2. PERHITUNGAN OTOMATIS
  // ==========================================
  double get _totalIncome => _transactions
      .where((tx) => tx['isExpense'] == false)
      .fold(0.0, (sum, tx) => sum + (tx['amount'] as double));

  double get _totalExpense => _transactions
      .where((tx) => tx['isExpense'] == true)
      .fold(0.0, (sum, tx) => sum + (tx['amount'] as double));

  double get _balance => _totalIncome - _totalExpense;

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
    final List<Widget> _pages = [
      _buildHomeView(),
      // Mengirim data & fungsi ke TransactionScreen
      TransactionScreen(
        transactions: _transactions,
        onEdit: (int index) => _showTransactionForm(index: index),
        onDelete: (int index) => _deleteTransaction(index),
      ),
      // Mengirim data & fungsi ke BudgetScreen
      BudgetScreen(
        transactions: _transactions,
        budgetCategories: _budgetCategories,
        onUpdateBudget: (int index, double newTotal) {
          setState(() {
            _budgetCategories[index]['total'] = newTotal;
          });
        },
      ),
      const ReportScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTransactionForm(); // Buka form untuk Tambah Baru
        },
        elevation: 4,
        backgroundColor: const Color(0xFF26A69A),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================
  // 3. FUNGSI CRUD TRANSAKSI
  // ==========================================
  void _deleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Transaksi?'),
          content: Text('Apakah Anda yakin ingin menghapus "${_transactions[index]['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _transactions.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Color(0xFFD32F2F))),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionForm({int? index}) {
    final bool isEditMode = index != null;
    
    final titleController = TextEditingController(text: isEditMode ? _transactions[index]['title'] : '');
    final amountController = TextEditingController(text: isEditMode ? _transactions[index]['amount'].toInt().toString() : '');
    bool isExpense = isEditMode ? _transactions[index]['isExpense'] : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Pengeluaran'),
                            selected: isExpense,
                            selectedColor: const Color(0xFFFFCDD2),
                            onSelected: (val) => setModalState(() => isExpense = true),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Pemasukan'),
                            selected: !isExpense,
                            selectedColor: const Color(0xFFC8E6C9),
                            onSelected: (val) => setModalState(() => isExpense = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Transaksi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nominal (Rp)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final title = titleController.text;
                          final amount = double.tryParse(amountController.text) ?? 0.0;

                          if (title.isNotEmpty && amount > 0) {
                            setState(() {
                              if (isEditMode) {
                                _transactions[index] = {
                                  'title': title,
                                  'category': isExpense ? 'Pengeluaran' : 'Pemasukan',
                                  'amount': amount,
                                  'date': _transactions[index]['date'],
                                  'isExpense': isExpense,
                                  'icon': isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                };
                              } else {
                                _transactions.insert(0, {
                                  'title': title,
                                  'category': isExpense ? 'Pengeluaran' : 'Pemasukan',
                                  'amount': amount,
                                  'date': 'Hari Ini',
                                  'isExpense': isExpense,
                                  'icon': isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                });
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isEditMode ? 'Simpan Perubahan' : 'Simpan', style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 4. WIDGET UI BERANDA
  // ==========================================
  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildMainBalanceCard(),
          const SizedBox(height: 16),
          _buildQuickSummaryRow(),
          const SizedBox(height: 24),
          _buildRecentTransactionsHeader(),
          const SizedBox(height: 12),
          _buildRecentTransactionsList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Selamat datang,', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Jane', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            SizedBox(height: 4),
            Text('Semangat mengatur keuangan hari ini', style: TextStyle(fontSize: 13, color: Color(0xFF558B2F))),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.person, color: Color(0xFF00695C)),
          ),
        ),
      ],
    );
  }

  Widget _buildMainBalanceCard() {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo Saat Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF37474F))),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: const Color(0xFF455A64)),
                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBalanceVisible ? 'Rp ${_formatCurrency(_balance)}' : 'Rp ••••••••',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12, thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pemasukan', style: TextStyle(fontSize: 12, color: Color(0xFF546E7A))),
                    const SizedBox(height: 4),
                    Text('Rp ${_formatCurrency(_totalIncome)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                  ],
                ),
              ),
              Container(height: 30, width: 1, color: Colors.black12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pengeluaran', style: TextStyle(fontSize: 12, color: Color(0xFF546E7A))),
                      const SizedBox(height: 4),
                      Text('Rp ${_formatCurrency(_totalExpense)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFC62828))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.pie_chart_outline, size: 18, color: Color(0xFF00796B)),
                    SizedBox(width: 4),
                    Text('Anggaran', style: TextStyle(fontSize: 11, color: Color(0xFF37474F))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('60%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.6, minHeight: 5, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B))),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildGlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF00796B)),
                    SizedBox(width: 4),
                    Text('Tabungan', style: TextStyle(fontSize: 11, color: Color(0xFF37474F))),
                  ],
                ),
                SizedBox(height: 8),
                Text('Rp 500.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildGlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.savings_outlined, size: 18, color: Color(0xFF00796B)),
                    SizedBox(width: 4),
                    Text('Sisa Saku', style: TextStyle(fontSize: 11, color: Color(0xFF37474F))),
                  ],
                ),
                SizedBox(height: 8),
                Text('Rp 750.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 1),
          child: Row(
            children: const [
              Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00796B))),
              Icon(Icons.chevron_right, size: 16, color: Color(0xFF00796B)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    final recentTransactions = _transactions.take(3).toList();

    if (recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('Belum ada transaksi')),
      );
    }

    return Column(
      children: recentTransactions.map((item) {
        final isExpense = item['isExpense'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isExpense ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  child: Icon(item['icon'] as IconData, color: isExpense ? const Color(0xFFD32F2F) : const Color(0xFF388E3C), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF263238))),
                      const SizedBox(height: 2),
                      Text(item['category'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF78909C))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? "-" : "+"} Rp ${_formatCurrency(item['amount'] as double)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isExpense ? const Color(0xFFC62828) : const Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 2),
                    Text(item['date'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', 0),
            _buildNavItem(Icons.receipt_long_outlined, 'Transaksi', 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.pie_chart_outline, 'Anggaran', 2),
            _buildNavItem(Icons.insert_chart_outlined, 'Laporan', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: isSelected ? const Color(0xFF00796B) : const Color(0xFF90A4AE)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF00796B) : const Color(0xFF90A4AE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, required EdgeInsetsGeometry padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F8).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    );
  }
}
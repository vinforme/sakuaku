import 'dart:ui';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedPeriod = 'Minggu Ini'; // Toggle periode

  // Dummy data untuk chart mingguan (nilai 0.0 - 1.0 mewakili persentase tinggi bar)
  final List<Map<String, dynamic>> _chartData = [
    {'day': 'Sen', 'value': 0.4},
    {'day': 'Sel', 'value': 0.7},
    {'day': 'Rab', 'value': 0.3},
    {'day': 'Kam', 'value': 0.9},
    {'day': 'Jum', 'value': 0.5},
    {'day': 'Sab', 'value': 0.8},
    {'day': 'Min', 'value': 0.6},
  ];

  // Dummy data kategori pengeluaran terbesar
  final List<Map<String, dynamic>> _topExpenses = [
    {
      'category': 'Makanan & Minuman',
      'amount': 'Rp 850.000',
      'percentage': 45,
      'icon': Icons.restaurant_outlined,
      'color': const Color(0xFFE57373),
    },
    {
      'category': 'Belanja',
      'amount': 'Rp 450.000',
      'percentage': 25,
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFF64B5F6),
    },
    {
      'category': 'Transportasi',
      'amount': 'Rp 250.000',
      'percentage': 15,
      'icon': Icons.directions_bus_outlined,
      'color': const Color(0xFF81C784),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Filter Periode
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Laporan Keuangan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              _buildPeriodDropdown(),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Padding untuk bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian 1: Grafik / Chart (Wireframe 4 - Top)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildChartContainer(),
                ),
                const SizedBox(height: 20),

                // Bagian 2: Ringkasan Total (Wireframe 4 - Middle)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Pemasukan',
                          'Rp 5.200.000',
                          Icons.arrow_downward,
                          const Color(0xFF388E3C),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Pengeluaran',
                          'Rp 3.450.000',
                          Icons.arrow_upward,
                          const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bagian 3: Daftar Pengeluaran Terbesar (Wireframe 4 - Bottom)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Pengeluaran Terbesar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF37474F),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // List Pengeluaran
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _topExpenses.length,
                  itemBuilder: (context, index) {
                    return _buildTopExpenseCard(_topExpenses[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget Dropdown Periode ---
  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00695C), size: 18),
          isDense: true,
          style: const TextStyle(
            color: Color(0xFF00695C),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPeriod = newValue!;
            });
          },
          items: <String>['Minggu Ini', 'Bulan Ini', 'Tahun Ini']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Widget Chart Glassmorphism ---
  Widget _buildChartContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F8).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tren Pengeluaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF546E7A),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _chartData.map((data) {
                    return _buildChartBar(data['day'], data['value']);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Bar untuk Grafik Murni Flutter ---
  Widget _buildChartBar(String label, double heightFactor) {
    // Ketinggian maksimum bar yang diizinkan (misal 120 pixel)
    const double maxBarHeight = 110.0; 
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: maxBarHeight * heightFactor,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4DB6AC), Color(0xFF00897B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF78909C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Widget Ringkasan Card (Pemasukan/Pengeluaran) ---
  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05), // Sedikit tint warna
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Daftar Kategori Terbesar (Glassmorphism) ---
  Widget _buildTopExpenseCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F8).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
            ),
            child: Row(
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
                      Text(
                        item['category'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Linear progress bar untuk persentase
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (item['percentage'] as int) / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFCFD8DC),
                          valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['amount'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['percentage']}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF78909C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
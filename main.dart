import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Expense Tracker Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 1. โมเดลข้อมูลธุรกรรม (Transaction Model)
// ==========================================
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ข้อมูลจำลองตั้งต้น (In-Memory List)
  final List<Transaction> _transactions = [
    Transaction(id: '1', title: 'เงินเดือนประจำเดือน', amount: 35000, isIncome: true, category: 'เงินเดือน', date: DateTime.now().subtract(const Duration(days: 4))),
    Transaction(id: '2', title: 'ค่าอาหารกลางวัน', amount: 150, isIncome: false, category: 'อาหาร', date: DateTime.now().subtract(const Duration(days: 3))),
    Transaction(id: '3', title: 'ค่าเดินทาง (BTS)', amount: 60, isIncome: false, category: 'เดินทาง', date: DateTime.now().subtract(const Duration(days: 2))),
    Transaction(id: '4', title: 'ซื้อของใช้ในบ้าน', amount: 500, isIncome: false, category: 'ช้อปปิ้ง', date: DateTime.now().subtract(const Duration(days: 1))),
    Transaction(id: '5', title: 'ดูภาพยนตร์', amount: 300, isIncome: false, category: 'บันเทิง', date: DateTime.now()),
  ];

  // ตัวแปรควบคุมการกรอง, ค้นหา และจัดเรียง
  String _filter = 'All'; // All, Income, Expense
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date' หรือ 'amount'
  final double _monthlyBudget = 5000.0; // ตั้งงบประมาณรายจ่ายสูงสุดต่อเดือน

  // คำนวณยอดรวมรายรับ
  double get _totalIncome {
    return _transactions.where((item) => item.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }

  // คำนวณยอดรวมรายจ่าย
  double get _totalExpense {
    return _transactions.where((item) => !item.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  }

  // ==========================================
  // หมวดหมู่รายการ (Categories & Icons)
  // ==========================================
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'อาหาร': return Icons.fastfood;
      case 'เดินทาง': return Icons.directions_bus;
      case 'ช้อปปิ้ง': return Icons.shopping_bag;
      case 'บันเทิง': return Icons.movie;
      case 'เงินเดือน': return Icons.account_balance_wallet;
      case 'ลงทุน': return Icons.trending_up;
      default: return Icons.category;
    }
  }

  // ฟังก์ชันเพิ่มรายการใหม่
  void _addTransaction(String title, double amount, bool isIncome, String category, DateTime date) {
    setState(() {
      _transactions.add(
        Transaction(
          id: DateTime.now().toString(),
          title: title,
          amount: amount,
          isIncome: isIncome,
          category: category,
          date: date,
        ),
      );
    });
  }

  // ฟังก์ชันลบรายการ
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((item) => item.id == id);
    });
  }

  // ==========================================
  // ฟังก์ชันเลือกวันที่ (Date Picker)
  // ==========================================
  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  // เปิด Modal สำหรับเพิ่มรายการใหม่
  void _showAddModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String selectedCategory = 'อาหาร';
    DateTime selectedDate = DateTime.now();

    final List<String> expenseCategories = ['อาหาร', 'เดินทาง', 'ช้อปปิ้ง', 'บันเทิง', 'อื่นๆ'];
    final List<String> incomeCategories = ['เงินเดือน', 'ลงทุน', 'รายได้เสริม', 'อื่นๆ'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> currentCategories = isIncome ? incomeCategories : expenseCategories;
            if (!currentCategories.contains(selectedCategory)) {
              selectedCategory = currentCategories.first;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'บันทึกรายการใหม่',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อรายการ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'จำนวนเงิน (บาท)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('รายจ่าย')),
                            selected: !isIncome,
                            selectedColor: Colors.red.shade100,
                            onSelected: (val) {
                              setModalState(() => isIncome = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('รายรับ')),
                            selected: isIncome,
                            selectedColor: Colors.green.shade100,
                            onSelected: (val) {
                              setModalState(() => isIncome = true);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'หมวดหมู่รายการ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: currentCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),
                    // ปุ่มเลือกวันที่ (Date Picker)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('วันที่: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        TextButton(
                          onPressed: () {
                            _selectDate(context, (pickedDate) {
                              setModalState(() => selectedDate = pickedDate);
                            });
                          },
                          child: const Text('เปลี่ยนวันที่'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final title = titleController.text;
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (title.isNotEmpty && amount > 0) {
                          _addTransaction(title, amount, isIncome, selectedCategory, selectedDate);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // กราฟสรุปสัดส่วน (Custom Summary & Visualization)
  // ==========================================
  Widget _buildCategorySummaryChart() {
    // กรองเฉพาะรายจ่ายมาคำนวณสัดส่วน
    var expenses = _transactions.where((item) => !item.isIncome).toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    Map<String, double> categoryTotals = {};
    for (var item in expenses) {
      categoryTotals[item.category] = (categoryTotals[item.category] ?? 0) + item.amount;
    }

    final List<Color> chartColors = [Colors.orange, Colors.blue, Colors.purple, Colors.redAccent, Colors.amber];
    int colorIndex = 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('กราฟสรุปสัดส่วนรายจ่ายตามหมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...categoryTotals.entries.map((entry) {
            double percentage = _totalExpense > 0 ? (entry.value / _totalExpense) : 0.0;
            Color currentColor = chartColors[colorIndex % chartColors.length];
            colorIndex++;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${entry.key} (฿${entry.value.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                      Text('${(percentage * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: currentColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade100,
                    color: currentColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double balance = _totalIncome - _totalExpense;
    double budgetProgress = (_totalExpense / _monthlyBudget).clamp(0.0, 1.0);

    // ==========================================
    // การค้นหาและจัดเรียงข้อมูล (Search & Sort)
    // ==========================================
    var filteredList = _transactions.where((item) {
      bool matchesFilter = true;
      if (_filter == 'Income') matchesFilter = item.isIncome;
      if (_filter == 'Expense') matchesFilter = !item.isIncome;

      bool matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    // จัดเรียงข้อมูล (Sort)
    filteredList.sort((a, b) {
      if (_sortBy == 'date') {
        return b.date.compareTo(a.date); // เรียงจากใหม่ไปเก่า
      } else {
        return b.amount.compareTo(a.amount); // เรียงจากจำนวนเงินมากไปน้อย
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Smart Expense Tracker Pro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ==========================================
          // ฟีเจอร์ตั้งงบประมาณรายเดือน (Monthly Budget Limit)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.tealAccent.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                const Text('ยอดเงินคงเหลือสุทธิ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 6),
                Text('฿${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('รายรับ: ฿${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    Text('รายจ่าย: ฿${_totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                // แถบหลอดเลือดเตือนงบประมาณ (Budget Progress Bar)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('งบประมาณรายจ่ายเดือนนี้', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('฿${_totalExpense.toStringAsFixed(0)} / ฿${_monthlyBudget.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: budgetProgress,
                      backgroundColor: Colors.white24,
                      color: budgetProgress > 0.8 ? Colors.orangeAccent : Colors.greenAccent,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // ช่องค้นหา (Search Bar) และ ปุ่มจัดเรียง (Sort)
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาชื่อรายการ หรือหมวดหมู่...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown เลือกรูปแบบการจัดเรียง
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('เรียงตามวันที่')),
                      DropdownMenuItem(value: 'amount', child: Text('เรียงตามยอดเงิน')),
                    ],
                    onChanged: (val) => setState(() => _sortBy = val!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ปุ่มเลือก Filter กรองประเภท
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(label: const Text('ทั้งหมด'), selected: _filter == 'All', onSelected: (val) => setState(() => _filter = 'All')),
                ChoiceChip(label: const Text('รายรับ'), selected: _filter == 'Income', onSelected: (val) => setState(() => _filter = 'Income')),
                ChoiceChip(label: const Text('รายจ่าย'), selected: _filter == 'Expense', onSelected: (val) => setState(() => _filter = 'Expense')),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // แสดงกราฟสรุปสัดส่วนรายจ่าย
          _buildCategorySummaryChart(),

          // ==========================================
          // รายการประวัติธุรกรรม (ListView & Icons)
          // ==========================================
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('ไม่พบรายการข้อมูล', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => _deleteTransaction(item.id),
                        child: Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: item.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            trailing: Text(
                              '${item.isIncome ? '+' : '-'}฿${item.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: item.isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }
}
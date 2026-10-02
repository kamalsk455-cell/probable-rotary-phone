import 'package:flutter/material.dart';

void main() {
  runApp(const VasoolRajaApp());
}

// ---------------------------------------------------------------------------
// 1. தரவு மாதிரிகள் (Data Models)
// ---------------------------------------------------------------------------
class PaymentRecord {
  final DateTime date;
  final double amount;
  final String mode; // ரொக்கம் அல்லது UPI

  PaymentRecord({required this.date, required this.amount, required this.mode});
}

class Customer {
  final String id;
  int orderNo;
  String shopName;
  String ownerName;
  String phone;
  double totalLoan;
  double dailyDue;
  double paidAmount;
  double todayPaid;
  String todayMode; // 'ரொக்கம்' / 'UPI' / ''
  bool isPaidToday;
  List<PaymentRecord> paymentHistory;

  Customer({
    required this.id,
    required this.orderNo,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.totalLoan,
    required this.dailyDue,
    this.paidAmount = 0.0,
    this.todayPaid = 0.0,
    this.todayMode = '',
    this.isPaidToday = false,
    List<PaymentRecord>? history,
  }) : paymentHistory = history ?? [];

  double get balance => totalLoan - paidAmount;
  int get daysPaidCount => (paidAmount / (dailyDue > 0 ? dailyDue : 1)).floor();
}

// ---------------------------------------------------------------------------
// 2. முதன்மை செயலி (Main App)
// ---------------------------------------------------------------------------
class VasoolRajaApp extends StatelessWidget {
  const VasoolRajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'வசூல் ராஜா',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D7C66)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isDayOpen = true; // நாள் ஓபன் / க்ளோஸ் நிலை
  final List<Customer> _customers = []; // முற்றிலும் காலியான பட்டியல்

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ---------------- நாள் திறத்தல் / முடித்தல் (Day Open / Close) ----------------
  void _toggleDayStatus() {
    if (isDayOpen) {
      // நாள் முடிக்கும் போது கணக்கு சரிபார்த்து உறுதி செய்தல்
      double totalToday = _customers.fold(0, (sum, c) => sum + c.todayPaid);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('இன்றைய கணக்கை முடிக்கவா? 🔒', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            'இன்றைய மொத்த வசூல்: ₹${totalToday.toInt()}\n\nநாள் முடித்தால் இன்றைய கணக்கு பூட்டப்படும்.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              onPressed: () {
                setState(() => isDayOpen = false);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Colors.black87, content: Text('இன்றைய வசூல் வெற்றிகரமாக முடிக்கப்பட்டது!')),
                );
              },
              child: const Text('ஆம், கணக்கை முடி'),
            ),
          ],
        ),
      );
    } else {
      // புதிய நாள் தொடங்குதல்
      setState(() {
        isDayOpen = true;
        for (var c in _customers) {
          c.isPaidToday = false;
          c.todayPaid = 0.0;
          c.todayMode = '';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('புதிய நாள் தொடங்கியது! இன்றைய வசூலைத் தொடங்கலாம்.')),
      );
    }
  }

  // ---------------- வசூல் பதிவு செய்தல் ----------------
  void _recordPayment(Customer customer, double amount, String mode) {
    if (!isDayOpen) {
      _showDayClosedWarning();
      return;
    }
    setState(() {
      customer.isPaidToday = true;
      customer.todayPaid = amount;
      customer.todayMode = mode;
      customer.paidAmount += amount;
      customer.paymentHistory.add(PaymentRecord(date: DateTime.now(), amount: amount, mode: mode));
    });
  }

  // ---------------- தவறான பதிவை ரத்து செய்தல் (Undo) ----------------
  void _undoPayment(Customer customer) {
    if (!isDayOpen) {
      _showDayClosedWarning();
      return;
    }
    setState(() {
      customer.paidAmount -= customer.todayPaid;
      if (customer.paymentHistory.isNotEmpty) {
        customer.paymentHistory.removeLast();
      }
      customer.isPaidToday = false;
      customer.todayPaid = 0.0;
      customer.todayMode = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${customer.shopName} வசூல் ரத்து செய்யப்பட்டது!')),
    );
  }

  void _showDayClosedWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.red, content: Text('இன்றைய நாள் முடிக்கப்பட்டுவிட்டது! "நாள் தொடங்கு" கொடுக்கவும்.')),
    );
  }

  // ---------------- பகுதித் தொகை செலுத்தும் விண்டோ (Partial Pay) ----------------
  void _openPartialPayDialog(Customer customer) {
    if (!isDayOpen) {
      _showDayClosedWarning();
      return;
    }
    final amountCtrl = TextEditingController(text: customer.dailyDue.toInt().toString());
    String selectedMode = 'ரொக்கம்';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('${customer.shopName} - தொகை பதிவு', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('தினசரி தவணை: ₹${customer.dailyDue.toInt()}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'கொடுத்த தொகை ₹ *',
                  hintText: 'எடுத்துக்காட்டு: 50',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ரொக்கம் (Cash)')),
                      selected: selectedMode == 'ரொக்கம்',
                      onSelected: (val) => setDlgState(() => selectedMode = 'ரொக்கம்'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('UPI / GPay')),
                      selected: selectedMode == 'UPI',
                      onSelected: (val) => setDlgState(() => selectedMode = 'UPI'),
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
              onPressed: () {
                double entered = double.tryParse(amountCtrl.text.trim()) ?? 0;
                if (entered <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('சரியான தொகையை உள்ளிடவும்!')));
                  return;
                }
                Navigator.pop(ctx);
                _recordPayment(customer, entered, selectedMode);
              },
              child: const Text('சேமிக்க'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- புதிய கஸ்டமர் சேர்க்கும் விண்டோ ----------------
  void _openAddCustomerDialog() {
    final shopCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dueCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('புதிய கடன் கணக்கு ➕', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopCtrl,
                decoration: const InputDecoration(labelText: 'கடையின் பெயர் *', hintText: 'எடுத்துக்காட்டு: ராஜா மளிகை', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'உரிமையாளர் பெயர் *', hintText: 'எடுத்துக்காட்டு: ராஜா', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'மொபைல் எண் *', hintText: 'எடுத்துக்காட்டு: 9876543210', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'கடன் தொகை ₹ *', hintText: 'எடுத்துக்காட்டு: 10000', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'தினசரி தவணை ₹ *', hintText: 'எடுத்துக்காட்டு: 100', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              if (shopCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('அனைத்து விவரங்களையும் உள்ளிடவும்!')));
                return;
              }
              double loan = double.tryParse(amountCtrl.text.trim()) ?? 10000;
              double due = double.tryParse(dueCtrl.text.trim()) ?? (loan / 100);

              setState(() {
                _customers.add(Customer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  orderNo: _customers.length + 1,
                  shopName: shopCtrl.text.trim(),
                  ownerName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  totalLoan: loan,
                  dailyDue: due,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('சேமிக்க'),
          ),
        ],
      ),
    );
  }

  // ---------------- பாஸ்புக் அட்டை விண்டோ (Passbook Table) ----------------
  void _openPassbookDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${customer.shopName} - பாஸ்புக்', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('உரிமையாளர்: ${customer.ownerName} • 📞 ${customer.phone}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('அசல்: ₹${customer.totalLoan.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('கட்டியது: ₹${customer.paidAmount.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('பாக்கி: ₹${customer.balance.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 20),
                const Text('பணம் செலுத்திய வரலாறு (அட்டவணை):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                if (customer.paymentHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('இன்னும் தவணைகள் எதுவும் தொடங்கவில்லை.', style: TextStyle(color: Colors.grey))),
                  )
                else
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                        children: [
                          Padding(padding: EdgeInsets.all(6), child: Text('எண்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(6), child: Text('தேதி', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(6), child: Text('முறை', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(6), child: Text('தொகை', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                      ...customer.paymentHistory.asMap().entries.map((entry) {
                        int idx = entry.key + 1;
                        var p = entry.value;
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(6), child: Text('$idx', style: const TextStyle(fontSize: 11))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${p.date.day}/${p.date.month}', style: const TextStyle(fontSize: 11))),
                            Padding(padding: const EdgeInsets.all(6), child: Text(p.mode, style: const TextStyle(fontSize: 11))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('₹${p.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green))),
                          ],
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('மூடு')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpectedToday = _customers.fold(0, (sum, c) => sum + c.dailyDue);
    double totalCollectedToday = _customers.fold(0, (sum, c) => sum + c.todayPaid);
    double totalPendingToday = totalExpectedToday - totalCollectedToday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('வசூல் ராஜா 👑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D7C66),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _toggleDayStatus,
            icon: Icon(isDayOpen ? Icons.lock_open : Icons.lock, size: 18),
            label: Text(isDayOpen ? 'நாள் முடி (Close)' : 'நாள் தொடங்கு (Open)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.playlist_add_check), text: 'இன்றைய வசூல்'),
            Tab(icon: Icon(Icons.table_chart), text: 'மொத்தக் கணக்கு'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D7C66),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('கடன் சேர் ➕', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _openAddCustomerDialog,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // -------------------------------------------------------------
          // பக்கம் 1: இன்றைய வசூல் பட்டியல் (Daily Collection Sheet)
          // -------------------------------------------------------------
          Column(
            children: [
              // வசூல் நிலைப் பட்டை
              Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statCard('இன்று வர வேண்டியது', '₹${totalExpectedToday.toInt()}', Colors.white),
                    _statCard('இன்றைய வசூல்', '₹${totalCollectedToday.toInt()}', Colors.greenAccent),
                    _statCard('இன்றைய பாக்கி', '₹${(totalPendingToday < 0 ? 0 : totalPendingToday).toInt()}', Colors.amberAccent),
                  ],
                ),
              ),

              Expanded(
                child: _customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront_outlined, size: 55, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            const Text('இன்னும் கடைகள் எதுவும் சேர்க்கப்படவில்லை!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('கீழே உள்ள "கடன் சேர் ➕" பட்டனைத் தட்டி கடைகளைச் சேர்க்கவும்.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _customers.length,
                        itemBuilder: (ctx, idx) {
                          final c = _customers[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  // வரிசை எண்
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: c.isPaidToday ? Colors.green : const Color(0xFF0D7C66),
                                    child: Text('${c.orderNo}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  const SizedBox(width: 10),

                                  // கடை & நபர் விவரம்
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text('${c.ownerName} • 📞 ${c.phone}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                        Text('தவணை: ₹${c.dailyDue.toInt()} • பாக்கி: ₹${c.balance.toInt()}', style: const TextStyle(color: Colors.brown, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),

                                  // பணம் வாங்கிய பட்டன்கள் / ரத்து பட்டன்
                                  if (!c.isPaidToday) ...[
                                    // முழுத் தொகை (ஒரே தட்டு)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                      onPressed: () => _recordPayment(c, c.dailyDue, 'ரொக்கம்'),
                                      child: Text('₹${c.dailyDue.toInt()}'),
                                    ),
                                    const SizedBox(width: 4),
                                    // பகுதித் தொகை பதிவு
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                      onPressed: () => _openPartialPayDialog(c),
                                      child: const Text('பகுதி / UPI', style: TextStyle(fontSize: 11)),
                                    ),
                                  ] else ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('✓ ₹${c.todayPaid.toInt()} (${c.todayMode})', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                        InkWell(
                                          onTap: () => _undoPayment(c),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 2),
                                            child: Text('ரத்து செய் (Undo)', style: TextStyle(color: Colors.red, fontSize: 11, decoration: TextDecoration.underline)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // -------------------------------------------------------------
          // பக்கம் 2: மொத்தக் கணக்கு & அட்டவணை (Master Ledger & Passbook)
          // -------------------------------------------------------------
          _customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_chart_outlined, size: 55, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text('கடன் விவரங்கள் எதுவும் இல்லை!', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _customers.length,
                  itemBuilder: (ctx, idx) {
                    final c = _customers[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(radius: 14, backgroundColor: Colors.teal.shade100, child: Text('${c.orderNo}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 8),
                                    Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D7C66))),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _customers.removeAt(idx);
                                      for (int i = 0; i < _customers.length; i++) {
                                        _customers[i].orderNo = i + 1;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text('${c.ownerName} • 📞 ${c.phone}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _ledgerInfo('அசல் கடன்', '₹${c.totalLoan.toInt()}', Colors.black87),
                                _ledgerInfo('கட்டியது (${c.daysPaidCount} நாள்)', '₹${c.paidAmount.toInt()}', Colors.green),
                                _ledgerInfo('மீதி பாக்கி', '₹${c.balance.toInt()}', Colors.red),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.menu_book, size: 16),
                                label: const Text('பாஸ்புக் அட்டவணையைக் காட்டு'),
                                onPressed: () => _openPassbookDialog(c),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String val, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _ledgerInfo(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

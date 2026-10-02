import 'package:flutter/material.dart';

void main() {
  runApp(const VasoolRajaApp());
}

// ---------------------------------------------------------------------------
// 1. விளம்பர பேனர் விட்ஜெட் (Ad Banner)
// ---------------------------------------------------------------------------
class SmartAdBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SmartAdBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.campaign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF15803D), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AD',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. தரவு மாதிரிகள் (Data Models)
// ---------------------------------------------------------------------------
class Staff {
  String id;
  String name;
  String routeName;
  String phone;
  String password;
  int battery;
  String currentLocation;
  int speed;
  Color markerColor;

  Staff({
    required this.id,
    required this.name,
    required this.routeName,
    required this.phone,
    required this.password,
    this.battery = 95,
    this.currentLocation = 'வசூல் லைனில் உள்ளார்',
    this.speed = 20,
    this.markerColor = Colors.blue,
  });
}

class CustomerLoan {
  String id;
  String name;
  String shopName;
  String phone;
  String staffId;
  double totalAmount;
  double deduction;
  double dailyDue;
  int totalDays;
  int daysPaid;
  bool isPaidToday;

  CustomerLoan({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.staffId,
    required this.totalAmount,
    required this.deduction,
    required this.dailyDue,
    this.totalDays = 100,
    this.daysPaid = 0,
    this.isPaidToday = false,
  });

  double get totalCollected => daysPaid * dailyDue;
  double get remainingBalance => totalAmount - totalCollected;
}

// ---------------------------------------------------------------------------
// 3. முதன்மை செயலி (Main App Entry)
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainAppController(),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. முதன்மை கட்டுப்படுத்தி (Main State Controller)
// ---------------------------------------------------------------------------
class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  int _activeScreen = 0; // 0: லாகின், 1: முதலாளி, 2: பையன், 3: கஸ்டமர்
  String _currentStaffId = '';
  CustomerLoan? _loggedInCustomer;
  String _ownerPassword = '1234'; // முதலாளி முதல் முறை நுழைய எளிய பாஸ்வேர்ட்

  // முற்றிலும் காலியான பட்டியல்கள் (எந்த டம்மி பெயர்களும் இல்லை!)
  final List<Staff> _staffList = [];
  final List<CustomerLoan> _customerList = [];

  // புதிய கஸ்டமர் சேர்க்க
  void _addCustomer(CustomerLoan c) {
    setState(() {
      _customerList.insert(0, c);
    });
  }

  // கஸ்டமரை நீக்க
  void _deleteCustomer(String id) {
    setState(() {
      _customerList.removeWhere((c) => c.id == id);
    });
  }

  // புதிய வசூல் பையன் சேர்க்க
  void _addStaff(Staff s) {
    setState(() {
      _staffList.add(s);
    });
  }

  // பையன் விவரம் மாற்ற
  void _editStaff(Staff updated) {
    setState(() {
      int idx = _staffList.indexWhere((s) => s.id == updated.id);
      if (idx != -1) _staffList[idx] = updated;
    });
  }

  // பையனை நீக்க
  void _deleteStaff(String id) {
    setState(() {
      _staffList.removeWhere((s) => s.id == id);
    });
  }

  // பையன் வசூல் டிக் செய்ய
  void _markDailyPaid(CustomerLoan c) {
    setState(() {
      c.isPaidToday = true;
      c.daysPaid += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeScreen == 0) {
      return RoleSelectionScreen(
        ownerPassword: _ownerPassword,
        staffList: _staffList,
        customerList: _customerList,
        onOwnerLoginSuccess: () => setState(() => _activeScreen = 1),
        onStaffLoginSuccess: (id) => setState(() {
          _currentStaffId = id;
          _activeScreen = 2;
        }),
        onCustomerLoginSuccess: (customer) => setState(() {
          _loggedInCustomer = customer;
          _activeScreen = 3;
        }),
      );
    } else if (_activeScreen == 1) {
      return OwnerDashboardScreen(
        ownerPassword: _ownerPassword,
        staffList: _staffList,
        customerList: _customerList,
        onAddCustomer: _addCustomer,
        onDeleteCustomer: _deleteCustomer,
        onAddStaff: _addStaff,
        onEditStaff: _editStaff,
        onDeleteStaff: _deleteStaff,
        onUpdateOwnerPassword: (pwd) => setState(() => _ownerPassword = pwd),
        onLogout: () => setState(() => _activeScreen = 0),
      );
    } else if (_activeScreen == 2) {
      final staff = _staffList.firstWhere(
        (s) => s.id == _currentStaffId,
        orElse: () => _staffList.first,
      );
      return StaffCollectionScreen(
        staff: staff,
        customerList: _customerList,
        onMarkPaid: _markDailyPaid,
        onLogout: () => setState(() => _activeScreen = 0),
      );
    } else {
      return CustomerPassbookScreen(
        customer: _loggedInCustomer!,
        onLogout: () => setState(() => _activeScreen = 0),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// காட்சி 1: லாகின் முகப்புத் திரை
// ---------------------------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String ownerPassword;
  final List<Staff> staffList;
  final List<CustomerLoan> customerList;
  final VoidCallback onOwnerLoginSuccess;
  final Function(String) onStaffLoginSuccess;
  final Function(CustomerLoan) onCustomerLoginSuccess;

  const RoleSelectionScreen({
    super.key,
    required this.ownerPassword,
    required this.staffList,
    required this.customerList,
    required this.onOwnerLoginSuccess,
    required this.onStaffLoginSuccess,
    required this.onCustomerLoginSuccess,
  });

  void _showOwnerDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('முதலாளி லாகின் 🔒', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('பாஸ்வேர்ட் உள்ளிடவும் (Default: $ownerPassword):', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'எடுத்துக்காட்டு: 1234',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            onPressed: () {
              if (ctrl.text.trim() == ownerPassword) {
                Navigator.pop(ctx);
                onOwnerLoginSuccess();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('தவறான பாஸ்வேர்ட்!')));
              }
            },
            child: const Text('உள்நுழை'),
          ),
        ],
      ),
    );
  }

  void _showStaffDialog(BuildContext context, Staff staff) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${staff.name} லாகின் 🛵', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${staff.routeName} வசூலுக்கு பாஸ்வேர்ட் உள்ளிடவும்:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'எடுத்துக்காட்டு: பாஸ்வேர்ட்',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              if (ctrl.text.trim() == staff.password) {
                Navigator.pop(ctx);
                onStaffLoginSuccess(staff.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('தவறான பாஸ்வேர்ட்!')));
              }
            },
            child: const Text('உள்நுழை'),
          ),
        ],
      ),
    );
  }

  void _showCustomerPhoneDialog(BuildContext context) {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('கஸ்டமர் லாகின் 👤', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('பதிவு செய்த 10-இலக்க மொபைல் எண்ணை உள்ளிடவும்:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'எடுத்துக்காட்டு: 9876543210',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB45309), foregroundColor: Colors.white),
            onPressed: () {
              String entered = phoneCtrl.text.trim();
              if (entered.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('மொபைல் எண்ணை உள்ளிடவும்!')));
                return;
              }
              final match = customerList.where((c) => c.phone.trim() == entered).toList();
              if (match.isNotEmpty) {
                Navigator.pop(ctx);
                onCustomerLoginSuccess(match.first);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('$entered என்ற எண் கடன் பதிவில் இல்லை! முதலாளியைத் தொடர்பு கொள்ளவும்.'),
                  ),
                );
              }
            },
            child: const Text('அட்டையைக் காட்டு'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('வசூல் ராஜா 👑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D7C66),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SmartAdBanner(
              title: '📢 தொழில் கடன் மற்றும் நிதி மேலாண்மை',
              subtitle: 'குறைந்த வட்டியில் எளிய தண்டு கடன் கணக்குகள்',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 14),
            const Text(
              'நீங்கள் யார் என்று தேர்ந்தெடுக்கவும்:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 1. முதலாளி
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28)),
                title: const Text('முதலாளி (Owner)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: const Text('முழு கணக்குகள் & புதிய கடன் சேர்க்க'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showOwnerDialog(context),
              ),
            ),
            const SizedBox(height: 14),

            // 2. வசூல் பசங்கள்
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ExpansionTile(
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFF0D7C66), child: Icon(Icons.two_wheeler, color: Colors.white, size: 28)),
                title: const Text('வசூல் பையன் (Staff)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: Text(staffList.isEmpty ? 'பசங்கள் யாரும் இன்னும் சேர்க்கப்படவில்லை' : '${staffList.length} பேர் உள்ளனர்'),
                children: staffList.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(
                            '⚠️ வசூல் பசங்கள் யாரும் இல்லை!\nமுதலாளி கணக்கில் உள்நுழைந்து "பையன் சேர்" மூலம் சேர்க்கவும்.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      ]
                    : staffList.map((s) => ListTile(
                          leading: const Icon(Icons.lock_outline, color: Colors.teal),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${s.routeName} • 📞 ${s.phone}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showStaffDialog(context, s),
                        )).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 3. வாடிக்கையாளர்
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFFB45309), child: Icon(Icons.grid_on, color: Colors.white, size: 28)),
                title: const Text('வாடிக்கையாளர் / கடைக்காரர்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: const Text('மொபைல் எண் அடித்து 100 நாள் மஞ்சள் அட்டை பார்க்க'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showCustomerPhoneDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// காட்சி 2: முதலாளி நிர்வாகத் திரை
// ---------------------------------------------------------------------------
class OwnerDashboardScreen extends StatefulWidget {
  final String ownerPassword;
  final List<Staff> staffList;
  final List<CustomerLoan> customerList;
  final Function(CustomerLoan) onAddCustomer;
  final Function(String) onDeleteCustomer;
  final Function(Staff) onAddStaff;
  final Function(Staff) onEditStaff;
  final Function(String) onDeleteStaff;
  final Function(String) onUpdateOwnerPassword;
  final VoidCallback onLogout;

  const OwnerDashboardScreen({
    super.key,
    required this.ownerPassword,
    required this.staffList,
    required this.customerList,
    required this.onAddCustomer,
    required this.onDeleteCustomer,
    required this.onAddStaff,
    required this.onEditStaff,
    required this.onDeleteStaff,
    required this.onUpdateOwnerPassword,
    required this.onLogout,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // புதிய கடன் சேர்க்கும் விண்டோ
  void _openAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final shopCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dedCtrl = TextEditingController();
    String selectedStaff = widget.staffList.isNotEmpty ? widget.staffList.first.id : 'DIRECT';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF0D7C66)),
              SizedBox(width: 8),
              Text('புதிய கடன் தொடங்கு ➕', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: shopCtrl,
                  decoration: const InputDecoration(
                    labelText: 'கடையின் பெயர் *',
                    hintText: 'எடுத்துக்காட்டு: ராஜா மளிகைக் கடை',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'உரிமையாளர் பெயர் *',
                    hintText: 'எடுத்துக்காட்டு: ராஜா',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: '10-இலக்க மொபைல் எண் *',
                    hintText: 'எடுத்துக்காட்டு: 9876543210',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'கடன் தொகை ₹ *',
                          hintText: 'எடுத்துக்காட்டு: 10000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: dedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'பிடித்தம் ₹ *',
                          hintText: 'எடுத்துக்காட்டு: 1000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedStaff,
                  decoration: const InputDecoration(
                    labelText: 'வசூல் முறை / பையன்',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'DIRECT', child: Text('நேரடி வசூல் (முதலாளி)')),
                    ...widget.staffList.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.routeName})'))),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedStaff = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ரத்து செய்', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
              onPressed: () {
                String shop = shopCtrl.text.trim();
                String name = nameCtrl.text.trim();
                String phone = phoneCtrl.text.trim();

                if (shop.isEmpty || name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('கடை பெயர், நபர் பெயர் மற்றும் மொபைல் எண் கட்டாயம்!')),
                  );
                  return;
                }

                double amt = double.tryParse(amountCtrl.text.trim()) ?? 10000;
                double ded = double.tryParse(dedCtrl.text.trim()) ?? 1000;

                final newLoan = CustomerLoan(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  shopName: shop,
                  phone: phone,
                  staffId: selectedStaff,
                  totalAmount: amt,
                  deduction: ded,
                  dailyDue: amt / 100, // 100 நாள் தண்டு தவணை
                  totalDays: 100,
                  daysPaid: 0,
                  isPaidToday: false,
                );

                widget.onAddCustomer(newLoan);
                Navigator.pop(ctx);
                setState(() {}); // திரையை உடனே ரீஃப்ரெஷ் செய்கிறோம்

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.green, content: Text('$shop கடன் கணக்கு தொடங்கப்பட்டது!')),
                );
              },
              child: const Text('சேமிக்க'),
            ),
          ],
        ),
      ),
    );
  }

  // புதிய வசூல் பையன் சேர்க்கும் விண்டோ
  void _openStaffFormDialog({Staff? editItem}) {
    final nameCtrl = TextEditingController(text: editItem?.name ?? '');
    final routeCtrl = TextEditingController(text: editItem?.routeName ?? '');
    final phoneCtrl = TextEditingController(text: editItem?.phone ?? '');
    final pwdCtrl = TextEditingController(text: editItem?.password ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(editItem == null ? 'புதிய வசூல் பையன் சேர் 🛵' : 'பையன் விவரங்களை மாற்று ✏️', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'பையன் பெயர் *',
                  hintText: 'எடுத்துக்காட்டு: கார்த்திக்',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: routeCtrl,
                decoration: const InputDecoration(
                  labelText: 'வசூல் லைன் / ரூட் *',
                  hintText: 'எடுத்துக்காட்டு: லைன் 1 (பல்லடம் ரோடு)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'மொபைல் எண்',
                  hintText: 'எடுத்துக்காட்டு: 9876500001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pwdCtrl,
                decoration: const InputDecoration(
                  labelText: 'பையன் லாகின் பாஸ்வேர்ட் *',
                  hintText: 'எடுத்துக்காட்டு: Pass_123@',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || routeCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('பெயர் மற்றும் ரூட் கட்டாயம்!')));
                return;
              }
              if (editItem == null) {
                final s = Staff(
                  id: 'S_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  routeName: routeCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty ? '9876500000' : phoneCtrl.text.trim(),
                  password: pwdCtrl.text.trim().isEmpty ? '1234' : pwdCtrl.text.trim(),
                  markerColor: Colors.primaries[widget.staffList.length % Colors.primaries.length],
                );
                widget.onAddStaff(s);
              } else {
                editItem.name = nameCtrl.text.trim();
                editItem.routeName = routeCtrl.text.trim();
                editItem.phone = phoneCtrl.text.trim();
                editItem.password = pwdCtrl.text.trim();
                widget.onEditStaff(editItem);
              }
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('சேமிக்க'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalBook = widget.customerList.fold(0, (sum, c) => sum + c.totalAmount);
    double totalCollected = widget.customerList.fold(0, (sum, c) => sum + c.totalCollected);
    double pending = totalBook - totalCollected;
    double todayDone = widget.customerList.where((c) => c.isPaidToday).fold(0, (sum, c) => sum + c.dailyDue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('முதலாளி மேலாண்மை 💼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: widget.onLogout),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'கடன் கணக்குகள்'),
            Tab(icon: Icon(Icons.two_wheeler), text: 'வசூல் பசங்கள்'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D7C66),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 1 ? 'பையன் சேர் 🛵' : 'கடன் சேர் ➕', style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          if (_tabController.index == 1) {
            _openStaffFormDialog();
          } else {
            _openAddCustomerDialog();
          }
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------------- டேப் 1: கடன் கணக்குகள் ----------------
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('வெளி நிற்கும் மொத்த பாக்கி', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹${pending.toInt()}', style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white24, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statBox('மொத்த அசல்', '₹${totalBook.toInt()}', Colors.white),
                            _statBox('வசூலானது', '₹${totalCollected.toInt()}', Colors.lightGreenAccent),
                            _statBox('இன்றைய வசூல்', '₹${todayDone.toInt()}', Colors.cyanAccent),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('கடைகள் பட்டியல் (${widget.customerList.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
                      onPressed: _openAddCustomerDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('கடன் சேர்'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (widget.customerList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text('இன்னும் எந்தக் கடையும் சேர்க்கப்படவில்லை!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        const Text('மேலே உள்ள "கடன் சேர்" பட்டனைத் தட்டி புதிய கஸ்டமரைச் சேர்க்கவும்.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ...widget.customerList.map((c) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.isPaidToday ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(c.isPaidToday ? Icons.check : Icons.access_time, color: c.isPaidToday ? Colors.green : Colors.red),
                        ),
                        title: Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D7C66))),
                        subtitle: Text('${c.name} • 📞 ${c.phone}\nகட்டியது: ${c.daysPaid}/100 நாள் • தவணை: ₹${c.dailyDue.toInt()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('பாக்கி: ₹${c.remainingBalance.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                Text(c.isPaidToday ? '✓ வாங்கியது' : 'பாக்கி', style: TextStyle(color: c.isPaidToday ? Colors.green : Colors.grey, fontSize: 11)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () => widget.onDeleteCustomer(c.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ---------------- டேப் 2: வசூல் பசங்கள் மேலாண்மை ----------------
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
                onPressed: () => _openStaffFormDialog(),
                icon: const Icon(Icons.add),
                label: const Text('புதிய வசூல் பையனைச் சேர்க்க 🛵'),
              ),
              const SizedBox(height: 12),
              if (widget.staffList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.two_wheeler, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text('வசூல் பசங்கள் யாரும் இல்லை!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 6),
                      const Text('"புதிய வசூல் பையனைச் சேர்க்க" பட்டனைத் தட்டி பசங்களைச் சேர்க்கவும்.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                    ],
                  ),
                )
              else
                ...widget.staffList.map((s) {
                  final theirCust = widget.customerList.where((c) => c.staffId == s.id).toList();
                  double target = theirCust.fold(0, (sum, c) => sum + c.dailyDue);
                  double done = theirCust.where((c) => c.isPaidToday).fold(0, (sum, c) => sum + c.dailyDue);

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
                                  CircleAvatar(backgroundColor: s.markerColor, child: const Icon(Icons.two_wheeler, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('${s.routeName} • 📞 ${s.phone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openStaffFormDialog(editItem: s)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.onDeleteStaff(s.id)),
                                ],
                              )
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('லாகின் பாஸ்வேர்ட்: ${s.password}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 12)),
                              Text('இன்றைய வசூல்: ₹${done.toInt()} / ₹${target.toInt()}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String t, String v, Color c) {
    return Column(
      children: [
        Text(t, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// காட்சி 3: வசூல் பையன் திரை
// ---------------------------------------------------------------------------
class StaffCollectionScreen extends StatelessWidget {
  final Staff staff;
  final List<CustomerLoan> customerList;
  final Function(CustomerLoan) onMarkPaid;
  final VoidCallback onLogout;

  const StaffCollectionScreen({
    super.key,
    required this.staff,
    required this.customerList,
    required this.onMarkPaid,
    required this.onLogout,
  });

  void _showQrDialog(BuildContext context, CustomerLoan c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${c.shopName} - UPI QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 160, height: 160, color: Colors.grey.shade200, child: const Icon(Icons.qr_code_2, size: 140, color: Color(0xFF0D7C66))),
            const SizedBox(height: 10),
            Text('செலுத்த வேண்டிய தொகை: ₹${c.dailyDue.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onMarkPaid(c);
            },
            child: const Text('பணம் வாங்கியாச்சு (டிக் செய்)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myShops = customerList.where((c) => c.staffId == staff.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${staff.name} - ${staff.routeName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        backgroundColor: const Color(0xFF0D7C66),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: onLogout),
        ],
      ),
      body: myShops.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('உங்களுக்கு இன்னும் கடைகள் ஒதுக்கப்படவில்லை!\nமுதலாளி புதிய கடைகளை ஒதுக்கியதும் இங்கு தெரியும்.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: myShops.length,
              itemBuilder: (ctx, idx) {
                final c = myShops[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D7C66))),
                                Text('${c.name} • 📞 ${c.phone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            Text('₹${c.dailyDue.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('கட்டியது: ${c.daysPaid}/100 நாள்'),
                            Text('பாக்கி: ₹${c.remainingBalance.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (!c.isPaidToday)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
                                  onPressed: () => onMarkPaid(c),
                                  icon: const Icon(Icons.check),
                                  label: const Text('வாங்கியாச்சு (Pay)'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(onPressed: () => _showQrDialog(context, c), icon: const Icon(Icons.qr_code_2))
                            ],
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('✓ இன்றைய வசூல் முடிந்தது', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// காட்சி 4: கஸ்டமரின் 100 நாள் மஞ்சள் அட்டை (Digital Passbook)
// ---------------------------------------------------------------------------
class CustomerPassbookScreen extends StatelessWidget {
  final CustomerLoan customer;
  final VoidCallback onLogout;

  const CustomerPassbookScreen({
    super.key,
    required this.customer,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF5),
      appBar: AppBar(
        title: Text('${customer.shopName} - பாஸ்புக்', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB45309),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Card(
              color: const Color(0xFFFEF3C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(customer.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                    const SizedBox(height: 4),
                    Text('உரிமையாளர்: ${customer.name} • 📞 ${customer.phone}'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('கடன்: ₹${customer.totalAmount.toInt()}'),
                        Text('தினசரி தவணை: ₹${customer.dailyDue.toInt()}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('கட்டியது: ₹${customer.totalCollected.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('பாக்கி: ₹${customer.remainingBalance.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('100 நாள் தவணை அட்டை (பச்சை = வாங்கியது):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: 100,
              itemBuilder: (ctx, i) {
                int day = i + 1;
                bool isPaid = day <= customer.daysPaid;
                return Container(
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFF2E7D32) : Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('$day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.white : Colors.black87)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

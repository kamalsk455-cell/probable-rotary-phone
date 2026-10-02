import 'package:flutter/material.dart';

void main() {
  runApp(const VasoolRajaApp());
}

// -------------------------------------------------------------
// 1. விளம்பர பேனர் விட்ஜெட் (AdMob Smart Banner)
// -------------------------------------------------------------
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: const Color(0xFF15803D), size: 20),
          ),
          const SizedBox(width: 8),
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
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(3)),
                      child: const Text('Ad', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.brown)),
                    )
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
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

// -------------------------------------------------------------
// 2. தரவு மாதிரிகள் (Data Models)
// -------------------------------------------------------------
class Staff {
  final String id;
  final String name;
  final String routeName;
  final String phone;
  String password;
  final int battery;
  final String currentLocation;
  final int speed;
  final Color markerColor;
  final double mapTop;
  final double mapLeft;
  final String nextShop;

  Staff({
    required this.id,
    required this.name,
    required this.routeName,
    required this.phone,
    required this.password,
    required this.battery,
    required this.currentLocation,
    required this.speed,
    required this.markerColor,
    required this.mapTop,
    required this.mapLeft,
    required this.nextShop,
  });
}

class CustomerLoan {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  String staffId;
  final double totalAmount;
  final double deduction;
  final double dailyDue;
  final int totalDays;
  int daysElapsed;
  int daysPaid;
  bool isPaidToday;
  bool cancellationRequested;
  String cancelReason;

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
    this.daysElapsed = 1,
    this.daysPaid = 0,
    this.isPaidToday = false,
    this.cancellationRequested = false,
    this.cancelReason = '',
  });

  double get cashGiven => totalAmount - deduction;
  double get totalCollected => daysPaid * dailyDue;
  double get remainingBalance => totalAmount - totalCollected;
  bool get isOverdue => daysElapsed > totalDays && daysPaid < totalDays;
  int get overdueDays => daysElapsed > totalDays ? (daysElapsed - totalDays) : 0;
}

// -------------------------------------------------------------
// 3. முதன்மை ஆப் (App Root)
// -------------------------------------------------------------
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
      ),
      home: const MainAppController(),
    );
  }
}

// -------------------------------------------------------------
// 4. முதன்மை கட்டுப்படுத்தி & லாகின் மேலாண்மை
// -------------------------------------------------------------
enum AppRole { selectRole, owner, staff, customer }

class MainAppController extends StatefulWidget {
  const MainAppController({super.key});

  @override
  State<MainAppController> createState() => _MainAppControllerState();
}

class _MainAppControllerState extends State<MainAppController> {
  AppRole _currentRole = AppRole.selectRole;
  String _loggedInStaffId = 'S1';
  String _loggedInCustomerPhone = '9876543210';
  String _ownerPassword = 'Boss_123@';

  final List<Staff> _staffList = [
    Staff(
      id: 'S1',
      name: 'கார்த்திக்',
      routeName: 'லைன் 1 (பல்லடம் ரோடு)',
      phone: '9876500001',
      password: 'Karthik_99@',
      battery: 85,
      currentLocation: 'பல்லடம் ரோடு, காமராஜ் சிலை',
      speed: 24,
      markerColor: Colors.blue.shade900,
      mapTop: 140,
      mapLeft: 120,
      nextShop: 'செல்வம் டீ ஸ்டால் (350மீ)',
    ),
    Staff(
      id: 'S2',
      name: 'முருகன்',
      routeName: 'லைன் 2 (காங்கேயம் ரோடு)',
      phone: '9876500002',
      password: 'Murugan_88#',
      battery: 64,
      currentLocation: 'காங்கேயம் ரவுண்டானா',
      speed: 18,
      markerColor: Colors.deepOrange.shade800,
      mapTop: 230,
      mapLeft: 220,
      nextShop: 'முத்து பேக்கரி (500மீ)',
    ),
  ];

  final List<CustomerLoan> _customers = [
    CustomerLoan(
      id: '1',
      name: 'ராஜா',
      shopName: 'ராஜா மளிகைக் கடை',
      phone: '9876543210',
      staffId: 'S1',
      totalAmount: 10000,
      deduction: 1000,
      dailyDue: 100,
      daysElapsed: 50,
      daysPaid: 45,
      isPaidToday: false,
    ),
    CustomerLoan(
      id: '2',
      name: 'செல்வம்',
      shopName: 'செல்வம் டீ ஸ்டால்',
      phone: '9876543211',
      staffId: 'S1',
      totalAmount: 10000,
      deduction: 800,
      dailyDue: 100,
      daysElapsed: 95,
      daysPaid: 92,
      isPaidToday: true,
    ),
    CustomerLoan(
      id: '3',
      name: 'குமார்',
      shopName: 'குமார் காய்கறி மண்டி',
      phone: '9876543212',
      staffId: 'S2',
      totalAmount: 20000,
      deduction: 2000,
      dailyDue: 200,
      daysElapsed: 115,
      daysPaid: 75,
      isPaidToday: true,
      cancellationRequested: true,
      cancelReason: 'ஒரே வீடு, அண்ணன் கார்டுக்கு பதிலா தம்பிக்கு போட்டாச்சு!',
    ),
    CustomerLoan(
      id: '4',
      name: 'முத்து',
      shopName: 'முத்து பேக்கரி',
      phone: '9876543213',
      staffId: 'S2',
      totalAmount: 10000,
      deduction: 1000,
      dailyDue: 100,
      daysElapsed: 30,
      daysPaid: 25,
      isPaidToday: false,
    ),
  ];

  void _addNewLoan(CustomerLoan newLoan) {
    setState(() {
      _customers.add(newLoan);
    });
  }

  void _markAsPaid(CustomerLoan customer) {
    setState(() {
      customer.isPaidToday = true;
      customer.daysPaid += 1;
      customer.cancellationRequested = false;
      customer.cancelReason = '';
    });
  }

  void _requestCancel(CustomerLoan customer, String reason) {
    setState(() {
      customer.cancellationRequested = true;
      customer.cancelReason = reason;
    });
  }

  void _approveCancel(CustomerLoan customer) {
    setState(() {
      customer.isPaidToday = false;
      if (customer.daysPaid > 0) customer.daysPaid -= 1;
      customer.cancellationRequested = false;
      customer.cancelReason = '';
    });
  }

  void _rejectCancel(CustomerLoan customer) {
    setState(() {
      customer.cancellationRequested = false;
      customer.cancelReason = '';
    });
  }

  void _logout() {
    setState(() {
      _currentRole = AppRole.selectRole;
    });
  }

  void _updateOwnerPassword(String newPassword) {
    setState(() {
      _ownerPassword = newPassword;
    });
  }

  void _updateStaffPassword(String staffId, String newPassword) {
    setState(() {
      final staff = _staffList.firstWhere((s) => s.id == staffId);
      staff.password = newPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentRole) {
      case AppRole.selectRole:
        return RoleLoginScreen(
          ownerPassword: _ownerPassword,
          staffList: _staffList,
          onOwnerLoginSuccess: () => setState(() => _currentRole = AppRole.owner),
          onStaffLoginSuccess: (staffId) {
            setState(() {
              _loggedInStaffId = staffId;
              _currentRole = AppRole.staff;
            });
          },
          onCustomerLoginSuccess: (phone) {
            setState(() {
              _loggedInCustomerPhone = phone;
              _currentRole = AppRole.customer;
            });
          },
        );

      case AppRole.owner:
        return OwnerDashboardScreen(
          ownerPassword: _ownerPassword,
          staffList: _staffList,
          customers: _customers,
          onAddLoan: _addNewLoan,
          onApproveCancel: _approveCancel,
          onRejectCancel: _rejectCancel,
          onUpdateOwnerPassword: _updateOwnerPassword,
          onUpdateStaffPassword: _updateStaffPassword,
          onLogout: _logout,
        );

      case AppRole.staff:
        return StaffRouteScreen(
          staff: _staffList.firstWhere((s) => s.id == _loggedInStaffId),
          customers: _customers,
          onPaid: _markAsPaid,
          onRequestCancel: _requestCancel,
          onLogout: _logout,
        );

      case AppRole.customer:
        CustomerLoan userLoan = _customers.firstWhere(
          (c) => c.phone == _loggedInCustomerPhone,
          orElse: () => _customers.first,
        );
        return CustomerPortalScreen(
          customer: userLoan,
          onLogout: _logout,
        );
    }
  }
}

// -------------------------------------------------------------
// காட்சி 0: லாகின் திரை
// -------------------------------------------------------------
class RoleLoginScreen extends StatelessWidget {
  final String ownerPassword;
  final List<Staff> staffList;
  final VoidCallback onOwnerLoginSuccess;
  final Function(String) onStaffLoginSuccess;
  final Function(String) onCustomerLoginSuccess;

  const RoleLoginScreen({
    super.key,
    required this.ownerPassword,
    required this.staffList,
    required this.onOwnerLoginSuccess,
    required this.onStaffLoginSuccess,
    required this.onCustomerLoginSuccess,
  });

  void _showOwnerPasswordDialog(BuildContext context) {
    final pwdController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('முதலாளி ரகசிய பாஸ்வேர்ட் 🔒'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('பாஸ்வேர்டை உள்ளிடவும் (Default: $ownerPassword):'),
              const SizedBox(height: 12),
              TextField(
                controller: pwdController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'பாஸ்வேர்ட் (குறியீடுகளுடன்)',
                  hintText: 'எ.கா: Boss_123@',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlgState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
              onPressed: () {
                if (pwdController.text == ownerPassword) {
                  Navigator.pop(ctx);
                  onOwnerLoginSuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.red, content: Text('தவறான பாஸ்வேர்ட்! அணுகல் மறுக்கப்பட்டது.')),
                  );
                }
              },
              child: const Text('உள்நுழை'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffPasswordDialog(BuildContext context, Staff staff) {
    final pwdController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('${staff.name} பாஸ்வேர்ட் 🛵'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${staff.routeName} வசூலைத் தொடங்க பாஸ்வேர்டை அடிக்கவும் (Default: ${staff.password}):'),
              const SizedBox(height: 12),
              TextField(
                controller: pwdController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'பையன் பாஸ்வேர்ட்',
                  hintText: 'எ.கா: Karthik_99@',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlgState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
              onPressed: () {
                if (pwdController.text == staff.password) {
                  Navigator.pop(ctx);
                  onStaffLoginSuccess(staff.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.red, content: Text('தவறான பாஸ்வேர்ட்! நீங்கள் உள்நுழைய முடியாது.')),
                  );
                }
              },
              child: const Text('வசூலைத் தொடங்கு'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPhoneDialog(BuildContext context) {
    final phoneController = TextEditingController(text: '9876543210');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('கஸ்டமர் லாகின் 👤'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('பதிவுசெய்த மொபைல் எண்ணை உள்ளிடவும்:'),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'மொபைல் எண்', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const Text('மாதிரி: 9876543210 (ராஜா), 9876543212 (குமார்)', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பு')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB45309), foregroundColor: Colors.white),
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                onCustomerLoginSuccess(phoneController.text.trim());
              }
            },
            child: const Text('அட்டையைப் பார்'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('வசூல் ராஜா 👑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D7C66),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SmartAdBanner(
              title: '📢 வணிக கடன் & நிதி மேலாண்மை தீர்வுகள்',
              subtitle: 'குறைந்த வட்டியில் உடனடி கடன் | Sponsored',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 14),
            const Text(
              'நீங்கள் யார் என்று தேர்ந்தெடுக்கவும்:\n(வலுவான குறியீட்டு பாஸ்வேர்ட் பாதுகாப்புடன்)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFF1E293B), child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28)),
                title: const Text('முதலாளி (Owner)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: const Text('முழு கணக்கு, GPS மேப், பாஸ்வேர்ட் மேலாண்மை'),
                trailing: const Icon(Icons.lock, color: Colors.amber),
                onTap: () => _showOwnerPasswordDialog(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFF0D7C66), child: Icon(Icons.two_wheeler, color: Colors.white, size: 28)),
                title: const Text('வசூல் பையன் (Agent Password)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: const Text('பையனின் பிரத்யேக பாஸ்வேர்ட் அடித்தால் மட்டுமே திறக்கும்'),
                children: staffList.map((s) => ListTile(
                  leading: const Icon(Icons.lock_outline, size: 20, color: Colors.teal),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.routeName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showStaffPasswordDialog(context, s),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(radius: 26, backgroundColor: Color(0xFFB45309), child: Icon(Icons.grid_on, color: Colors.white, size: 28)),
                title: const Text('கடைக்காரர் / வாடிக்கையாளர்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: const Text('100 நாள் டிஜிட்டல் மஞ்சள் அட்டை (மொபைல் எண் லாகின்)'),
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

// -------------------------------------------------------------
// காட்சி 1: வசூல் பையன் திரை
// -------------------------------------------------------------
class StaffRouteScreen extends StatelessWidget {
  final Staff staff;
  final List<CustomerLoan> customers;
  final Function(CustomerLoan) onPaid;
  final Function(CustomerLoan, String) onRequestCancel;
  final VoidCallback onLogout;

  const StaffRouteScreen({
    super.key,
    required this.staff,
    required this.customers,
    required this.onPaid,
    required this.onRequestCancel,
    required this.onLogout,
  });

  void _showQrDialog(BuildContext context, CustomerLoan customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${customer.shopName} - UPI QR', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2, size: 160, color: Color(0xFF0D7C66)),
            ),
            const SizedBox(height: 12),
            Text('செலுத்த வேண்டிய தொகை: ₹${customer.dailyDue.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 4),
            const Text('GPay / PhonePe மூலம் ஸ்கேன் செய்யலாம்', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              onPaid(customer);
            },
            child: const Text('பணம் வந்துவிட்டது (டிக் செய்)'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, CustomerLoan customer) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ரத்து செய்யக் கோரிக்கை'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${customer.shopName} பதிவை ரத்து செய்ய காரணம் எழுதுங்க:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'காரணம் என்ன? (கட்டாயம்)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('திரும்பி போ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              onRequestCancel(customer, reasonController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('கோரிக்கை அனுப்பு'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffCustomers = customers.where((c) => c.staffId == staff.id).toList();
    double target = staffCustomers.fold(0, (sum, i) => sum + i.dailyDue);
    double collected = staffCustomers.where((i) => i.isPaidToday).fold(0, (sum, i) => sum + i.dailyDue);

    return Scaffold(
      appBar: AppBar(
        title: Text('${staff.name} - ${staff.routeName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D7C66),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), tooltip: 'வெளியேறு', onPressed: onLogout),
        ],
      ),
      body: Column(
        children: [
          const SmartAdBanner(
            title: '🛵 டிவிஎஸ் பைக் சிறப்பு எக்ஸ்சேஞ்ச் மேளா!',
            subtitle: 'பழைய பைக்கைக் கொடுத்து புதிய பைக் வாங்குங்கள் | 0% வட்டி',
            icon: Icons.two_wheeler,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF0D7C66),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Text('இன்றைய டார்கெட்', style: TextStyle(color: Colors.white70)), Text('₹${target.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                Column(children: [const Text('வசூலானது', style: TextStyle(color: Colors.white70)), Text('₹${collected.toInt()}', style: const TextStyle(color: Color(0xFF7DDA58), fontSize: 18, fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: staffCustomers.length,
              itemBuilder: (context, index) {
                final c = staffCustomers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: c.isOverdue ? Colors.red.shade300 : Colors.grey.shade200, width: c.isOverdue ? 1.5 : 1),
                  ),
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
                                Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${c.name} • 📞 ${c.phone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                              child: Text('₹${c.dailyDue.toInt()}', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 16)),
                            )
                          ],
                        ),
                        if (c.isOverdue) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red, size: 16),
                                const SizedBox(width: 6),
                                Text('⚠️ 100 நாள் முடிந்தது! (${c.overdueDays} நாள் தாமதம்)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('கட்டியது: ${c.daysPaid} / ${c.totalDays} நாள்'),
                            Text('மீதி: ₹${c.remainingBalance.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (!c.isPaidToday)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
                                  onPressed: () => onPaid(c),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('வாங்கியாச்சு (Pay)'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                onPressed: () => _showQrDialog(context, c),
                                icon: const Icon(Icons.qr_code_2),
                              )
                            ],
                          )
                        else if (c.cancellationRequested)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade700)),
                            child: const Text('⏳ ரத்து கோரிக்கை முதலாளி பார்வைக்கு அனுப்பப்பட்டுள்ளது', style: TextStyle(color: Colors.brown, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        else
                          Row(
                            children: [
                              const Expanded(child: Text('✓ இன்று வாங்கியாச்சு', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                onPressed: () => _showCancelDialog(context, c),
                                icon: const Icon(Icons.report_problem, size: 16),
                                label: const Text('தவறான பதிவு?'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// காட்சி 2: முதலாளி நிர்வாகத் திரை
// -------------------------------------------------------------
class OwnerDashboardScreen extends StatefulWidget {
  final String ownerPassword;
  final List<Staff> staffList;
  final List<CustomerLoan> customers;
  final Function(CustomerLoan) onAddLoan;
  final Function(CustomerLoan) onApproveCancel;
  final Function(CustomerLoan) onRejectCancel;
  final Function(String) onUpdateOwnerPassword;
  final Function(String, String) onUpdateStaffPassword;
  final VoidCallback onLogout;

  const OwnerDashboardScreen({
    super.key,
    required this.ownerPassword,
    required this.staffList,
    required this.customers,
    required this.onAddLoan,
    required this.onApproveCancel,
    required this.onRejectCancel,
    required this.onUpdateOwnerPassword,
    required this.onUpdateStaffPassword,
    required this.onLogout,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  void _openPasswordSettingsDialog() {
    final ownerPwdCtrl = TextEditingController(text: widget.ownerPassword);
    final karthikPwdCtrl = TextEditingController(text: widget.staffList[0].password);
    final muruganPwdCtrl = TextEditingController(text: widget.staffList[1].password);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: Colors.amber),
            SizedBox(width: 8),
            Text('பாஸ்வேர்ட் மாற்றுக 🔐', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('முதலாளி மாஸ்டர் பாஸ்வேர்ட்:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: ownerPwdCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'எ.கா: Boss_123@'),
              ),
              const Divider(height: 20),
              Text('${widget.staffList[0].name} (பையன் 1) பாஸ்வேர்ட்:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: karthikPwdCtrl,
                decoration: InputDecoration(border: const OutlineInputBorder(), hintText: 'எ.கா: ${widget.staffList[0].name}_99#'),
              ),
              const SizedBox(height: 8),
              Text('${widget.staffList[1].name} (பையன் 2) பாஸ்வேர்ட்:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: muruganPwdCtrl,
                decoration: InputDecoration(border: const OutlineInputBorder(), hintText: 'எ.கா: ${widget.staffList[1].name}_88@'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ரத்து')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7C66), foregroundColor: Colors.white),
            onPressed: () {
              if (ownerPwdCtrl.text.trim().isNotEmpty) widget.onUpdateOwnerPassword(ownerPwdCtrl.text.trim());
              if (karthikPwdCtrl.text.trim().isNotEmpty) widget.onUpdateStaffPassword(widget.staffList[0].id, karthikPwdCtrl.text.trim());
              if (muruganPwdCtrl.text.trim().isNotEmpty) widget.onUpdateStaffPassword(widget.staffList[1].id, muruganPwdCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: Colors.green, content: Text('அனைத்து பாஸ்வேர்டுகளும் பாதுகாப்பாக மாற்றப்பட்டன!')),
              );
            },
            child: const Text('சேமி (Save)'),
          ),
        ],
      ),
    );
  }

  void _openAddLoanDialog() {
    final nameCtrl = TextEditingController();
    final shopCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '10000');
    final dedCtrl = TextEditingController(text: '1000');
    String staffId = widget.staffList.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('➕ புதிய தண்டு கடன் தொடங்க', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'கஸ்டமர் பெயர்', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: shopCtrl, decoration: const InputDecoration(labelText: 'கடை பெயர் / ஊர்', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'மொபைல் எண்', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'கடன் தொகை', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: dedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'பிடித்தம்', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'வசூல் பையனை ஒதுக்குக', border: OutlineInputBorder()),
                  value: staffId,
                  items: widget.staffList.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} - ${s.routeName}'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => staffId = val);
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7C66),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || shopCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('பெயர் மற்றும் கடை பெயரை உள்ளிடவும்!')));
                      return;
                    }
                    double t = double.tryParse(totalCtrl.text) ?? 10000;
                    double d = double.tryParse(dedCtrl.text) ?? 1000;

                    final newLoan = CustomerLoan(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text,
                      shopName: shopCtrl.text,
                      phone: phoneCtrl.text.isEmpty ? 'இல்லை' : phoneCtrl.text,
                      staffId: staffId,
                      totalAmount: t,
                      deduction: d,
                      dailyDue: t / 100,
                      totalDays: 100,
                      daysElapsed: 1,
                      daysPaid: 0,
                      isPaidToday: false,
                    );

                    widget.onAddLoan(newLoan);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('புதிய கடன் சேர்க்கப்பட்டது!')));
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('கடன் கணக்கைச் சேர்'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalBook = widget.customers.fold(0, (s, i) => s + i.totalAmount);
    double totalCollectedAll = widget.customers.fold(0, (s, i) => s + i.totalCollected);
    double marketPending = totalBook - totalCollectedAll;
    double todayCollected = widget.customers.where((i) => i.isPaidToday).fold(0, (s, i) => s + i.dailyDue);
    int overdueCount = widget.customers.where((c) => c.isOverdue).length;

    final cancelRequests = widget.customers.where((c) => c.cancellationRequested).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('முதலாளி நிர்வாகம் 💼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.key, color: Colors.amberAccent),
            tooltip: 'பாஸ்வேர்ட் மாற்றுக',
            onPressed: _openPasswordSettingsDialog,
          ),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), tooltip: 'வெளியேறு', onPressed: widget.onLogout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D7C66),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('புது கடன் சேர்', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _openAddLoanDialog,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SmartAdBanner(
              title: '💼 தங்க நகை கடன் & வணிக முதலீட்டு ஆஃபர்',
              subtitle: '99 பைசா வட்டியில் உடனடி நிதி சேவை | முன்னணி வங்கி விளம்பரம்',
              icon: Icons.monetization_on,
            ),
            const SizedBox(height: 8),

            if (cancelRequests.isNotEmpty) ...[
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade300, width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('ரத்து செய்யக் கோரிக்கைகள் (${cancelRequests.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        ],
                      ),
                      const Divider(),
                      ...cancelRequests.map((req) => Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(req.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('₹${req.dailyDue.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('பையன் சொன்ன காரணம்: "${req.cancelReason}"', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13, fontStyle: FontStyle.italic)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(onPressed: () => widget.onRejectCancel(req), child: const Text('நிராகரி')),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () => widget.onApproveCancel(req),
                                      child: const Text('ஏற்றுக்கொள் (ரத்து செய்)'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('வெளி நிற்கும் மொத்த பாக்கி', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('₹${marketPending.toInt()}', style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryBox('மொத்த அசல்', '₹${totalBook.toInt()}', Colors.white),
                        _summaryBox('வசூலானது', '₹${totalCollectedAll.toInt()}', Colors.lightGreenAccent),
                        _summaryBox('இன்றைய வசூல்', '₹${todayCollected.toInt()}', Colors.cyanAccent),
                        _summaryBox('தாமதம்', '$overdueCount பேர்', Colors.redAccent),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('பசங்களின் லைவ் நிலை (LIVE)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7C66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => LiveMapRadarScreen(customers: widget.customers, staffList: widget.staffList),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('வரைபடத்தில் பார்'),
                )
              ],
            ),
            const SizedBox(height: 8),

            ...widget.staffList.map((staff) {
              final sCust = widget.customers.where((c) => c.staffId == staff.id).toList();
              double sTarget = sCust.fold(0, (s, i) => s + i.dailyDue);
              double sDone = sCust.where((i) => i.isPaidToday).fold(0, (s, i) => s + i.dailyDue);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
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
                              CircleAvatar(radius: 14, backgroundColor: staff.markerColor, child: const Icon(Icons.two_wheeler, color: Colors.white, size: 16)),
                              const SizedBox(width: 8),
                              Text('${staff.name} - ${staff.routeName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Pwd: ${staff.password}', style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 11)),
                              const SizedBox(width: 8),
                              Text('🔋 ${staff.battery}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('📍 ${staff.currentLocation} (${staff.speed} கி.மீ/மணி)', style: TextStyle(color: Colors.teal.shade800, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('இன்றைய வசூல்: ₹${sDone.toInt()} / ₹${sTarget.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('${((sTarget == 0 ? 0 : sDone / sTarget) * 100).toInt()}% முடிந்தது', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('வாடிக்கையாளர் பாக்கி விவரங்கள்', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('${widget.customers.length} கடைகள்', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.customers.length,
              itemBuilder: (context, index) {
                final c = widget.customers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.isOverdue ? Colors.red.shade100 : (c.isPaidToday ? Colors.green.shade100 : Colors.orange.shade100),
                      child: Icon(
                        c.isOverdue ? Icons.warning : (c.isPaidToday ? Icons.check : Icons.access_time),
                        color: c.isOverdue ? Colors.red : (c.isPaidToday ? Colors.green : Colors.orange),
                        size: 20,
                      ),
                    ),
                    title: Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text(c.isOverdue ? '⚠️ 100 நாள் முடிந்து ${c.overdueDays} நாள் தாமதம்' : 'கட்டியது: ₹${c.totalCollected.toInt()} (${c.daysPaid} நாள்)'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('பாக்கி: ₹${c.remainingBalance.toInt()}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text('அசல்: ₹${c.totalAmount.toInt()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(String t, String v, Color c) {
    return Column(
      children: [
        Text(t, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// -------------------------------------------------------------
// காட்சி 3: வரைபடத் திரை
// -------------------------------------------------------------
class LiveMapRadarScreen extends StatefulWidget {
  final List<CustomerLoan> customers;
  final List<Staff> staffList;

  const LiveMapRadarScreen({super.key, required this.customers, required this.staffList});

  @override
  State<LiveMapRadarScreen> createState() => _LiveMapRadarScreenState();
}

class _LiveMapRadarScreenState extends State<LiveMapRadarScreen> {
  late Staff _selectedStaff;

  @override
  void initState() {
    super.initState();
    _selectedStaff = widget.staffList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('பசங்களின் லைவ் வரைபடம் 🛰️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.greenAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedStaff.name}-ற்கு போன் செய்யப்படுகிறது...')));
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFE5E3DF),
            child: Stack(
              children: [
                Positioned(top: 150, left: 0, right: 0, child: Container(height: 40, color: Colors.white)),
                Positioned(top: 0, bottom: 0, left: 160, child: Container(width: 35, color: Colors.white)),
                Positioned(top: 240, left: 0, right: 0, child: Container(height: 35, color: Colors.white)),
                Positioned(top: 165, left: 0, right: 0, child: Container(height: 4, color: Colors.orange.shade300)),
                Positioned(top: 0, bottom: 0, left: 175, child: Container(width: 4, color: Colors.orange.shade300)),

                const Positioned(
                  top: 90,
                  left: 60,
                  child: Column(children: [Icon(Icons.store, color: Colors.green, size: 28), Text('ராஜா மளிகை\n(வாங்கியாச்சு)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green))]),
                ),
                const Positioned(
                  top: 290,
                  left: 70,
                  child: Column(children: [Icon(Icons.store, color: Colors.red, size: 28), Text('செல்வம் டீ\n(பாக்கி)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red))]),
                ),
                const Positioned(
                  top: 90,
                  right: 40,
                  child: Column(children: [Icon(Icons.store, color: Colors.red, size: 28), Text('முத்து பேக்கரி\n(பாக்கி)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red))]),
                ),

                ...widget.staffList.map((staff) {
                  bool isSelected = staff.id == _selectedStaff.id;
                  return Positioned(
                    top: staff.mapTop,
                    left: staff.mapLeft,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStaff = staff;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: staff.markerColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: isSelected ? 3 : 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? const Color(0xCCFFC107) : Colors.black26,
                                  blurRadius: isSelected ? 12 : 6,
                                  spreadRadius: isSelected ? 3 : 0,
                                )
                              ],
                            ),
                            child: const Icon(Icons.two_wheeler, color: Colors.white, size: 22),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected ? Border.all(color: Colors.amber, width: 1) : null,
                            ),
                            child: Text(
                              '${staff.name} 🛵',
                              style: TextStyle(color: isSelected ? Colors.amberAccent : Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.staffList.map((staff) {
                  bool isSelected = staff.id == _selectedStaff.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: CircleAvatar(backgroundColor: staff.markerColor, radius: 8),
                      label: Text(
                        '${staff.name} (${staff.routeName.split(' ').first})',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1E293B),
                      onSelected: (val) {
                        if (val) setState(() => _selectedStaff = staff);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: _selectedStaff.markerColor, child: const Icon(Icons.two_wheeler, color: Colors.white, size: 14)),
                            const SizedBox(width: 8),
                            Text('${_selectedStaff.name}: ${_selectedStaff.speed} கி.மீ/மணி', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Text('🔋 ${_selectedStaff.battery}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('📍 ${_selectedStaff.currentLocation}', style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('அடுத்த கடை: ${_selectedStaff.nextShop}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${_selectedStaff.name} செல்லும் கடைக்கு "பையன் வருகிறார்" என WhatsApp தகவல் அனுப்பப்பட்டது!')),
                              );
                            },
                            icon: const Icon(Icons.share_location, size: 16),
                            label: const Text('கடைக்கு WhatsApp தகவல் சொல்', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// காட்சி 4: கஸ்டமரின் பிரத்யேக டிஜிட்டல் மஞ்சள் அட்டை
// -------------------------------------------------------------
class CustomerPortalScreen extends StatelessWidget {
  final CustomerLoan customer;
  final VoidCallback onLogout;

  const CustomerPortalScreen({
    super.key,
    required this.customer,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('${customer.shopName} - பாஸ்புக் 📋', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB45309),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), tooltip: 'வெளியேறு', onPressed: onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SmartAdBanner(
              title: '📢 மளிகைக் கடை மொத்த வியாபார சலுகை!',
              subtitle: 'அரிசி, பருப்பு மூட்டைகளுக்கு 15% தள்ளுபடி | இலவச டெலிவரி',
              icon: Icons.storefront,
            ),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFFFEF3C7),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(customer.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('உரிமையாளர்: ${customer.name} • 📞 ${customer.phone}'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('கடன் தொகை: ₹${customer.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('தினசரி தவணை: ₹${customer.dailyDue.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('கட்டியது: ₹${customer.totalCollected.toInt()} (${customer.daysPaid} நாள்)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                        Text('மீதி: ₹${customer.remainingBalance.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                      ],
                    ),
                    if (customer.isOverdue) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text('⚠️ 100 நாள் முடிந்து ${customer.overdueDays} நாட்கள் தாமதம்! தயவுசெய்து விரைந்து செலுத்தவும்.', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('100 நாள் தவணை அட்டை (பச்சை நிறம் = வாங்கியது)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemCount: 100,
              itemBuilder: (context, index) {
                int dayNumber = index + 1;
                bool isPaid = dayNumber <= customer.daysPaid;
                return Container(
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFF2E7D32) : Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('$dayNumber', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.white : Colors.black87)),
                );
              },
            ),
            const SizedBox(height: 16),
            const SmartAdBanner(
              title: '📱 புதிய ஸ்மார்ட்போன் தீபாவளி தள்ளுபடி சலுகை',
              subtitle: 'மாதம் வெறும் ₹999 தவணையில் புதிய போன் | Sponsored',
              icon: Icons.phone_android,
            ),
          ],
        ),
      ),
    );
  }
}

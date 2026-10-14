
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(DompetKuV3());
class DompetKuV3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A))),
      home: MainV3(),
    );
  }
}
class MainV3 extends StatefulWidget { @override State<MainV3> createState() => _MainV3State(); }
class _MainV3State extends State<MainV3> {
  List tx = [];
  List goals = [];
  String name = "";
  String email = "";
  bool isPremium = false;
  int tab = 0;
  bool isLogin = false;
  Map<String, IconData> catIcon = {
    "Makan": Icons.restaurant_rounded,
    "Transport": Icons.directions_car_rounded,
    "Belanja": Icons.shopping_bag_rounded,
    "Gaji": Icons.work_rounded,
    "Tagihan": Icons.receipt_long_rounded,
    "Hiburan": Icons.movie_rounded,
    "Kesehatan": Icons.medical_services_rounded,
  };
  Map<String, Color> catColor = {
    "Makan": Color(0xFF06B6D4),
    "Transport": Color(0xFF3B82F6),
    "Belanja": Color(0xFFF59E0B),
    "Gaji": Color(0xFF10B981),
    "Tagihan": Color(0xFF8B5CF6),
    "Hiburan": Color(0xFFEC4899),
    "Kesehatan": Color(0xFFEF4444),
  };
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      tx = jsonDecode(sp.getString("tx") ?? "[]");
      goals = jsonDecode(sp.getString("goals") ?? "[]");
      name = sp.getString("name") ?? "";
      email = sp.getString("email") ?? "";
      isPremium = sp.getBool("premium") ?? false;
      isLogin = sp.getBool("isLogin") ?? false;
    });
  }
  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("tx", jsonEncode(tx));
    sp.setString("goals", jsonEncode(goals));
    sp.setString("name", name);
    sp.setString("email", email);
    sp.setBool("premium", isPremium);
    sp.setBool("isLogin", isLogin);
  }
  void _addTx(String type, int amount, String cat) {
    if (!isPremium && tx.length >= 50) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Free 50 limit! Upgrade bos")));
      return;
    }
    setState(() { tx.add({"type": type, "amount": amount, "cat": cat, "date": DateTime.now().toIso8601String()}); });
    _save();
  }
  void _addGoal(String title, int target) {
    setState(() { goals.add({"title": title, "target": target, "saved": 0}); });
    _save();
  }
  Future<void> _export() async {
    try {
      File f = File("/storage/emulated/0/Download/dompetku_v3.json");
      if (!await Directory("/storage/emulated/0/Download").exists()) {
        final dir = await getExternalStorageDirectory();
        f = File("${dir!.path}/backup_v3.json");
      }
      await f.writeAsString(jsonEncode({"user": name, "premium": isPremium, "tx": tx, "goals": goals}));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup: ${f.path}")));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
  }
  void _buy() { setState(() => isPremium = true); _save(); }
  @override Widget build(BuildContext context) {
    if (!isLogin) {
      return Scaffold(backgroundColor: Color(0xFF0F172A), body: Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: Icon(Icons.account_balance_wallet_rounded, size: 64, color: Color(0xFF0F172A))),
        SizedBox(height: 24),
        Text("DompetKu V3", style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
        Text("Premium Leather Wallet", style: TextStyle(color: Colors.amber.shade200, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 32),
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), padding: EdgeInsets.all(22), child: Column(children: [
          TextField(onChanged: (v) => name = v, decoration: InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 12),
          TextField(onChanged: (v) => email = v, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () { if (name.isEmpty) return; setState(() => isLogin = true); _save(); }, child: Text("MASUK KE DOMPET", style: TextStyle(fontWeight: FontWeight.bold)))),
        ])),
      ]))));
    }
    int inc = tx.where((e) => e["type"] == "in").fold(0, (s, e) => s + (e["amount"] as int));
    int out = tx.where((e) => e["type"] == "out").fold(0, (s, e) => s + (e["amount"] as int));
    int bal = inc - out;
    Map<String, int> catMap = {};
    for (var e in tx.where((e) => e["type"] == "out")) { catMap[e["cat"]] = (catMap[e["cat"]] ?? 0) + (e["amount"] as int); }
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: "Home"),
        NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label: "Analitik"),
        NavigationDestination(icon: Icon(Icons.savings_rounded), label: "Goals"),
        NavigationDestination(icon: Icon(Icons.person_rounded), label: "Akun"),
      ]),
      body: tab == 0 ? ListView(children: [
        Container(padding: EdgeInsets.fromLTRB(20, 56, 20, 24), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Halo, $name ${isPremium ? "Premium" : ""}", style: TextStyle(color: Colors.white70)), Text("Total Balance", style: TextStyle(color: Colors.white38, fontSize: 11))]),
            CircleAvatar(backgroundColor: Colors.white, child: Text(name.isEmpty ? "U" : name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
          SizedBox(height: 12),
          Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(bal), style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          SizedBox(height: 16),
          Row(children: [
            Expanded(child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 20), SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Masuk", style: TextStyle(color: Colors.white54, fontSize: 10)), Text("Rp $inc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])]))),
            SizedBox(width: 12),
            Expanded(child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(Icons.arrow_downward_rounded, color: Colors.redAccent, size: 20), SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Keluar", style: TextStyle(color: Colors.white54, fontSize: 10)), Text("Rp $out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])]))),
          ]),
        ])),
        Padding(padding: EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Transaksi Terakhir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), TextButton(onPressed: () => setState(() => tab = 1), child: Text("Lihat Semua"))])),
        ...tx.reversed.take(8).map((e) {
          return Container(margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: ListTile(leading: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: (catColor[e["cat"]] ?? Colors.grey).withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(catIcon[e["cat"]] ?? Icons.wallet_rounded, color: catColor[e["cat"]] ?? Colors.grey)), title: Text(e["cat"], style: TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(DateFormat('dd MMM').format(DateTime.parse(e["date"]))), trailing: Text("${e["type"] == "in" ? "+" : "-"} Rp ${e["amount"]}", style: TextStyle(fontWeight: FontWeight.bold, color: e["type"] == "in" ? Colors.green : Colors.black))));
        }).toList(),
        SizedBox(height: 90),
      ]) : tab == 1 ? ListView(padding: EdgeInsets.all(20), children: [
        Text("Analitik", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 16),
        Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
          Text("Pengeluaran per Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          SizedBox(height: 220, child: isPremium && catMap.isNotEmpty ? PieChart(PieChartData(sections: catMap.entries.map((en) { final color = catColor[en.key] ?? Colors.grey; return PieChartSectionData(value: en.value.toDouble(), title: "${en.key}\n${(en.value/out*100).toStringAsFixed(0)}%", color: color, radius: 70, titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)); }).toList(), sectionsSpace: 2, centerSpaceRadius: 40)) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_rounded, size: 48, color: Colors.grey.shade300), Text("Premium Only"), SizedBox(height: 8), ElevatedButton(onPressed: _buy, child: Text("Unlock Rp19k"))]))),
        ])),
      ]) : tab == 2 ? ListView(padding: EdgeInsets.all(20), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Goals", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), IconButton(onPressed: () { showModalBottomSheet(context: context, builder: (_) => GoalSheet(onAdd: _addGoal)); }, icon: Icon(Icons.add_circle_rounded, size: 32))]),
        SizedBox(height: 12),
        ...goals.map((g) {
          double prog = (g["saved"]/g["target"]).clamp(0.0, 1.0);
          return Container(margin: EdgeInsets.only(bottom: 12), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(g["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${(prog*100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold))]),
            SizedBox(height: 8),
            LinearProgressIndicator(value: prog, backgroundColor: Colors.grey.shade200, color: Color(0xFF0F172A), minHeight: 8),
            SizedBox(height: 8),
            Text("Rp ${g["saved"]} / Rp ${g["target"]}", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]));
        }).toList(),
      ]) : ListView(padding: EdgeInsets.all(20), children: [
        Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)), child: Row(children: [CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Text(name.isEmpty ? "U" : name[0].toUpperCase(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))), SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(email, style: TextStyle(color: Colors.white70)), Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isPremium ? Colors.amber : Colors.grey, borderRadius: BorderRadius.circular(20)), child: Text(isPremium ? "PREMIUM V3" : "FREE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))])])),
        SizedBox(height: 20),
        if (!isPremium) Container(padding: EdgeInsets.all(18), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Upgrade ke V3 Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 8), Text("Unlimited + Pie Chart + Goals", style: TextStyle(color: Colors.white70, fontSize: 12)), SizedBox(height: 14), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black), onPressed: _buy, child: Text("BELI Rp19.000 LIFETIME")))])),
        SizedBox(height: 20),
        ListTile(leading: Icon(Icons.backup_rounded), title: Text("Export Backup V3"), onTap: _export),
        ListTile(leading: Icon(Icons.logout_rounded, color: Colors.red), title: Text("Logout", style: TextStyle(color: Colors.red)), onTap: () async { final sp = await SharedPreferences.getInstance(); sp.clear(); setState(() => isLogin = false); }),
      ]),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Color(0xFF0F172A), icon: Icon(Icons.add_rounded, color: Colors.white), label: Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onPressed: () { showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddSheetV3(onAdd: _addTx, cats: catIcon.keys.toList())); }),
    );
  }
}
class AddSheetV3 extends StatefulWidget {
  final Function(String, int, String) onAdd;
  final List<String> cats;
  const AddSheetV3({required this.onAdd, required this.cats});
  @override State<AddSheetV3> createState() => _AddSheetV3State();
}
class _AddSheetV3State extends State<AddSheetV3> {
  String type = "out";
  final amountC = TextEditingController();
  String cat = "Makan";
  @override Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), padding: EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      SizedBox(height: 20),
      SegmentedButton<String>(segments: [ButtonSegment(value: "out", label: Text("Keluar"), icon: Icon(Icons.arrow_downward_rounded)), ButtonSegment(value: "in", label: Text("Masuk"), icon: Icon(Icons.arrow_upward_rounded))], selected: {type}, onSelectionChanged: (s) => setState(() => type = s.first)),
      SizedBox(height: 16),
      TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nominal", prefixText: "Rp ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
      SizedBox(height: 12),
      DropdownButtonFormField<String>(value: cat, items: widget.cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => cat = v!), decoration: InputDecoration(labelText: "Kategori", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
      SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 54, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: () { final a = int.tryParse(amountC.text) ?? 0; if (a <= 0) return; widget.onAdd(type, a, cat); Navigator.pop(context); }, child: Text("SIMPAN TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold)))),
      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
    ]));
  }
}
class GoalSheet extends StatefulWidget {
  final Function(String, int) onAdd;
  const GoalSheet({required this.onAdd});
  @override State<GoalSheet> createState() => _GoalSheetState();
}
class _GoalSheetState extends State<GoalSheet> {
  final titleC = TextEditingController();
  final targetC = TextEditingController();
  @override Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Target Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      SizedBox(height: 12),
      TextField(controller: titleC, decoration: InputDecoration(labelText: "Contoh: Liburan ke Bali", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      SizedBox(height: 12),
      TextField(controller: targetC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Target Rp", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: () { final t = int.tryParse(targetC.text) ?? 0; if (t <= 0 || titleC.text.isEmpty) return; widget.onAdd(titleC.text, t); Navigator.pop(context); }, child: Text("SIMPAN GOAL"))),
    ]));
  }
}

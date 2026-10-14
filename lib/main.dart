import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(DompetKuApp());

class DompetKuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A)),
      ),
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List tx = [];
  String userName = "";
  String userEmail = "";
  bool isPremium = false;
  int tab = 0;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      tx = jsonDecode(sp.getString("tx") ?? "[]");
      userName = sp.getString("name") ?? "";
      userEmail = sp.getString("email") ?? "";
      isPremium = sp.getBool("premium") ?? false;
      isLogin = sp.getBool("isLogin") ?? false;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("tx", jsonEncode(tx));
    sp.setString("name", userName);
    sp.setString("email", userEmail);
    sp.setBool("premium", isPremium);
    sp.setBool("isLogin", isLogin);
  }

  void _addTx(String type, int amount, String cat) {
    if (!isPremium && tx.length >= 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Free 30 limit! Premium bos!")),
      );
      return;
    }
    setState() {
      tx.add({
        "type": type,
        "amount": amount,
        "cat": cat,
        "date": DateTime.now().toIso8601String(),
      });
    });
    _save();
  }

  Future<void> _export() async {
    try {
      final dir = await getExternalStorageDirectory();
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await Directory("/storage/emulated/0/Download").exists()) {
        f = File("${dir!.path}/backup.json");
      }
      await f.writeAsString(jsonEncode({"user": userName, "premium": isPremium, "tx": tx}));
      ScaffoldMessenger.of(context).showSnackBar(SuackBar(content: Text("Backup: ${f.path}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SuackBar(content: Text("$e")));
    }
  }

  Future<void> _import() async {
    try {
      final dir = await getExternalStorageDirectory();
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await f.exists()) f = File("${dir!.path}/backup.json");
      final d = jsonDecode(await f.readAsString());
      setState(() {
        tx = List.from(d["tx"] ?? []);
        isPremium = d["premium"] ?? false;
      });
      _save();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _buy() {
    setState(() => isPremium = true);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      return Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF0F172A),))
            , SizedBox(height: 20),
            Text("DompetKu", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white))
            , Text("Kelola Unang", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 30),
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), padding: EdgeInsets.all(20), child: Column(children: [
              TextField(onChanged: (v) => userName = v, decoration: InputDecoration(labelText: "Nama", prefixIcon: Icon(Icons.person)i),
              SizedBox(height: 12),
              TextField(onChanged: (v) => userEmail = v, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
              SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                 in MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A)),
      ),
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List tx = [];
  String userName = "";
  String userEmail = "";
  bool isPremium = false;
  int tab = 0;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      tx = jsonDecode(sp.getString("tx") ?? "[]");
      userName = sp.getString("name") ?? "";
      userEmail = sp.getString("email") ?? "";
      isPremium = sp.getBool("premium") ?? false;
      isLogin = sp.getBool("isLogin") ?? false;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString("tx", jsonEncode(tx));
    sp.setString("name", userName);
    sp.setString("email", userEmail);
    sp.setBool("premium", isPremium);
    sp.setBool("isLogin", isLogin);
  }

  void _addTx(String type, int amount, String cat) {
    if (!isPremium && tx.length >= 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Free 30 limit! Premium bos!")),
      );
      return;
    }
    setState() {
      tx.add({
        "type": type,
        "amount": amount,
        "cat": cat,
        "date": DateTime.now().toIso8601String(),
      });
    });
    _save();
  }

  Future<void> _export() async {
    try {
      final dir = await getExternalStorageDirectory();
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await Directory("/storage/emulated/0/Download").exists()) {
        f = File("${dir!.path}/backup.json");
      }
      await f.writeAsString(jsonEncode({"user": userName, "premium": isPremium, "tx": tx}));
      ScaffoldMessenger.of(context).showSnackBar(SuackBar(content: Text("Backup: ${f.path}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SuackBar(content: Text("$e")));
    }
  }

  Future<void> _import() async {
    try {
      final dir = await getExternalStorageDirectory();
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await f.exists()) f = File("${dir!.path}/backup.json");
      final d = jsonDecode(await f.readAsString());
      setState(() {
        tx = List.from(d["tx"] ?? []);
        isPremium = d["premium"] ?? false;
      });
      _save();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _buy() {
    setState(() => isPremium = true);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      return Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF0F172A),))
            , SizedBox(height: 20),
            Text("DompetKu", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white))
            , Text("Kelola Unang", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 30),
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), padding: EdgeInsets.all(20), child: Column(children: [
              TextField(onChanged: (v) => userName = v, decoration: InputDecoration(labelText: "Nama", prefixIcon: Icon(Icons.person)i),
              SizedBox(height: 12),
              TextField(onChanged: (v) => userEmail = v, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
              SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (userName.isEmpty) return;
                    setState(() => isLogin = true);
                    _save();
                  },
                  child: Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2))),
                )),
              ]),) ])),),
        ),
      );
    }

    int inc = tx.where((e) => e["type"] == "in").fold(0, (s, e) => s+(e["amount"] as int));
    int out = tx.where((e) => e["type"] == "out").fold(0, (s, e) => s+(e["amount"] as int));
    int bal = inc - out;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: "Home"),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: "Analitik"),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: "Akun"),
        ],
      ),
      body: tab == 0 
          ? ListView(children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                color: Color(0xFF0F172A),
                child: Column(crossAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAllignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Halo, $userName ${isPremium ? "🚀" : ""}", style: TextStyle(color: Colors.white70)),
                      Text("Saldo Kamu", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                    CircleAvatar(backgroundColor: Colors.white, child: Text(userName.isEmpty ? "U" : userName[0].toUpperCase())),
                  ]),
                  SizedBox(height: 10),
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(bal),
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [
                      Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 6),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Masuk", style: TextStyle(color: Colors.white54, fontSize: 10)),
                        Text("Rp $inc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ]),
                    ]))),
                    SizedBox(width: 10),
                    Expanded(child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [
                      Icon(Icons.arrow_downward, color: Colors.redAccent, size: 20),
                      SizedBox(width: 6),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Keluar", style: TextStyle(color: Colors.white54, fontSize: 10)),
                        Text("Rp $out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ]),
                    ]),))),
                  ]),
                ]),
              ),
              if (!isPremium)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade[50]!,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade[200]!),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text("${tx.length}/30 Free. Upgrade Premium!", style: TextStyle(fontSize: 12))),
                    TextButton(onPressed: () => setState(() => tab = 2), child: Text("Upgrade")),
                  ]),
                ),
              Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${tx.length} item", style: TextStyle(color: Colors.grey)),
              ])),
              ...tx.reversed.map((e) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color : Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: e["type"] == "in" ? Colors.green.shade[50]!, Colors.red.shade[50]!, borderRadius: BorderRadius.circular(10)), child: Icon(e["type"] == "in" ? Icons.call_received_rounded : Icons.call_made_rounded, color: e["type"] == "in" ? Colors.green : Colors.red))
                   , title: Text(e["cat"], style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(e["date"]))),
                    trailing: Text("${e["type"] == "in" ? "+" : "-"} R$ ${e["amount"]}", style: TextStyle(fontWeight: FontWeight.bold, color: e["type"] == "in" ? Colors.green : Colors.black)),
                  ),
                );
              }).toList(),
              SizedBox(height: 80),
            ])
          : tab == 1
              ? Center(child: isPremium ? Text("Analitik Premium \n${tx.length} transaksi") : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_rounded, size: 70, color: Colors.grey.shade[300])
                  ,SizedBox(height: 12),
                  Text("Premium Feature", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Grafik hanya premium"),
                  SizedBox(height: 12),
                  ElevatedButton(onPressed: _buy, child: Text("Unlock Rp19k")),
                ]))
              : ListView(padding: EdgeInsets.all(20), children: [
                Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)), child: Row(children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Text(userName.isEmpty ? "U" : userName[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(userName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(userEmail, style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isPremium ? Colors.amber : Colors.grey, borderRadius: BorderRadius.circular(20)), child: Text(isPremium ? "💀 PREMIUM" : "FREE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  ]),
                ]),),
                SizedBox(height: 20),
                if (!isPremium)
                  Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Upgrade ke Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Unlimited, Backup, Analitik", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 12),
                    SizedBox(owidth: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), onPressed: _buy, child: Text("BELY Rp19.000 LIFETIME"))),
                  ])),
                SizedBox(height: 20),
                ListTile(leading: Icon(Icons.backup_rounded), title: Text("Export Backup"), subtitle: Text("Simpan ke Download"), onTap: _export),
                ListTile(leading: Icon(Icons.restore_rounded), title: Text("Import Backup"), onTap: _import),
                Divider(),
                ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout", style: TextStyle(color: Colors.red)), onTap: () async {
                  final sp = await SharedPreferences.getInstance();
                  sp.clear();
                  setState(() => isLogin = false);
                }),
              ]),
      floatingActionButton: tab == 0 
          ? FloatingActionButton.extended(
              backgroundColor: Color(0xFF0F172A),
              onPressed: () {
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddSheet(onAdd: _addTx));
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Tambah", style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

class AddSheet extends StatefulWidget {
  final Function(String, int, String) onAdd;
  const AddSheet({required this.onAdd });
  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  String type = "out";
  final amountC = TextEditingController();
  final catC = TextEditingController(text: "Makan");

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))), padding: EdgeInsets.all(20), child: Column(mainSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade[300], borderRadius: BorderRadius.circular(2))),
      SizedBox(height: 20),
      SegmentedButton<String>(
        segments: [
          ButtonSegment(value: "out", label: Text("Keluar"), icon: Icon(Icons.arrow_downward)),
          ButtonSegment(value: "in", label: Text("Masuk"), icon: Icon(Icons.arrow_upward)),
        ],
        selected: {type},
        onSelectionChanged: (s) { setState(() => type = s.first); },
      ),
      SizedBox(height: 16),
      TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nominal", prefixText: "Rp ", border: OutlineBorder(borderRadius: BorderRadius.circular(12)))),
      SizedBox(height: 12),
      TextField(controller: catC,decoration: InputDecoration(labelText: "Untuk apa?", border: OutlineBorder(borderRadius: BorderRadius.circular(12)))),
      SizedBox(height: 20),
      SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)) ,
          onPressed: () {
            final a = int.tryParse(amountC.text) ?? 0;
            if (a <= 0) return;
            widget.onAdd(type, a, catC.text);
            Navigator.pop(context);
          },
          child: Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold))
        )),
      ),
    ]));
  }
}

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A))),
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
      tx = jsonDecode(sp.getString("tx")?? "[]");
      userName = sp.getString("name")?? "";
      userEmail = sp.getString("email")?? "";
      isPremium = sp.getBool("premium")?? false;
      isLogin = sp.getBool("isLogin")?? false;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Free 30 limit! Upgrade bos")));
      return;
    }
    setState(() {
      tx.add({"type": type, "amount": amount, "cat": cat, "date": DateTime.now().toIso8601String()});
    });
    _save();
  }

  Future<void> _export() async {
    try {
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await Directory("/storage/emulated/0/Download").exists()) {
        final dir = await getExternalStorageDirectory();
        f = File("${dir!.path}/backup.json");
      }
      await f.writeAsString(jsonEncode({"user": userName, "premium": isPremium, "tx": tx}));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup: ${f.path}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> _import() async {
    try {
      final dir = await getExternalStorageDirectory();
      File f = File("/storage/emulated/0/Download/dompetku.json");
      if (!await f.exists()) f = File("${dir!.path}/backup.json");
      final d = jsonDecode(await f.readAsString());
      setState(() {
        tx = List.from(d["tx"]?? []);
        isPremium = d["premium"]?? false;
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF0F172A))),
              SizedBox(height: 20),
              Text("DompetKu", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
              Text("Kelola Uang", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  TextField(onChanged: (v) => userName = v, decoration: InputDecoration(labelText: "Nama", prefixIcon: Icon(Icons.person))),
                  SizedBox(height: 12),
                  TextField(onChanged: (v) => userEmail = v, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        if (userName.isEmpty) return;
                        setState(() => isLogin = true);
                        _save();
                      },
                      child: Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
    }

    int inc = tx.where((e) => e["type"] == "in").fold(0, (s, e) => s + (e["amount"] as int));
    int out = tx.where((e) => e["type"] == "out").fold(0, (s, e) => s + (e["amount"] as int));
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Halo, $userName", style: TextStyle(color: Colors.white70)),
                      Text("Saldo Kamu", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                    CircleAvatar(backgroundColor: Colors.white, child: Text(userName.isEmpty? "U" : userName[0].toUpperCase())),
                  ]),
                  SizedBox(height: 10),
                  Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(bal), style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                ]),
              ),
             ...tx.reversed.map((e) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(e["cat"]),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(e["date"]))),
                    trailing: Text("${e["type"] == "in"? "+" : "-"} Rp ${e["amount"]}"),
                  ),
                );
              }).toList(),
            ])
          : tab == 1
            ? Center(child: Text("Analitik"))
              : ListView(padding: EdgeInsets.all(20), children: [
                  ListTile(title: Text(userName)),
                  ListTile(leading: Icon(Icons.backup_rounded), title: Text("Export"), onTap: _export),
                  ListTile(leading: Icon(Icons.restore_rounded), title: Text("Import"), onTap: _import),
                  ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout"), onTap: () async { final sp = await SharedPreferences.getInstance(); sp.clear(); setState(() => isLogin = false); }),
                ]),
      floatingActionButton: FloatingActionButton(onPressed: () { showModalBottomSheet(context: context, builder: (_) => AddSheet(onAdd: _addTx)); }, child: Icon(Icons.add)),
    );
  }
}

class AddSheet extends StatefulWidget {
  final Function(String, int, String) onAdd;
  const AddSheet({required this.onAdd});
  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  String type = "out";
  final amountC = TextEditingController();
  final catC = TextEditingController(text: "Makan");
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nominal")),
        TextField(controller: catC, decoration: InputDecoration(labelText: "Untuk apa?")),
        ElevatedButton(onPressed: () { final a = int.tryParse(amountC.text)?? 0; if (a <= 0) return; widget.onAdd(type, a, catC.text); Navigator.pop(context); }, child: Text("SIMPAN")),
      ]),
    );
  }
}

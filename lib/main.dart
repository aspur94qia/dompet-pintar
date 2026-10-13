import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
void main() => runApp(const DompetPintarApp());
class DompetPintarApp extends StatelessWidget {
  const DompetPintarApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0D5C36))), home: const HomePage());
  }
}
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transaksi = []; int total = 0;
  @override void initState() { super.initState(); loadData(); }
  loadData() async {
    final p = await SharedPreferences.getInstance(); final s = p.getString('data');
    if (s!= null) { setState(() { transaksi = List<Map<String, dynamic>>.from(jsonDecode(s)); total = transaksi.fold(0, (sum, e) => sum + (e['nominal'] as int)); }); }
  }
  saveData() async { final p = await SharedPreferences.getInstance(); p.setString('data', jsonEncode(transaksi)); }
  tambah(bool isMasuk, String kat, int nom) { setState(() { transaksi.insert(0, {'kat': kat, 'nominal': isMasuk? nom : -nom, 'tgl': DateFormat('dd MMM').format(DateTime.now()), 'masuk': isMasuk}); total += isMasuk? nom : -nom; }); saveData(); }
  @override Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: const Text('Dompet Pintar Pro'), centerTitle: true, backgroundColor: Color(0xFF0D5C36), foregroundColor: Colors.white),
      body: Column(children: [
        Container(width: double.infinity, padding: EdgeInsets.all(24), color: Color(0xFF0D5C36), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Saldo', style: TextStyle(color: Colors.white70)), SizedBox(height: 8), Text(fmt.format(total), style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))])),
        Expanded(child: transaksi.isEmpty? Center(child: Text('Belum ada transaksi')) : ListView.builder(itemCount: transaksi.length, itemBuilder: (c, i) { final t = transaksi[i]; return ListTile(leading: CircleAvatar(backgroundColor: t['masuk']? Colors.green : Colors.red, child: Icon(t['masuk']? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white)), title: Text(t['kat']), subtitle: Text(t['tgl']), trailing: Text(fmt.format(t['nominal']), style: TextStyle(color: t['masuk']? Colors.green : Colors.red, fontWeight: FontWeight.bold))); }))
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => showSheet(), label: Text('Tambah'), icon: Icon(Icons.add)),
    );
  }
  showSheet() {
    final cKat = TextEditingController(); final cNom = TextEditingController(); bool masuk = true;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setM) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16), child: Column(mainAxisSize: MainAxisSize.min, children: [
      SegmentedButton<bool>(segments: [ButtonSegment(value: true, label: Text('Pemasukan')), ButtonSegment(value: false, label: Text('Pengeluaran'))], selected: {masuk}, onSelectionChanged: (s) => setM(() => masuk = s.first)), SizedBox(height: 12), TextField(controller: cKat, decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder())), SizedBox(height: 12), TextField(controller: cNom, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Nominal', border: OutlineInputBorder())), SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (cKat.text.isNotEmpty && cNom.text.isNotEmpty) { tambah(masuk, cKat.text, int.parse(cNom.text)); Navigator.pop(ctx); } }, child: Text('Simpan'))), SizedBox(height: 20)
    ]))));
  }
}

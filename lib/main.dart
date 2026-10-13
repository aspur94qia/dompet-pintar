
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const DompetKuApp());

class Trx {
  String title; double amount; bool isExpense; String cat; DateTime date;
  Trx(this.title, this.amount, this.isExpense, this.cat, this.date);
  Map<String,dynamic> toMap() => {'t':title,'a':amount,'e':isExpense,'c':cat,'d':date.toIso8601String()};
  static Trx fromMap(Map<String,dynamic> m) => Trx(m['t'], m['a'], m['e'], m['c'], DateTime.parse(m['d']));
}

class DompetKuApp extends StatelessWidget {
  const DompetKuApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00C853))),
      home: const MainScreen());
  }
}

class MainScreen extends StatefulWidget { const MainScreen({super.key}); @override State<MainScreen> createState()=>_MainScreenState(); }

class _MainScreenState extends State<MainScreen> {
  List<Trx> data = [];
  int tab = 0;
  bool dark = false;
  String search = '';
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override void initState(){ super.initState(); load(); }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString('trx');
    if(s!=null){
      final List list = jsonDecode(s);
      setState(()=> data = list.map((e)=> Trx.fromMap(e)).toList());
    } else {
      setState(()=> data = [
        Trx('Gaji Bulanan', 3500000, false, 'Gaji', DateTime.now().subtract(Duration(days:1))),
        Trx('Kopi Kenangan', 25000, true, 'Makan', DateTime.now()),
        Trx('Bensin', 30000, true, 'Transport', DateTime.now()),
      ]);
    }
  }
  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString('trx', jsonEncode(data.map((e)=>e.toMap()).toList()));
  }

  double get total => data.fold(0, (a,b)=> b.isExpense ? a-b.amount : a+b.amount);
  double get masuk => data.where((e)=>!e.isExpense).fold(0,(a,b)=>a+b.amount);
  double get keluar => data.where((e)=>e.isExpense).fold(0,(a,b)=>a+b.amount);

  Map<String,double> get catMap {
    var m = <String,double>{};
    for(var e in data.where((e)=>e.isExpense)){ m[e.cat]=(m[e.cat]??0)+e.amount; }
    return m;
  }

  List<Trx> get filtered => data.where((e)=> e.title.toLowerCase().contains(search.toLowerCase())).toList();

  String emoji(String c){ switch(c){ case 'Makan': return '🍔'; case 'Transport': return '🛵'; case 'Belanja': return '🛍️'; case 'Gaji': return '💼'; default: return '💰'; } }

  void addSheet(){
    String title=''; String amt=''; bool exp=true; String cat='Makan';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx)=> StatefulBuilder(builder: (ctx,setM){
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom+20, left:20,right:20,top:20),
          child: Column(mainAxisSize: MainAxisSize.min, children:[
            Text('Transaksi Baru ✨',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
            SizedBox(height:12),
            TextField(decoration: InputDecoration(labelText:'Buat apa?', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), onChanged:(v)=>title=v),
            SizedBox(height:8),
            TextField(decoration: InputDecoration(labelText:'Berapa Rp?', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), keyboardType: TextInputType.number, onChanged:(v)=>amt=v),
            SizedBox(height:8),
            DropdownButtonFormField(value:cat, items:['Makan','Transport','Belanja','Gaji','Lainnya'].map((e)=>DropdownMenuItem(value:e, child:Text('${emoji(e)} $e'))).toList(), onChanged:(v)=>setM(()=>cat=v!)),
            SizedBox(height:8),
            Row(children:[ Expanded(child: ChoiceChip(label:Text('💸 Keluar'), selected:exp, onSelected:(v)=>setM(()=>exp=true))), SizedBox(width:8), Expanded(child: ChoiceChip(label:Text('💰 Masuk'), selected:!exp, onSelected:(v)=>setM(()=>exp=false))), ]),
            SizedBox(height:16),
            SizedBox(width:double.infinity, height:50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853), foregroundColor: Colors.white), onPressed:(){ if(title.isNotEmpty && amt.isNotEmpty){ setState(()=> data.insert(0, Trx(title, double.tryParse(amt)??0, exp, cat, DateTime.now()))); save(); Navigator.pop(ctx);} }, child: Text('Simpan'))),
          ]));
      }));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: dark? Color(0xFF121212): Color(0xFFF8FFFB),
      body: tab==0 ? buildHome() : buildInsight(),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected:(i)=>setState(()=>tab=i), destinations: [ NavigationDestination(icon: Icon(Icons.home_rounded), label:'Home'), NavigationDestination(icon: Icon(Icons.pie_chart), label:'Analitik') ]),
      floatingActionButton: FloatingActionButton.extended(onPressed:addSheet, label: Text('Tambah'), icon: Icon(Icons.add)),
    );
  }

  Widget buildHome(){
    return CustomScrollView(slivers:[
      SliverAppBar(expandedHeight: 300, pinned:true, backgroundColor: Color(0xFF00C853),
        flexibleSpace: FlexibleSpaceBar(background: Container(decoration: BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF00C853),Color(0xFF009624)])), padding: EdgeInsets.fromLTRB(20,50,20,20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text('DompetKu ✨', style:TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold)), IconButton(onPressed:()=> setState(()=> dark=!dark), icon: Icon(dark? Icons.light_mode: Icons.dark_mode, color: Colors.white)) ]),
          SizedBox(height:10),
          TextField(onChanged:(v)=> setState(()=> search=v), decoration: InputDecoration(hintText:'Cari transaksi...', prefixIcon: Icon(Icons.search), filled:true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),),
          SizedBox(height:14),
          Text('Total Saldo', style:TextStyle(color:Colors.white70)), Text(fmt.format(total), style:TextStyle(color:Colors.white, fontSize:32, fontWeight:FontWeight.w900)),
          SizedBox(height:12),
          Row(children:[
            Expanded(child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(12)), child: Text('Masuk: ${fmt.format(masuk)}', style:TextStyle(color: Color(0xFF00C853), fontWeight:FontWeight.bold)))),
            SizedBox(width:8),
            Expanded(child: Container(padding:EdgeInsets.all(12), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(12)), child: Text('Keluar: ${fmt.format(keluar)}', style:TextStyle(color: Colors.red, fontWeight:FontWeight.bold)))),
          ])
        ])))),
      SliverList.builder(itemCount: filtered.length, itemBuilder:(c,i){
        final t=filtered[i];
        return Dismissible(key: ValueKey(t.date.toString()+i.toString()), background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right:20), child: Icon(Icons.delete, color: Colors.white)), onDismissed: (_){ setState(()=> data.remove(t)); save(); }, child: Card(margin: EdgeInsets.symmetric(horizontal:16, vertical:6), child: ListTile(leading: Text(emoji(t.cat), style: TextStyle(fontSize:24)), title: Text(t.title, style: TextStyle(fontWeight:FontWeight.bold)), subtitle: Text('${t.cat} • ${DateFormat('dd MMM HH:mm').format(t.date)}'), trailing: Text('${t.isExpense?'-':'+'}${fmt.format(t.amount)}', style: TextStyle(color: t.isExpense?Colors.red:Colors.green, fontWeight:FontWeight.bold)))));
      }),
      SliverToBoxAdapter(child: SizedBox(height:80))
    ]);
  }

  Widget buildInsight(){
    return ListView(padding: EdgeInsets.fromLTRB(20,60,20,20), children:[
      Text('Analitik Keuangan', style:TextStyle(fontSize:24, fontWeight:FontWeight.bold)),
      SizedBox(height:12),
      if(catMap.isNotEmpty)
        Container(height:200, padding:EdgeInsets.all(16), decoration:BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: CustomPaint(painter: PiePainter(catMap), child: Center(child: Text('Total\n${fmt.format(keluar)}', textAlign: TextAlign.center, style: TextStyle(fontWeight:FontWeight.bold))))),
      SizedBox(height:16),
      Container(padding:EdgeInsets.all(16), decoration:BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: catMap.entries.map((e){ double pct = keluar==0?0:e.value/keluar; return Padding(padding:EdgeInsets.only(bottom:8), child: Row(children:[ Text('${emoji(e.key)} ${e.key}'), Spacer(), Text('${(pct*100).toStringAsFixed(0)}% • ${fmt.format(e.value)}'), SizedBox(width:8), SizedBox(width:60, child: LinearProgressIndicator(value:pct)) ])); }).toList())),
      SizedBox(height:16),
      Container(padding:EdgeInsets.all(16), decoration:BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF00C853), Color(0xFF009624)]), borderRadius: BorderRadius.circular(16)), child: Text(keluar>masuk*0.8 ? '⚠️ Boros bos! Kurangi jajan minggu ini' : '✅ Keren! Kamu hemat bulan ini', style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold))),
    ]);
  }
}

class PiePainter extends CustomPainter {
  final Map<String,double> data;
  PiePainter(this.data);
  @override void paint(Canvas canvas, Size size){
    double total = data.values.fold(0,(a,b)=>a+b);
    double start = -90*3.14159/180;
    List<Color> colors = [Color(0xFF00C853), Color(0xFFFF5722), Color(0xFF2196F3), Color(0xFFFFC107), Color(0xFF9C27B0)];
    int i=0;
    for(var e in data.entries){
      double sweep = (e.value/total)*3.14159*2;
      final paint = Paint()..color = colors[i%colors.length]..style=PaintingStyle.fill;
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width*0.8, height: size.height*0.8), start, sweep, true, paint);
      start+=sweep; i++;
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=> true;
}

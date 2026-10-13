
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const DompetKuApp());

class Trx {
  String title; double amount; bool isExpense; String cat; DateTime date;
  Trx(this.title, this.amount, this.isExpense, this.cat, this.date);
}

class DompetKuApp extends StatelessWidget {
  const DompetKuApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00C853)), fontFamily: 'Roboto'),
      home: const MainScreen());
  }
}

class MainScreen extends StatefulWidget { const MainScreen({super.key}); @override State<MainScreen> createState()=>_MainScreenState(); }

class _MainScreenState extends State<MainScreen> {
  List<Trx> data = [
    Trx('Gaji Bulanan', 3500000, false, 'Gaji', DateTime.now().subtract(Duration(days: 1))),
    Trx('Kopi Kenangan', 25000, true, 'Makan', DateTime.now()),
    Trx('Bensin Motor', 30000, true, 'Transport', DateTime.now()),
    Trx('Shopee Haul', 120000, true, 'Belanja', DateTime.now()),
    Trx('Freelance Logo', 500000, false, 'Gaji', DateTime.now()),
  ];
  int tab = 0;
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double get total => data.fold(0, (a,b)=> b.isExpense ? a-b.amount : a+b.amount);
  double get masuk => data.where((e)=>!e.isExpense).fold(0,(a,b)=>a+b.amount);
  double get keluar => data.where((e)=>e.isExpense).fold(0,(a,b)=>a+b.amount);

  Map<String,double> get catMap {
    var m = <String,double>{};
    for(var e in data.where((e)=>e.isExpense)){ m[e.cat]=(m[e.cat]??0)+e.amount; }
    return m;
  }

  String emoji(String c){ switch(c){ case 'Makan': return '🍔'; case 'Transport': return '🛵'; case 'Belanja': return '🛍️'; case 'Gaji': return '💼'; default: return '💰'; } }

  void addSheet(){
    String title=''; String amt=''; bool exp=true; String cat='Makan';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx)=> StatefulBuilder(builder: (ctx,setM){
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom+20, left:20,right:20,top:20),
          child: Column(mainAxisSize: MainAxisSize.min, children:[
            Container(width:40,height:4,decoration:BoxDecoration(color:Colors.grey[300],borderRadius:BorderRadius.circular(4))),
            SizedBox(height:16), Text('Transaksi Baru',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
            SizedBox(height:16),
            TextField(decoration: InputDecoration(labelText:'Buat apa? contoh: Seblak', filled:true, fillColor: Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), onChanged:(v)=>title=v),
            SizedBox(height:12),
            TextField(decoration: InputDecoration(labelText:'Berapa? (Rp)', filled:true, fillColor: Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), keyboardType: TextInputType.number, onChanged:(v)=>amt=v),
            SizedBox(height:12),
            DropdownButtonFormField(value:cat, decoration: InputDecoration(filled:true,fillColor:Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), items:['Makan','Transport','Belanja','Gaji','Lainnya'].map((e)=>DropdownMenuItem(value:e, child:Text('${emoji(e)} $e'))).toList(), onChanged:(v)=>setM(()=>cat=v!)),
            SizedBox(height:12),
            Row(children:[ Expanded(child: ChoiceChip(label:Center(child:Text('💸 Keluar')), selected:exp, selectedColor: Color(0xFFFFCDD2), onSelected:(v)=>setM(()=>exp=true))), SizedBox(width:8), Expanded(child: ChoiceChip(label:Center(child:Text('💰 Masuk')), selected:!exp, selectedColor: Color(0xFFC8E6C9), onSelected:(v)=>setM(()=>exp=false))), ]),
            SizedBox(height:20),
            SizedBox(width:double.infinity, height:50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed:(){ if(title.isNotEmpty && amt.isNotEmpty){ setState(()=> data.insert(0, Trx(title, double.tryParse(amt)??0, exp, cat, DateTime.now()))); Navigator.pop(ctx);} }, child: Text('Simpan - Bikin Kaya!', style:TextStyle(fontWeight:FontWeight.bold)))),
          ]));
      }));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFF8FFFB),
      body: tab==0 ? buildHome() : buildInsight(),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected:(i)=>setState(()=>tab=i), destinations: [ NavigationDestination(icon: Icon(Icons.dashboard_rounded), label:'Beranda'), NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label:'Insight') ]),
      floatingActionButton: FloatingActionButton.extended(onPressed:addSheet, backgroundColor: Color(0xFF00C853), foregroundColor: Colors.white, icon: Icon(Icons.add_rounded), label: Text('Tambah')),
    );
  }

  Widget buildHome(){
    return CustomScrollView(slivers:[
      SliverAppBar(expandedHeight: 280, pinned:true, backgroundColor: Color(0xFF00C853),
        flexibleSpace: FlexibleSpaceBar(background: Container(decoration: BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF00C853),Color(0xFF009624)], begin: Alignment.topLeft, end: Alignment.bottomRight)), padding: EdgeInsets.fromLTRB(20,60,20,20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text('DompetKu ✨', style:TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold)), Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6), decoration:BoxDecoration(color:Colors.white24, borderRadius:BorderRadius.circular(20)), child: Text('🔥 ${data.length} transaksi', style:TextStyle(color:Colors.white))) ]),
          SizedBox(height:20),
          Text('Total Saldo Kamu', style:TextStyle(color:Colors.white70)), SizedBox(height:4),
          Text(fmt.format(total), style:TextStyle(color:Colors.white, fontSize:36, fontWeight:FontWeight.w900)),
          SizedBox(height:20),
          Row(children:[
            Expanded(child: Container(padding:EdgeInsets.all(14), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16)), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ Text('Pemasukan', style:TextStyle(color:Colors.grey)), SizedBox(height:4), Text(fmt.format(masuk), style:TextStyle(fontWeight:FontWeight.bold, color:Color(0xFF00C853))) ]))),
            SizedBox(width:12),
            Expanded(child: Container(padding:EdgeInsets.all(14), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16)), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ Text('Pengeluaran', style:TextStyle(color:Colors.grey)), SizedBox(height:4), Text(fmt.format(keluar), style:TextStyle(fontWeight:FontWeight.bold, color:Colors.red)) ]))),
          ])
        ])))),
      SliverToBoxAdapter(child: Padding(padding:EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text('Transaksi Terbaru', style:TextStyle(fontWeight:FontWeight.bold, fontSize:16)), Text('${DateFormat('dd MMM yyyy').format(DateTime.now())}', style:TextStyle(color:Colors.grey)) ]))),
      SliverList.builder(itemCount: data.length, itemBuilder:(c,i){
        final t=data[i];
        return Container(margin: EdgeInsets.symmetric(horizontal:16, vertical:6), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16), boxShadow:[BoxShadow(color:Colors.black12, blurRadius:6, offset:Offset(0,2))]),
          child: ListTile(leading: Container(width:48,height:48, decoration:BoxDecoration(color: t.isExpense ? Color(0xFFFFEBEE) : Color(0xFFE8F5E9), borderRadius:BorderRadius.circular(12)), child:Center(child:Text(emoji(t.cat), style:TextStyle(fontSize:22)))), title: Text(t.title, style:TextStyle(fontWeight:FontWeight.bold)), subtitle: Text('${t.cat} • ${DateFormat('HH:mm').format(t.date)}'), trailing: Column(mainAxisAlignment:MainAxisAlignment.center, crossAxisAlignment:CrossAxisAlignment.end, children:[ Text('${t.isExpense?'-':'+'}${fmt.format(t.amount)}', style:TextStyle(color: t.isExpense?Colors.red:Color(0xFF00C853), fontWeight:FontWeight.bold)), Text(t.isExpense?'Keluar':'Masuk', style:TextStyle(fontSize:10, color:Colors.grey)) ]), onLongPress: ()=> setState(()=> data.removeAt(i)),));
      }),
      SliverToBoxAdapter(child: SizedBox(height:100))
    ]);
  }

  Widget buildInsight(){
    return ListView(padding: EdgeInsets.fromLTRB(20,60,20,20), children:[
      Text('Insight Keuangan 🔍', style:TextStyle(fontSize:24, fontWeight:FontWeight.bold)),
      SizedBox(height:8), Text('Pantau kemana uangmu pergi', style:TextStyle(color:Colors.grey)),
      SizedBox(height:20),
      Container(padding:EdgeInsets.all(20), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(20), boxShadow:[BoxShadow(color:Colors.black12, blurRadius:10)]), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text('Pengeluaran per Kategori', style:TextStyle(fontWeight:FontWeight.bold)),
        SizedBox(height:16),
        ...catMap.entries.map((e){ double pct = keluar==0?0:e.value/keluar; return Padding(padding:EdgeInsets.only(bottom:12), child: Column(children:[ Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[ Text('${emoji(e.key)} ${e.key}'), Text(fmt.format(e.value)) ]), SizedBox(height:6), LinearProgressIndicator(value:pct, backgroundColor:Color(0xFFEEEEEE), color:Color(0xFF00C853), borderRadius:BorderRadius.circular(10)), ])); }),
        if(catMap.isEmpty) Text('Belum ada pengeluaran', style:TextStyle(color:Colors.grey))
      ])),
      SizedBox(height:16),
      Container(padding:EdgeInsets.all(20), decoration:BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF00C853),Color(0xFF009624)]), borderRadius:BorderRadius.circular(20)), child: Row(children:[ Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[ Text('Tips Hemat Hari Ini 💡', style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold)), SizedBox(height:8), Text(keluar> masuk*0.8 ? 'Waduh! Pengeluaranmu hampir melebihi pemasukan. Kurangi jajan kopi minggu ini!' : 'Keren! Kamu hemat banget bulan ini. Pertahankan!', style:TextStyle(color:Colors.white70)) ])), Text('🧠', style:TextStyle(fontSize:40)) ])),
      SizedBox(height:100)
    ]);
  }
}

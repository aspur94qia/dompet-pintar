
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
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A), brightness: Brightness.light)),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A), brightness: Brightness.dark)),
      home: MainV3(),
    );
  }
}

class MainV3 extends StatefulWidget { @override
  State<MainV3> createState() => _MainV3State(); }

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
    "Tagihan": Color(0xFF8B_CF6),
    "Hiburan": Color(0xFFEC4899),
    "Kesehatan": Color(0xFFEF4444),
  };

  @override
  void initState() { super.initState(); _load(); }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Free 50 limit! Upgrade Premium bos")));
      return;
    }
    setState(() { tx.add({"type": type, "amount": amount, "cat": cat, "date": DateTime.now().toIs8601String()}); });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Backup V1: ${f.path}")));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
  }
  void _buy() { setState(() => isPremium = true); _save(); }

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      return Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 30)]), child: Icon(Icons.account_balance_wallet_rounded, size: 64, color: Color(0xFF0F172A))),
          SizedBox(height: 24),
          Text("DompetKu V3", style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
          Text("Premium Leather Wallet", style: TextStyle(color: Colors.amber.shade200, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 32),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), padding: EdgeInsets.all(22), child: Column(children: [
            TextField(onChanged: (v) => name = v, decoration: InputDecoration(labelText: "Nama Lengkap", prefixI½¸è%½¸¡%½¹Ì¹Á•ÉÍ½¹}É½Õ¹‘•¤°‰½É‘•Èè=ÕÑ±¥¹•%¹ÁÕÑ	½É‘•È¡‰½É‘•ÉI…‘¥ÕÌè	½É‘•ÉI…‘¥ÕÌ¹¥ÉÕ±…È ÄÈ¤¤¤¤°(€€€€€€€€€€€M¥é•‘	½à¡¡•¥¡Ğè€ÄÈ¤°(€€€€€€€€€€€Q•áÑ¥•±¡½¹¡…¹•è€¡Ø¤€ôø•µ…¥°€ôØ°‘•½É…Ñ¥½¸è%¹ÁÕÑ•½É…Ñ¥½¸¡±…‰•±Q•áĞè€‰µ…¥°ˆ°ÁÉ•™¥á&6öã¢–6öâ„–6öç2æVÖ–Å÷&÷VæFVB’Â&÷&FW#¢÷WFÆ–æT–çWD&÷&FW"†&÷&FW%&F—W3¢&÷&FW%&F—W2æ6—&7VÆ"ƒ"’’’’À¢6—¦VD&÷‚††V–v‡C¢#’À¢6—¦VD&÷‚‡v–GFƒ¢F÷V&ÆRæ–æf–æ—G’Â†V–v‡C¢SbÂ6†–ÆC¢VÆWfFVD'WGFöâ‡7G–ÆS¢VÆWfFVD'WGFöâç7G–ÆTg&öÒ†&6¶w&÷VæD6öÆ÷#¢6öÆ÷"ƒ„dccs$’Â6†S¢&÷VæFVE&V7FævÆT&÷&FW"†&÷&FW%&F—W3¢&÷&FW%&F—W2æ6—&7VÆ"ƒB’’’Âöå&W76VC¢‚’²–b†æÖRæ—4V×G’’&WGW&ã²6WE7FFR‚‚’Óâ—4Æöv–âÒG'VR“²÷6fR‚“²ÒÂ6†–ÆC¢FW‡B‚$Ô5T²´RDôÕUB"Â7G–ÆS¢FW‡E7G–ÆR†föçEvV–v‡C¢föçEvV–v‡Bæ&öÆBÂÆWGFW%76–æs¢ãR’’’’’À¢Ò’À¢Ò’’’À¢“°¢Ğ ¢–çB–æ2ÒG‚çv†W&R‚†R’ÓâU²'G—R%ÒÓÒ&–â"’æföÆBƒÂ‡2ÂR’Óâ2²†U²&Ö÷VçB%Ò2–çB’“°¢–çB÷WBÒG‚çv†W&R‚†R’ÓâU²'G—R%ÒÓÒ&÷WB"’æföÆBƒÂ‡2ÂR’Óâ2²†U²&Ö÷VçB%Ò2–çB’“°¢–çB&ÂÒ–æ2Ò÷WC° ¢ÖÅ7G&–ærÂ–çCâ6DÖÒ·Ó°¢f÷"‡f"R–âG‚çv†W&R‚†R’ÓâU²'G—R%ÒÓÒ&÷WB"’’°¢6DÖ¶U²&6B%ÕÒÒ†6DÖ¶U²&6B%ÕÒóò’²†U²&Ö÷VçB%Ò2–çB“°¢Ğ ¢&WGW&â66fföÆB€¢&6¶w&÷VæD6öÆ÷#¢6öÆ÷"ƒ„ddc„dd2’À¢&÷GFöÔæf–vF–öä&#¢æf–vF–öä&"‡6VÆV7FVD–æFWƒ¢F"ÂöäFW7F–æF–öå6VÆV7FVC¢†’’Óâ6WE7FFR‚‚’ÓâF"Ò’’ÂFW7F–æF–öç3¢°¢æf–vF–öäFW7F–æF–öâ†–6öã¢–6öâ„–6öç2æ†öÖU÷&÷VæFVB’ÂÆ&VÃ¢$†öÖR"’À¢æf–vF–öäFW7F–æF–öâ†–6öã¢–6öâ„–6öç2ç–Uö6†'E÷&÷VæFVB’ÂÆ&VÃ¢$æÆ—F–²"’À¢æf–vF–öäFW7F–æF–öâ†–6öã¢–6öâ„–6öç2ç6f–æw5÷&÷VæFVB’ÂÆ&VÃ¢$vöÇ2"’À¢æf–vF–öäFW7F–æF–öâ†–6öã¢–6öâ„–6öç2çW'6öå÷&÷VæFVB’ÂÆ&VÃ¢$·Vâ"’À¢Ò’À¢&öG“¢F"ÓÒòÆ—7Ef–Wr†6†–ÆG&Vã¢°¢6öçF–æW"‡FF–æs¢VFvT–ç6WG2æg&öÔÅE$"ƒ#ÂSbÂ#Â#B’ÂFV6÷&F–öã¢&÷„FV6÷&F–öâ†6öÆ÷#¢6öÆ÷"ƒ„dccs$’Â&÷&FW%&F—W3¢&÷&FW%&F—W2çfW'F–6Â†&÷GFöÓ¢&F—W2æ6—&7VÆ"ƒ#‚’’’Â6†–ÆC¢6öÇVÖâ†7&÷74†—4Æ–væÖVçC¢7&÷74†—4Æ–væÖVçBç7F'BÂ6†–ÆG&Vã¢°¢&÷r†Ö–ä†—4Æ–væÖVçC¢Ö–ä†—4Æ–væÖVçBç76T&WGvVVâÂ6†–ÆG&Vã¢°¢6öÇVÖâ†7&÷74†—4Æ–væÖVçC¢7&÷74†—4Æ–væÖVçBç7F'BÂ6†–ÆG&Vã¢µFW‡B‚$†ÆòÂFæÖRG¶—5&VÖ—VÒò/	ùª‚"¢"'Ò"Â7G–ÆS¢FW‡E7G–ÆR†6öÆ÷#¢6öÆ÷'2çv†—FSs’’ÂFW‡B‚%F÷FÂ&Ææ6R"Â7G–ÆS¢FW‡E7G–ÆR†6öÆ÷#¢6öÆ÷'2çv†—FS3‚ÂföçE6—¦S¢ÂÆWGFW%76–æs¢’•Ò’À¢6—&6ÆTfF"†&6¶w&÷VæD6öÆ÷#¢6öÆ÷'2çv†—FRÂ6†–ÆC¢FW‡B†æÖRæ—4V×G’ò%R"¢æÖU³ÒçFõWW$66R‚’Â7G–ÆS¢FW‡E7G–ÆR†föçEvV–v‡C¢föçEvV–v‡Bæ&öÆB’’’À¢Ò’À¢6—¦VD&÷‚††V–v‡C¢"’À¢FW‡B„çVÖ&W$f÷&ÖBæ7W'&Væ7’†Æö6ÆS¢v–Eô”BrÂ7–Ö&öÃ¢u'rÂFV6–ÖÄF–v—G3¢’æf÷&ÖB†&Â’Â7G–ÆS¢FW‡E7G–ÆR†6öÆ÷#¢6öÆ÷'2çv†—FRÂföçE6—¦S¢3bÂföçEvV–v‡C¢föçEvV–v‡Bçs“ÂÆWGFW%76–æs¢Ó’’À¢6—¦VD&÷‚††V–v‡C¢b’À¢&÷r†6†–ÆG&Vã¢°¢W‡æFVB†6†–ÆC¢ö&Ææ6T6&B„–6öç2æ'&÷u÷Wv&E÷&÷VæFVBÂ$Ö7V²"Â–æ2Â6öÆ÷'2æw&VVä66VçB’’À¢6—¦VD&÷‚‡v–GFƒ¢"’À¢W‡æFVB†6†–ÆC¢ö&Ææ6T6&B„–6öç2æ'&÷uöF÷vçv&E÷&÷VæFVBÂ$¶VÇV""Â÷WBÂ6öÆ÷'2ç&VD66VçB’’À¢Ò’À¢–b‚—5&VÖ—VÒ’6öçF–æW"†Ö&v–ã¢VFvT–ç6WG2æöæÇ’‡F÷¢b’ÂFF–æs¢VFvT–ç6WG2æÆÂƒ"’ÂFV6÷&F–öã¢&÷„FV6÷&F–öâ†6öÆ÷#¢6öÆ÷'2çv†—FRçv—F„÷6—G’ƒã‚’Â&÷&FW%&F—W3¢&÷&FW%&F—W2æ6—&7VÆ"ƒ"’Â&÷&FW#¢&÷&FW"æÆÂ†6öÆ÷#¢6öÆ÷'2æÖ&W"çv—F„÷6—G’ƒã2’’’Â6†–ÆC¢&÷r†6†–ÆG&Vã¢´–6öâ„–6öç2ç7F'5÷&÷VæFVBÂ6öÆ÷#¢6öÆ÷'2æÖ&W"’Â6—¦VD&÷‚‡v–GFƒ¢‚’ÂW‡æFVB†6†–ÆC¢FW‡B‚"G·G‚æÆVæwF‡ÒóSg&VRâWw&FR'VBVæÆ–Ö—FVBb6†'B"Â7G–ÆS¢FW‡E7G–ÆR†6öÆ÷#¢6öÆ÷'2æÖ&W"ç6†FSÂföçE6—¦S¢’’’ÂFW‡D'WGFöâ†öå&W76VC¢‚’Óâ6WE7FFR‚‚’ÓâF"Ò2’Â6†–ÆC¢FW‡B‚%Uu$DB"Â7G–ÆS¢FW‡E7G–ÆR†6öÆ÷#¢6öÆ÷'2æÖ&W"’’•Ò’’À¢Ò’’À¢FF–ær‡FF–æs¢VFvT–ç6WG2æÆÂƒb’Â6†–ÆC¢&÷r†Ö–ä†—4Æ–væÖVçC¢Ö–ä†—4Æ–væÖVçBç76T&WGvVVâÂ6†–ÆG&Vã¢µFW‡B‚%G&ç6·6’FW&¶†—""Â7G–ÆS¢FW‡E7G–ÆR†föçEvV–v‡C¢föçEvV–v‡Bæ&öÆBÂföçE6—¦S¢b’’ÂFW‡D'WGFöâ†öå&W76VC¢‚’Óâ6WE7FFR‚‚’ÓâF"Ò’Â6†–ÆC¢FW‡B‚$Æ–†B6V×V"’•Ò’’À¢ââçG‚ç&WfW'6VBçF¶Rƒ‚’æÖ‚†R’°¢&WGW&â6öçF–æW"†Ö&v–ã¢VFvT–ç6WG2ç7–ÖÖWG&–2††÷&—¦öçFÃ¢bÂfW'F–6Ã¢B’ÂFV6÷&F–öã¢&÷„FV6÷&F–öâ†6öÆ÷#¢6öÆ÷'2çv†—FRÂ&÷&FW%&F—W3¢&÷&FW%&F—W2æ6—&7VÆ"ƒB’Â&÷…6†F÷s¢´&÷…6†F÷r†6öÆ÷#¢6öÆ÷'2æ&Æ6²çv—F„÷6—G’ƒã2’Â&ÇW%&F—W3¢‚•Ò’Â6†–ÆC¢Æ—7EF–ÆR†ÆVF–æs¢6öçF–æW"‡FF–æs¢VFvT–ç6WG2æÆÂƒ’ÂFV6÷&F–öã¢&÷„FV6÷&F–öâ†6öÆ÷#¢†6D6öÆ÷%¶U²&6B%Òó
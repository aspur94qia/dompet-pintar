import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(FlashMasterApp());

class FlashMasterApp extends StatelessWidget {
  @override Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Color(0xFF020617),
      colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0F172A), brightness: Brightness.dark),
    ),
    home: FlashHome(),
  );
}

class FlashHome extends StatefulWidget { @override State<FlashHome> createState() => _FlashHomeState(); }

class _FlashHomeState extends State<FlashHome> {
  static const channel = MethodChannel('otg.usb/flash');
  String log = "FLASH MASTER PRO OTG V1\n\n[READY]\n1. Colok OTG HP Target ke HP ini\n2. Aktifkan USB Debugging di HP Target\n3. Klik SCAN\n\nFitur:\n- ADB devices/shell/install/push\n- Fastboot flash/erase/reboot\n- MTK/QCOM detect\n\nLog:\n";
  List<String> devices = [];

  Future<void> scan() async {
    try {
      final res = await channel.invokeMethod('scanUsb');
      setState(() { log += "\n[SCAN] $res\n"; });
    } catch(e){ setState(()=> log += "\n[OTG] Scan via native belum aktif, tapi APK tetap jalan.\nDevice harus OTG Host.\nError: $e\n"); }
  }
  void adbCmd(String cmd){
    setState(()=> log += "\n> adb $cmd\n[EXEC] Simulasi V1 - V2 butuh NDK binary\nUntuk real ADB, butuh root + libusb\n");
  }

  @override Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text("FLASH MASTER OTG", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), backgroundColor: Color(0xFF0F172A), actions: [IconButton(icon: Icon(Icons.usb_rounded), onPressed: scan)]),
      body: Column(children: [
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))), child: Column(children: [
          Row(children: [
            Expanded(child: ElevatedButton.icon(icon: Icon(Icons.search), label: Text("SCAN OTG"), onPressed: scan, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black))),
            SizedBox(width:8),
            Expanded(child: ElevatedButton.icon(icon: Icon(Icons.bolt), label: Text("REBOOT BL"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), onPressed: ()=> adbCmd("reboot bootloader"))),
          ]),
          SizedBox(height:10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            _tool(Icons.install_mobile, "Install APK", "adb install", ()=> adbCmd("install /sdcard/app.apk")),
            _tool(Icons.file_upload, "Push", "adb push", ()=> adbCmd("push file /sdcard/")),
            _tool(Icons.file_download, "Pull", "adb pull", ()=> adbCmd("pull /sdcard/")),
            _tool(Icons.terminal, "Shell", "getprop", ()=> adbCmd("shell getprop ro.product.model")),
            _tool(Icons.screenshot, "Screencap", "cap", ()=> adbCmd("shell screencap")),
            _tool(Icons.restart_alt, "Reboot", "reboot", ()=> adbCmd("reboot")),
            _tool(Icons.system_update, "Flash Boot", "fastboot", ()=> adbCmd("fastboot flash boot boot.img")),
            _tool(Icons.memory, "GetVar", "fastboot", ()=> adbCmd("fastboot getvar all")),
            _tool(Icons.delete_forever, "Erase Cache", "fastboot", ()=> adbCmd("fastboot erase cache")),
          ])),
        ])),
        Expanded(child: Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: SingleChildScrollView(child: Text(log, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent))))),
      ]),
      floatingActionButton: FloatingActionButton.extended(icon: Icon(Icons.play_arrow), label: Text("ADB DEVICES"), backgroundColor: Color(0xFF0F172A), onPressed: ()=> adbCmd("devices")),
    );
  }
  Widget _tool(IconData i, String t, String sub, VoidCallback f) => Container(width: 88, height: 82, margin: EdgeInsets.only(right: 8), child: ElevatedButton(onPressed: f, style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E293B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 22), SizedBox(height:4), Text(t, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 7, color: Colors.white54))]))),
}

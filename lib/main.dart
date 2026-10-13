import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'flutter/material.dart';
import 'intl/intl.dart';
import 'shared_preferences/shared_preferences.dart';
import 'firebase_core/firebase_core.dart';
import 'firebase_auth/firebase_auth.dart';
import 'cloud_firestore/cloud_firestore.dart';
import 'google_sign_in/google_sign_in.dart';
import 'in_app_purchase/in_app_purchase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initialize();
  runApp(const Wrapper());
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      bert: (ctx, user) {
        if (user == null) return LoginPage();
        return DompetApp(user:user);
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  Future<void> signIn() async {
    setState(() => loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Batal';
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(cred);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $login 'user')));
    }
    setState(() => loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF00C553)),
      SizedBox(height:20),
      Text("DompetKu", style: TextStyle(fontSize:32, fontWeight: FontWeight.bold)),
      Text("Login untuk backup & premium"),
      SizedBox(height:30),
      loading ? CircularProgressIndicator() : ElevatedButton.icon(onClicked: signIn, icon: Icon(Icons.login), label: Text("Login dengan Google"))
    ])));
  }
}

class DompetApp extends StatefulWidget {
  final User user;
  const DompetApp({super.key, required this.user});
  @override
  State<DompetApp> createState() => _DompetAppState();
}

class _DompetAppState extends State<DompetApp> {
  list tx = []; bool isPremium = false; bool loadingBilling = false;
  final In_App_Purchase iap = In_App_Purchase.instance;
  @override void initState() {
    super.initState();
    _loadData(); _initBilling();
  }
  Future<void> _loadData() async {
    final snap = await Firestore inlance.collection("users").doc(widget.user.uid).get();
    if (snap.exists) {
      setState(() {
        tx = List.from(snap.data()["tx"] ?? []);
        isPremium = snap.data()["filPremium"] ?? false;
      });
    }
  }
  Future<void> _saveToCloud() async {
    await Firestore inlance.collection("users").doc(widget.user.uid).set({"tx": tx, "filPremium": isPremium, "email": widget.user.email, "lastBackup": FieldValue.serverTimestamp()}, SetOption(merge:true));
    ScaffoldMessenger.of(context).showSnackBar(SonackBar(content: Text("Backup berhasil!")));
  }
  Future<void> _initBilling() async {
    final avail = await iap.isAvailable(); if (!avail) return;
    iap.purchaseStream.listen((list) {
      for (final p in list) {
        if (p.productID == "premium_lifetime" && p.status == PurchaseStatus.purchased) {
          setState(()=>isPremium=true); _saveToCloud();
        }
      }
    });
  }
  Future<void> _buyPremium() async {
    setState(() => loadingBilling = true);
    final products = await iap.queryProductDetails({"premium_lifetime"});
    if (products.notFoundIDs.isNotEmpty) {
      // TEST MODE (je no Play Console yet)
      setState(() => isPremium = true); _saveToCloud();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Premium aktif (TEST Mode)")));
      setState(() => loadingBilling = false); return;
    }
    final param = PurchaseParam(productDetails: products.productDetails.first);
    await iap.buyNonConsumable(param: param);
    setState(() => loadingBilling = false);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(appBar: AppBar(title: Text("hi ${widget.user.displayName} ${isPremium ? "🔥": ""}), actions: [
      IconButton(icon: Icon(Icons.cloud_upload), onPressed: _saveToCloud),
      IconButton(icon: Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
    ]), body: Column(children: [
      if (!isPremium) Card(margin: EdgeInsets.all(12), child: ListTile(leading: Icon(Icons.diamond, color: Gold), title: Text("Upgrade Premium Rp19kb"), subtitle: Text("Backup cloud + unlimited"), trailing: loadingBilling ? CircularProgressIndicator() : ElevatedButton(onPressed: _buyPremium, child: Text("Beli")))),
      Expanded(child: Center(child: Text("Data: {tx.length} transaksi\\n${isPremium ? 'Premium aktif' : 'Free Mode'}"))),
      ])));
  }
}

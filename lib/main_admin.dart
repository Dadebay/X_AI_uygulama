import 'package:atlas/firebase_options.dart';
import 'package:atlas/modules/admin/views/web/admin_web_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Admin panelinin web build entrypoint'i. Mobil uygulamanın (splash, auth,
/// tema, dil, reklam vb.) hiçbir bağımlılığını import etmez — bu sayede
/// dart2js tree-shaking mobil kod ağacını ve onun asset'lerini (hugeicons
/// fontu dahil) admin bundle'ından tamamen eleyebilir.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web'de Firestore'un IndexedDB cache'i varsayılan kapalı; açınca dönen
  // ziyaretçide takım/kullanıcı listeleri anında cache'ten gelir.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pulse Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ThemeData.dark().colorScheme.copyWith(primary: const Color(0xFF00C853)),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Gilroy'),
        primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(fontFamily: 'Gilroy'),
      ),
      home: const AdminWebApp(),
    );
  }
}

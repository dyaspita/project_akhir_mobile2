import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';
import 'model/pemesanan_model.dart';
import 'model/layanan.dart';
import 'utils/time_adapter.dart';
import 'services/notification_service.dart';

import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'pages/detail_penitipan.dart';
import 'pages/pemesanan.dart';
import 'pages/ringkasan_pemesanan.dart';
import 'pages/riwayat.dart';
import 'pages/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  await Hive.initFlutter();
  await SharedPreferences.getInstance();

  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PesananAdapter());

  if (!Hive.isBoxOpen('userbox')) await Hive.openBox<User>('userbox');
  if (!Hive.isBoxOpen('pesananbox')) await Hive.openBox<Pesanan>('pesananbox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Hotel',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(), 
        '/login': (context) => const Login(title: 'Login'),
        '/register': (context) => const Register(title: 'Register'),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/ringkasan': (context) => const RingkasanPemesananPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/detail_penitipan': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final layananData = (args is Map)
              ? Map<String, dynamic>.from(args)
              : <String, dynamic>{};
          return DetailPenitipanPage(layananData: layananData);
        },
        '/pemesanan': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final layananMap = (args is Map)
              ? Map<String, dynamic>.from(args)
              : <String, dynamic>{};
          return PemesananPage(layanan: Layanan.fromMap(layananMap));
        },
      },
    );
  }
}

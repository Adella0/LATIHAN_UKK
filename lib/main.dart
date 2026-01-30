import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_routes.dart';

void main() async {
  // 1. Inisialisasi binding Flutter agar plugin dapat berjalan sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase menggunakan URL dan Anon Key Anda
  await Supabase.initialize(
    url: 'https://rnnoextdauvjomslctcn.supabase.co',
    anonKey: 'sb_publishable__CzlJitG8VMKtzjUNKirVw_T3Pb0bJF', // Pastikan key ini terbaru dari dashboard Supabase
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SarprasGo',
      initialRoute: '/', // Mengarah ke SplashScreen
      routes: AppRoutes.routes, // Memuat rute dari file AppRoutes yang sudah diupdate
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
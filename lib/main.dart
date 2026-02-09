import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rnnoextdauvjomslctcn.supabase.co',
    anonKey: 'sb_publishable__CzlJitG8VMKtzjUNKirVw_T3Pb0bJF', // Masukkan key asli kamu
  );

  await initializeDateFormatting('id', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil user yang sedang login
    final session = Supabase.instance.client.auth.currentSession;

   return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Aplikasi Peminjaman',
  // Gunakan initialRoute dari AppRoutes
  initialRoute: AppRoutes.initial, 
  // Daftarkan rute yang sudah kita buat
  routes: AppRoutes.routes,
);
  }
}
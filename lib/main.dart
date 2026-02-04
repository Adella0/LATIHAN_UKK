import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rnnoextdauvjomslctcn.supabase.co',
    anonKey: 'sb_publishable__CzlJitG8VMKtzjUNKirVw_T3Pb0bJF', // Masukkan key asli kamu
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
      initialRoute: AppRoutes.initial, // Ini akan membuka LoginScreen (sesuai setting di AppRoutes)
      routes: AppRoutes.routes,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'daftar_riwayat_aktivitas.dart';
import '../ui/profil.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  String userName = "";
  String userRole = "";
  bool isLoading = true;

  // Variabel Statistik
  String totalAlat = "0";
  String penggunaAktif = "0";
  String totalDenda = "0";

  List<Map<String, dynamic>> pieChartData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); 
  }

 Future<void> _loadDashboardData() async {
  try {
    final supabase = Supabase.instance.client;
    
    // 1. Profil Admin yang sedang login
    final user = supabase.auth.currentUser;
    if (user != null) {
      final res = await supabase.from('users').select().eq('id_user', user.id).maybeSingle();
      if (res != null) {
        userName = res['nama'] ?? "Admin";
        userRole = res['role']?.toString().toUpperCase() ?? "ADMIN";
      }
    }

    // 2. STATISTIK (DIPERBAIKI)
    
    // a. Total Alat: Menghitung jumlah baris di tabel alat
    final resAlat = await supabase.from('alat').select('id_alat');
    int hitungAlat = (resAlat as List).length;

    // b. Pengguna Aktif: Menghitung user yang session-nya sedang aktif
    final resAktif = await supabase.from('users').select('id_user'); 
    // Catatan: Jika kamu punya kolom 'status' atau 'is_online', tambahkan .eq('status', true)
    int hitungAktif = (resAktif as List).length; 

    // c. Total Denda: Menghitung jumlah baris di tabel denda
    int hitungDenda = 0;
    try {
      final resDenda = await supabase.from('denda').select('id_denda');
      hitungDenda = (resDenda as List).length;
    } catch (e) {
      hitungDenda = 0;
    }

    // 3. GRAFIK (TETAP SAMA)
    final resChart = await supabase.from('detail_peminjaman').select('jumlah, id_alat');
    final alatRes = await supabase.from('alat').select('id_alat, nama_alat');
    Map<dynamic, String> mapAlat = {
      for (var a in alatRes) a['id_alat']: a['nama_alat'].toString()
    };

    Map<String, double> hasilHitung = {};
    for (var item in resChart) {
      String namaAlat = mapAlat[item['id_alat']] ?? "Alat ${item['id_alat']}";
      double jml = double.tryParse(item['jumlah'].toString()) ?? 0;
      if (jml > 0) {
        hasilHitung[namaAlat] = (hasilHitung[namaAlat] ?? 0) + jml;
      }
    }

    List<Color> warna = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    int i = 0;
    List<Map<String, dynamic>> dataBaru = hasilHitung.entries.map((e) {
      return {"label": e.key, "value": e.value, "color": warna[i++ % warna.length]};
    }).toList();

    if (mounted) {
      setState(() {
        totalAlat = hitungAlat.toString();
        penggunaAktif = hitungAktif.toString();
        totalDenda = hitungDenda.toString();
        pieChartData = dataBaru;
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("DEBUG ERROR: $e");
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildStatSection(), // Bagian yang diupdate
                  const SizedBox(height: 30),
                  _buildGraphTitle(),
                  const SizedBox(height: 10),
                  _buildChartSection(),
                  const SizedBox(height: 25),
                  _buildActivityHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      children: [
                        _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                        _buildActivityItem("Monica", "12/01/2026", "Peminjam"),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF424242),
              child: Icon(Icons.person, size: 38, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, $userName!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(userRole, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard("Total alat", totalAlat),
          _buildStatCard("Total pengguna", penggunaAktif), // Nama diubah
          _buildStatCard("Total denda", totalDenda), // Nama diubah
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC9D0D6).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraphTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          Text("Grafik alat paling sering dipinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (pieChartData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text("Data Kosong")),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                sections: pieChartData.map((data) {
                  return PieChartSectionData(
                    color: data['color'],
                    value: data['value'],
                    title: data['value'].toInt().toString(),
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pieChartData.map((data) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 10, height: 10, color: data['color']),
                  const SizedBox(width: 8),
                  Text(data['label'], style: const TextStyle(fontSize: 12)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Log aktivitas", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas())),
            child: const Text("Detail >", style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String nama, String tanggal, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: $nama", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
              Text("Tanggal: $tanggal", style: GoogleFonts.poppins(fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'Petugas' ? const Color(0xFF02182F) : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 8)),
          ),
        ],
      ),
    );
  }
}
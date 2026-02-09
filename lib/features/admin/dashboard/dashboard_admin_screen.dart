import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Pastikan sudah tambah intl di pubspec.yaml
import 'daftar_riwayat_aktivitas.dart';
import '../ui/profil.dart';
import 'detail_denda.dart';

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
  List<Map<String, dynamic>> _logAktivitas = []; // Penampung Log

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

      // 2. STATISTIK (KODE ASLI ANDA)
      final resAlat = await supabase.from('alat').select('id_alat');
      int hitungAlat = (resAlat as List).length;

      final resAktif = await supabase.from('users').select('id_user');
      int hitungAktif = (resAktif as List).length;

      int hitungDenda = 0;
      try {
        final resDenda = await supabase.from('denda').select('id_denda');
        hitungDenda = (resDenda as List).length;
      } catch (e) {
        hitungDenda = 0;
      }

      // 3. GRAFIK (KODE ASLI ANDA)
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

      // --- LOGIKA LOG AKTIVITAS (FOKUS PERBAIKAN DI SINI) ---
      final resLog = await supabase
          .from('log_aktivitas')
          .select('''
            aksi,
            created_at,
            users:user_id (nama, role)
          ''')
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          totalAlat = hitungAlat.toString();
          penggunaAktif = hitungAktif.toString();
          totalDenda = hitungDenda.toString();
          pieChartData = dataBaru;
          _logAktivitas = List<Map<String, dynamic>>.from(resLog);
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
                  _buildStatSection(),
                  const SizedBox(height: 30),
                  _buildGraphTitle(),
                  const SizedBox(height: 10),
                  _buildChartSection(),
                  const SizedBox(height: 25),
                  _buildActivityHeader(),
                  
                  // LIST LOG DINAMIS (FOKUS PERBAIKAN DI SINI)
                  Expanded(
                    child: _logAktivitas.isEmpty
                        ? Center(child: Text("Belum ada aktivitas", style: GoogleFonts.poppins(fontSize: 12)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            itemCount: _logAktivitas.length,
                            itemBuilder: (context, index) {
                              final log = _logAktivitas[index];
                              
                              final String nama = log['users']?['nama'] ?? "User Tidak Dikenal";
                              final String roleRaw = log['users']?['role'] ?? "User";
                              final String aksi = log['aksi'] ?? "Melakukan aktivitas";
                              
                              // Format Tanggal lebih cantik
                              DateTime dt = DateTime.parse(log['created_at']).toLocal();
                              String tanggal = DateFormat('dd MMM yyyy, HH:mm').format(dt);

                              return _buildActivityItem(nama, tanggal, roleRaw, aksi);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- WIDGET KOMPONEN (TETAP SAMA) ---

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
          _buildStatCard("Total pengguna", penggunaAktif),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailDendaPage())),
            child: _buildStatCard("Total denda", totalDenda),
          ),
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
          borderRadius: BorderRadius.circular(12)),
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
    if (pieChartData.isEmpty) return const SizedBox(height: 150, child: Center(child: Text("Data Kosong")));
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
        ],
      ),
    );
  }

  // DESAIN CARD BARU (LEBIH BERSIH DAN MODERN)
  Widget _buildActivityItem(String nama, String tanggal, String role, String aksi) {
    bool isPetugas = role.toLowerCase() == 'petugas';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPetugas ? const Color(0xFF02182F) : Colors.grey[200],
            child: Text(nama[0].toUpperCase(), 
              style: TextStyle(color: isPetugas ? Colors.white : Colors.black87, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPetugas ? const Color(0xFFE3F2FD) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(role, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isPetugas ? Colors.blue[900] : Colors.grey[600])),
                    ),
                  ],
                ),
                Text(aksi, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(tanggal, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
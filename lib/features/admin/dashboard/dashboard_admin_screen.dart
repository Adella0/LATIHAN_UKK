import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 
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

  String totalAlat = "0";
  String penggunaAktif = "0";
  String totalDenda = "0";

  List<Map<String, dynamic>> pieChartData = [];
  List<Map<String, dynamic>> _logAktivitas = []; 

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;
      if (user != null) {
        final res = await supabase.from('users').select().eq('id_user', user.id).maybeSingle();
        if (res != null) {
          userName = res['nama'] ?? "Admin";
          userRole = res['role']?.toString().toUpperCase() ?? "ADMIN";
        }
      }

      final resAlat = await supabase.from('alat').select('id_alat');
      final resUsers = await supabase.from('users').select('id_user');
      final resDenda = await supabase.from('denda').select('total_denda');
      
      double totalNominalDenda = 0;
      if (resDenda != null) {
        for (var item in resDenda) {
          totalNominalDenda += double.tryParse(item['total_denda'].toString()) ?? 0;
        }
      }
      
      String displayDenda = totalNominalDenda >= 1000 
          ? "${(totalNominalDenda / 1000).toStringAsFixed(0)}k" 
          : totalNominalDenda.toInt().toString();

      final resLog = await supabase.from('log_aktivitas').select('''
          id_log, aksi, keterangan, created_at,
          users:user_id (nama, role)
        ''').order('created_at', ascending: false).limit(10); // Limit ditambah agar scroll terasa

      final resChart = await supabase.from('detail_peminjaman').select('jumlah, id_alat');
      final alatRes = await supabase.from('alat').select('id_alat, nama_alat');
      
      Map<dynamic, String> mapAlat = { for (var a in alatRes) a['id_alat']: a['nama_alat'].toString() };
      Map<String, double> hasilHitung = {};
      double totalPinjam = 0;

      for (var item in resChart) {
        String namaAlat = mapAlat[item['id_alat']] ?? "Alat";
        double jml = double.tryParse(item['jumlah'].toString()) ?? 0;
        hasilHitung[namaAlat] = (hasilHitung[namaAlat] ?? 0) + jml;
        totalPinjam += jml;
      }

      List<Color> palette = [
        const Color(0xFF0D1B3E),
        const Color(0xFF1A3D8F),
        const Color(0xFF3A7BD5),
        const Color(0xFF74ABE2),
        const Color(0xFFA6C1EE),
        const Color(0xFFCBD5E0),
      ];

      int colorIdx = 0;
      List<Map<String, dynamic>> dataBaru = hasilHitung.entries.map((e) {
        double persentase = (e.value / totalPinjam) * 100;
        return {
          "label": e.key, 
          "value": e.value, 
          "percent": "${persentase.toStringAsFixed(0)}%",
          "color": palette[colorIdx++ % palette.length]
        };
      }).toList();

      if (mounted) {
        setState(() {
          totalAlat = (resAlat as List).length.toString();
          penggunaAktif = (resUsers as List).length.toString();
          totalDenda = displayDenda;
          _logAktivitas = List<Map<String, dynamic>>.from(resLog);
          pieChartData = dataBaru;
          isLoading = false;
        });
      }
    } catch (e) {
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
            : Column( // Menggunakan Column agar header tetap statis
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildStatSection(),
                  const SizedBox(height: 35),
                  _buildGraphTitle(),
                  _buildChartSection(),
                  const SizedBox(height: 30),
                  _buildActivityHeader(),
                  // Expanded digunakan agar ListView di bawah mengambil sisa ruang dan bisa scroll
                  Expanded(
                    child: _buildLogList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const CircleAvatar(radius: 26, backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.person, color: Colors.black54)),
          ),
        ),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hi, $userName!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
          Text(userRole, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildStatSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard("Total alat", totalAlat)),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard("Total pengguna", penggunaAktif)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailDendaPage())),
              child: _buildStatCard("Total denda", totalDenda),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D1B3E))),
      ]),
    );
  }

  Widget _buildGraphTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF0D1B3E), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text("Grafik peminjaman alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    );
  }

  Widget _buildChartSection() {
    if (pieChartData.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Data Kosong")));
    
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: pieChartData.map((data) {
                  return PieChartSectionData(
                    color: data['color'],
                    value: data['value'],
                    title: data['percent'], 
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              shrinkWrap: true,
              children: pieChartData.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(data['label'], 
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text("Log aktivitas terbaru", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLogList() {
    if (_logAktivitas.isEmpty) return const Center(child: Text("Belum ada aktivitas"));
    return ListView.builder(
      // shrinkWrap dilepas agar performa scroll lebih baik dalam Expanded
      physics: const AlwaysScrollableScrollPhysics(), 
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _logAktivitas.length,
      itemBuilder: (context, index) {
        final log = _logAktivitas[index];
        final String nama = log['users']?['nama'] ?? "User";
        final String aksi = log['aksi'] ?? "";
        DateTime dt = DateTime.parse(log['created_at']).toLocal();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            onTap: () => _showLogDetail(log),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF0F2F5),
              child: Text(nama[0].toUpperCase(), style: const TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold)),
            ),
            title: Text(nama, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(aksi, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
            trailing: Text(DateFormat('HH:mm').format(dt), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ),
        );
      },
    );
  }

  void _showLogDetail(Map<String, dynamic> log) {
    // Detail log logic
  }
}
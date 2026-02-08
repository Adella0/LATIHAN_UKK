import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  String totalAlat = "0";
  String pinjamanAktif = "0";
  String barangRusak = "0";

  final List<Map<String, dynamic>> chartData = [
    {"label": "Proyektor", "value": 200, "color": const Color(0xFF02182F)},
    {"label": "Tv", "value": 185, "color": const Color(0xFFC9D0D6)},
    {"label": "Bola basket", "value": 165, "color": const Color(0xFF02182F)},
    {"label": "Remot", "value": 115, "color": const Color(0xFFC9D0D6)},
    {"label": "Meja", "value": 85, "color": const Color(0xFF02182F)},
  ];

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
      // 1. Ambil data mentah tanpa filter kolom dulu biar tidak error nama kolom
      final res = await supabase
          .from('users')
          .select() 
          .eq('id_user', user.id)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          // Ambil data 'nama' atau 'nama_user'. Kita cek mana yang ada isinya.
          userName = res['nama'] ?? res['nama_user'] ?? "Admin";
          
          // Ambil role dan buat huruf depannya kapital (admin -> Admin)
          String roleRaw = res['role'] ?? "Admin";
          userRole = roleRaw[0].toUpperCase() + roleRaw.substring(1);
          
          isLoading = false;
        });
      }
    }
  } catch (e) {
    debugPrint("Error Dashboard: $e");
    if (mounted) setState(() => isLoading = false);
  }
}

  // --- FUNGSI POP-UP DETAIL LOG ---
  void _showDetailPopup(String nama, String tanggal, String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Detail Riwayat", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow("Nama", nama),
            _buildDetailRow("Tanggal", tanggal),
            _buildDetailRow("Role", role),
            _buildDetailRow("Status", "Selesai"),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
                  const SizedBox(height: 35),
                  _buildGraphTitle(),
                  _buildChartSection(),
                  const SizedBox(height: 25),
                  _buildActivityHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      children: [
                        _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                        _buildActivityItem("Monica", "12/01/2026", "Peminjam"),
                        _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                        _buildActivityItem("Monica", "12/01/2026", "Peminjam"),
                        const SizedBox(height: 100),
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
              Text("Hi, $userName!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(userRole, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
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
          _buildStatCard("Pinjaman aktif", pinjamanAktif),
          _buildStatCard("Pengguna", barangRusak),
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
          const SizedBox(height: 4),
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
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.fromLTRB(10, 20, 15, 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text("( Jumlah alat yang dipinjam )", style: GoogleFonts.poppins(fontSize: 7, color: Colors.black54)),
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["200", "150", "100", "50", "0"].map((e) => Text(e, style: const TextStyle(fontSize: 9, color: Colors.black54))).toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) => const Divider(height: 1, color: Colors.black12, thickness: 0.5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: chartData.map((data) {
                    double barHeight = (data['value'] / 200) * 140;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 22,
                          height: barHeight,
                          decoration: BoxDecoration(color: data['color'], borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 4),
                        Text(data['label'], style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.w500)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
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
          Row(children: [
            const Icon(Icons.history, size: 20), 
            const SizedBox(width: 8), 
            Text("Log aktivitas", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold))
          ]),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFC9D0D6),
                borderRadius: BorderRadius.circular(10),
                // MENAMBAHKAN BAYANGAN (SHADOW) AGAR MENONJOL
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: const Text("Detail >", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String nama, String tanggal, String role) {
    final Color badgeColor = role == 'Petugas' ? const Color(0xFF02182F) : const Color(0xFFB0B8C1);
    return GestureDetector(
      onTap: () => _showDetailPopup(nama, tanggal, role), // KLIK MUNCUL POPUP
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInfoRow("Nama", nama, role, badgeColor),
                  const SizedBox(height: 4),
                  _buildInfoRow("Tanggal", tanggal, null, null),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String? role, Color? badgeColor) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF02182F)))),
        const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF02182F))),
        if (role != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
            child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
          ),
        ]
      ],
    );
  }
}
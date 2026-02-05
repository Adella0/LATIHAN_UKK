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
        final userData = await supabase.from('users').select('nama, role').eq('id_user', user.id).single();
        final totalRes = await supabase.from('alat').select('id_alat');
        final pinjamRes = await supabase.from('peminjaman').select('id_pinjam').eq('status', 'Dipinjam');
        final rusakRes = await supabase.from('alat').select('id_alat').eq('kondisi', 'Rusak');

        setState(() {
          userName = userData['nama'] ?? "Admin1"; 
          userRole = userData['role'] ?? "Admin";
          totalAlat = totalRes.length.toString();
          pinjamanAktif = pinjamRes.length.toString();
          barangRusak = rusakRes.length.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Admin1";
        userRole = "Admin";
        isLoading = false;
      });
    }
  }

  // --- FUNGSI POP-UP DETAIL ---
  void _showActivityDetail(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 35, height: 4,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF343A40),
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(tanggal, style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF02182F))),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text("Aktivitas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF02182F))),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1.2), borderRadius: BorderRadius.circular(15)),
                child: Text(
                  role == "Petugas" ? "Menyetujui peminjaman alat\n1 proyektor" : "Melakukan peminjaman alat\n1 proyektor",
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF02182F), fontWeight: FontWeight.w500, height: 1.4),
                ),
              ),
            ],
          ),
        ),
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
                  // --- AREA STATIS ---
                  const SizedBox(height: 55),
                  _buildHeader(),
                  const SizedBox(height: 35),
                  _buildStatSection(),
                  const SizedBox(height: 40),
                  _buildGraphTitle(),
                  _buildChartSection(),
                  const SizedBox(height: 30),
                  _buildActivityHeader(),
                  // --- AREA SCROLLABLE (HANYA LOG AKTIVITAS) ---
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      children: [
                        _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                        _buildActivityItem("Monica", "12/01/2026", "Peminjam"),
                        _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                        const SizedBox(height: 110),
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
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilScreen()),
    );
  },
  child: CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF424242),
              child: Icon(Icons.person, size: 38, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName.isEmpty ? "" : "Hi, $userName!", style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black)),
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
          _buildStatCard("Barang rusak", barangRusak),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFC9D0D6).withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraphTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Text("Grafik alat paling sering dipinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Row(
        children: [
          RotatedBox(quarterTurns: 3, child: Text("( Jumlah alat yang dipinjam )", style: GoogleFonts.poppins(fontSize: 8, color: Colors.black87))),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(5, (i) => Container(height: 0.5, color: Colors.black12))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: chartData.map((data) => _buildBar(data['label'], (data['value'] / 200) * 140, data['color'])).toList(),
                ),
              ],
            ),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ["200", "150", "100", "50", "0"].map((e) => Text(e, style: const TextStyle(fontSize: 9, color: Colors.black54))).toList())
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 24, height: height, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)))),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 7, color: Colors.black87)),
      ],
    );
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [const Icon(Icons.history, size: 22), const SizedBox(width: 8), Text("Log aktivitas", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold))]),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFC9D0D6), borderRadius: BorderRadius.circular(15)),
              child: const Text("Detail >", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String nama, String tanggal, String role) {
    final Color badgeColor = role == 'Petugas' ? const Color(0xFF02182F) : const Color(0xFFADB5BD);
    return GestureDetector(
      onTap: () => _showActivityDetail(context, nama, tanggal, role, badgeColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInfoRow("Nama", nama, role, badgeColor),
                  const SizedBox(height: 6),
                  _buildInfoRow("Tanggal", tanggal, null, null),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String? role, Color? badgeColor) {
    return Row(
      children: [
        SizedBox(width: 75, child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF02182F)))),
        const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF02182F))),
        if (role != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
            child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ]
      ],
    );
  }
}
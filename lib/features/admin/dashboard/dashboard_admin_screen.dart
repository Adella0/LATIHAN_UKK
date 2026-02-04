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
  String userName = "Loading...";
  String userRole = "...";
  bool isLoading = true;

  String totalAlat = "-";
  String pinjamanAktif = "-";
  String barangRusak = "-";

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
        final userData = await supabase
            .from('users')
            .select('nama, role')
            .eq('id_user', user.id)
            .single();

        final totalRes = await supabase.from('alat').select('id_alat');
        final pinjamRes = await supabase.from('peminjaman').select('id_pinjam').eq('status', 'Dipinjam');
        final rusakRes = await supabase.from('alat').select('id_alat').eq('kondisi', 'Rusak');

        setState(() {
          userName = userData['nama'] ?? user.email!.split('@')[0];
          userName = userName[0].toUpperCase() + userName.substring(1);
          userRole = userData['role'] ?? "Admin";
          totalAlat = totalRes.length.toString();
          pinjamanAktif = pinjamRes.length.toString();
          barangRusak = rusakRes.length.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : _buildDashboardMainContent(),
      ),
    );
  }

  Widget _buildDashboardMainContent() {
    const Color softGrey = Color(0xFFC9D0D6);
    const Color primaryBlue = Color(0xFF02182F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Atas (Header & Stats)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatSection(softGrey),
                  const SizedBox(height: 35),
                  _buildGraphTitle(primaryBlue),
                  const SizedBox(height: 20),
                  _buildChartSection(),
                  const SizedBox(height: 35),
                  _buildActivityHeader(softGrey),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
        // Bagian List Aktivitas (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                _buildActivityItem("Ailen", "12/01/2026", "Petugas"),
                _buildActivityItem("Monica", "12/01/2026", "Peminjam"),
                _buildActivityItem("Rian", "13/01/2026", "Peminjam"),
                _buildActivityItem("Siska", "14/01/2026", "Petugas"),
                const SizedBox(height: 120), // Ruang agar tidak tertutup Navbar
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN WIDGET (Header, Stats, Chart, dkk) ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF424242),
              child: Icon(Icons.person, size: 35, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, $userName!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(userRole, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard("Total alat", totalAlat, color),
        _buildStatCard("Pinjaman aktif", pinjamanAktif, color),
        _buildStatCard("Alat rusak", barangRusak, color),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraphTitle(Color blue) {
    return Row(
      children: [
        Container(width: 15, height: 15, decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Text("Grafik alat paling sering dipinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 150,
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          RotatedBox(quarterTurns: 3, child: Text("( Jumlah alat )", style: GoogleFonts.poppins(fontSize: 8))),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Proyektor", 100, const Color(0xFF02182F)),
                _buildBar("TV", 80, const Color(0xFFC9D0D6)),
                _buildBar("Basket", 60, const Color(0xFF02182F)),
                _buildBar("Remot", 40, const Color(0xFFC9D0D6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 20, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 8)),
      ],
    );
  }

  Widget _buildActivityHeader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Riwayat aktivitas", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas())),
          child: const Text("Detail >", style: TextStyle(color: Colors.black, fontSize: 12)),
        )
      ],
    );
  }

  Widget _buildActivityItem(String nama, String tanggal, String role) {
    Color badgeColor = role == "Petugas" ? const Color(0xFF02182F) : Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("$nama ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(5)),
                    child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 8)),
                  )
                ],
              ),
              Text(tanggal, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Icon(Icons.chevron_right)
        ],
      ),
    );
  }
}
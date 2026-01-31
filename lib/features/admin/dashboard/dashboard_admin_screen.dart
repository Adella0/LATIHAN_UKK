import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daftar_riwayat_aktivitas.dart';
import '../manage_alat/list_alat_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  // --- STATE UNTUK NAVIGASI ---
  int _selectedIndex = 0; // 0: Dashboard, 1: Alat, 2: Pengguna, 3: Aktivitas

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

  // --- FUNGSI POP-UP DETAIL (TETAP SAMA) ---
  void _showActivityDetail(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const Text(":  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Row(
                    children: [
                      Text(nama, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const Text(":  ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(tanggal, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 25),
            Text("Aktivitas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role == "Petugas" 
                    ? "Menyetujui peminjaman alat\n1 proyektor" 
                    : "Melakukan peminjaman alat\n1 proyektor",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          String rawName = userData['nama'] ?? "";
          if (rawName.isEmpty && user.email != null) {
            userName = user.email!.split('@')[0]; 
          } else {
            userName = rawName.isNotEmpty ? rawName : "User";
          }
          userName = userName[0].toUpperCase() + userName.substring(1);

          String roleRaw = userData['role'] ?? "Admin";
          userRole = roleRaw.isNotEmpty 
              ? roleRaw[0].toUpperCase() + roleRaw.substring(1) 
              : "Admin";

          totalAlat = totalRes.isEmpty ? "-" : totalRes.length.toString();
          pinjamanAktif = pinjamRes.isEmpty ? "-" : pinjamRes.length.toString();
          barangRusak = rusakRes.isEmpty ? "-" : rusakRes.length.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (Supabase.instance.client.auth.currentUser?.email != null) {
          userName = Supabase.instance.client.auth.currentUser!.email!.split('@')[0];
          userName = userName[0].toUpperCase() + userName.substring(1);
        } else {
          userName = "User";
        }
        userRole = "Admin";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);

    // LOGIKA PILIH HALAMAN
    Widget bodyContent;
    if (_selectedIndex == 0) {
      bodyContent = _buildDashboardMainContent();
    } else if (_selectedIndex == 1) {
      bodyContent = ListAlatScreen(); // Masuk ke halaman List Alat
    // Di dalam dashboard_admin_screen.dart
} else if (_selectedIndex == 3) {
  // Ganti ini agar tidak memanggil DaftarRiwayatAktivitas() secara langsung
  bodyContent = const Center(child: Text("Halaman Ringkasan Aktivitas")); 
} else {
      bodyContent = const Center(child: Text("Halaman Belum Tersedia"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : bodyContent, // Menampilkan konten sesuai index yang dipilih
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(primaryBlue),
    );
  }

  // --- KONTEN UTAMA DASHBOARD ---
  Widget _buildDashboardMainContent() {
    const Color primaryBlue = Color(0xFF02182F);
    const Color softGrey = Color(0xFFC9D0D6);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildHeader(),
          const SizedBox(height: 35),
          _buildStatSection(softGrey),
          const SizedBox(height: 40),
          _buildGraphTitle(primaryBlue),
          const SizedBox(height: 30),
          _buildChartSection(primaryBlue, softGrey),
          const SizedBox(height: 60),
          _buildActivityHeader(softGrey),
          const SizedBox(height: 20),
          _buildActivityItem("Ailen", "12/01/2026", "Petugas", primaryBlue),
          _buildActivityItem("Monica", "12/01/2026", "Peminjam", const Color(0xFFADB5BD)),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- WIDGET KOMPONEN LAINNYA (TETAP SAMA) ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Color(0xFF424242),
          child: Icon(Icons.person, size: 45, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, $userName!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(userRole, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6C757D), fontWeight: FontWeight.w500)),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraphTitle(Color blue) {
    return Row(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Text("Grafik alat paling sering dipinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildChartSection(Color blue, Color grey) {
    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text("( Jumlah alat yang dipinjam )", 
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => _buildYAxisLine((200 - (index * 50)).toString())),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Proyektor", 180, blue),
                      _buildBar("Tv", 170, grey),
                      _buildBar("Bola basket", 150, blue),
                      _buildBar("Remot", 100, grey),
                      _buildBar("Meja", 70, blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLine(String val) {
    return Row(
      children: [
        SizedBox(width: 30, child: Text(val, style: GoogleFonts.poppins(fontSize: 11))),
        const Expanded(child: Divider(color: Colors.black26, thickness: 1)),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
        const SizedBox(height: 12), 
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActivityHeader(Color color) { // color di sini adalah softGrey (0xFFC9D0D6)
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          const Icon(Icons.history, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Text("Riwayat aktivitas", 
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
      GestureDetector(
        onTap: () {
          // Navigasi ke halaman baru (bukan pindah index tab)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Padding diperbesar sedikit agar lebih proporsional
          decoration: BoxDecoration(
            color: color, // Ini akan menampilkan warna abu-abu muda (softGrey)
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Text(
                "Detail", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildActivityItem(String nama, String tanggal, String role, Color badgeColor) {
    return GestureDetector(
      onTap: () => _showActivityDetail(context, nama, tanggal, role, badgeColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 60, child: Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                      const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(nama, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(width: 60, child: Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                      const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(tanggal, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black, size: 28),
          ],
        ),
      ),
    );
  }

  // --- REVISI BOTTOM NAV AGAR BISA PINDAH INDEX ---

  Widget _buildBottomNav(Color blue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 10), 
      height: 80, 
      decoration: BoxDecoration(
        color: blue, 
        borderRadius: BorderRadius.circular(40), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Dashboard", 0),
          _buildNavItem(Icons.inventory_2, "Alat", 1),
          _buildNavItem(Icons.people, "Pengguna", 2),
          _buildNavItem(Icons.description, "Aktivitas", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Mengecek apakah index ini yang sedang dipilih
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Mengganti halaman aktif
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32), 
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)), 
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2.5,
              width: 30,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
            )
          else
            const SizedBox(height: 6.5), 
        ],
      ),
    );
  }
}
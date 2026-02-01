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
 // --- REVISI FUNGSI POP-UP DETAIL SESUAI GAMBAR ---
  // --- REVISI FUNGSI MENJADI DIALOG TENGAH (CENTERED POP-UP) ---
  void _showActivityDetail(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      // Mengurangi panjang ke samping sesuai instruksi (menambah horizontal inset)
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.12, 
      ),
      child: Container(
        // Padding bawah dikurangi agar proporsional, tidak terlalu "kosong" di bawah
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar di tengah atas
            Center(
              child: Container(
                width: 35,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header: Profil di kiri, Tanggal di kanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memaksa tanggal ke ujung kanan
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
                        Text(
                          nama,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02182F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tanggal dipojokkan sesuai lebar baru
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tanggal, // Menghilangkan teks "Tanggal :" agar lebih hemat ruang di dialog ramping
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF02182F),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 22),
            
            Text(
              "Aktivitas",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: const Color(0xFF02182F),
              ),
            ),
            const SizedBox(height: 8),
            
            // Box Aktivitas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 1.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                role == "Petugas" 
                    ? "Menyetujui peminjaman alat\n1 proyektor" 
                    : "Melakukan peminjaman alat\n1 proyektor",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF02182F),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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

    return Column( // Menggunakan Column utama agar bagian atas tidak ikut tergulung
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // --- BAGIAN STATIS (TIDAK BISA SCROLL) ---
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const SizedBox(height: 70),
    _buildHeader(),
    const SizedBox(height: 38), 
    _buildStatSection(softGrey),
    const SizedBox(height: 40),
    _buildGraphTitle(primaryBlue),
    const SizedBox(height: 30),
    _buildChartSection(primaryBlue, softGrey),
    const SizedBox(height: 40), // Jarak sebelum masuk area scroll
    _buildActivityHeader(softGrey),
    const SizedBox(height: 15),
    ],
    ),
    ),

    // --- BAGIAN DINAMIS (HANYA INI YANG BISA SCROLL) ---
    Expanded(
    child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
    children: [
    _buildActivityItem("Ailen", "12/01/2026", "Petugas", primaryBlue),
    _buildActivityItem("Monica", "12/01/2026", "Peminjam", const Color(0xFFADB5BD)),
    _buildActivityItem("Rian", "13/01/2026", "Peminjam", const Color(0xFFADB5BD)),
    _buildActivityItem("Siska", "14/01/2026", "Petugas", primaryBlue),
                    
    // Ruang ekstra di bawah agar tidak tertutup BottomNav
    const SizedBox(height: 120), 
    ],
    ),
    ),
    ),
    ],
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
    padding: const EdgeInsets.symmetric(vertical: 18), // Sedikit dipersempit agar lebih compact
    decoration: BoxDecoration(
      color: color, 
      borderRadius: BorderRadius.circular(15)
    ),
    child: Column(
      children: [
        Text(
          title, 
          style: GoogleFonts.poppins(
            fontSize: 13, // Ukuran teks judul kecil sesuai gambar
            fontWeight: FontWeight.w600, // Tidak terlalu tebal agar kontras dengan angka
            color: const Color(0xFF02182F),
          ),
        ),
        const SizedBox(height: 4), // Jarak diperkecil agar lebih padat
        Text(
          value, 
          style: GoogleFonts.poppins(
            fontSize: 22, // Angka tetap besar sebagai poin utama
            fontWeight: FontWeight.bold,
            color: const Color(0xFF02182F),
          ),
        ),
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
  const Color darkBlue = Color(0xFF02182F);
  const Color lightGrey = Color(0xFFC9D0D6);

  return Container(
    height: 160, // Diperkecil lagi agar lebih padat
    padding: const EdgeInsets.only(right: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Teks Samping Rata Tengah
        RotatedBox(
          quarterTurns: 3,
          child: Text(
            "( Jumlah alat yang dipinjam )",
            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 4. Jarak garis antar jumlah dipersempit dengan height tetap
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => _buildYAxisLine((200 - (index * 50)).toString()),
                ),
              ),
              // Area Batang
              Positioned(
                left: 35,
                right: 0,
                bottom: 0, // 2. Memastikan menempel tepat di garis 0
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 1. Jarak kiri kanan lebih rapat
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("Proyektor", 110, darkBlue),
                    _buildBar("Tv", 100, lightGrey),
                    _buildBar("Bola basket", 85, darkBlue),
                    _buildBar("Remot", 60, lightGrey),
                    _buildBar("Meja", 40, darkBlue),
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
  return SizedBox(
    height: 25, // Mengatur kerapatan antar garis horizontal
    child: Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(val, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54)),
        ),
        const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    ),
  );
}

Widget _buildBar(String label, double height, Color color) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 22, // Batang lebih ramping agar grafik tidak terlihat "gemuk"
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
      // 3. Nama alat di bawah garis 0
      const SizedBox(height: 4), 
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

 Widget _buildActivityHeader(Color color) { // color: softGrey (0xFFC9D0D6)
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          const Icon(Icons.history, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Text(
            "Riwayat aktivitas", 
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)
          ),
        ],
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DaftarRiwayatAktivitas()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(10),
            // Menambahkan bayangan halus di bawah tombol
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Warna bayangan transparan
                blurRadius: 6, // Kehalusan bayangan
                offset: const Offset(0, 3), // Posisi bayangan (horizontal, vertical)
              ),
            ],
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
  const Color darkBlue = Color(0xFF02182F);
  const Color softGrey = Color(0xFFADB5BD); // Warna abu-abu untuk peminjam

  // Logika penentuan warna berdasarkan role
  final Color currentRoleColor = role.toLowerCase() == 'petugas' ? darkBlue : softGrey;

  return GestureDetector(
    onTap: () => _showActivityDetail(context, nama, tanggal, role, currentRoleColor),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 1.5), // Border tipis
        borderRadius: BorderRadius.circular(15), // Sudut membulat sesuai gambar
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // Baris Nama
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        "Nama",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: darkBlue),
                      ),
                    ),
                    const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      nama,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: darkBlue),
                    ),
                    const SizedBox(width: 8),
                    // Badge Dinamis: Biru jika Petugas, Abu-abu jika Peminjam
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: currentRoleColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        role,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Baris Tanggal
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        "Tanggal",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: darkBlue),
                      ),
                    ),
                    const Text(":   ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      tanggal,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: darkBlue),
                    ),
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
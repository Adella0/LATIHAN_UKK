import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  // Variabel untuk menampung data user
  String userName = "Loading...";
  String userRole = "...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk mengambil data dari Database
  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        // Ambil data nama dan role dari table 'users' berdasarkan id_user
        final data = await Supabase.instance.client
            .from('users')
            .select('nama, role')
            .eq('id_user', user.id)
            .single();

        setState(() {
          userName = data['nama'] ?? "User";
          // Membuat huruf pertama role jadi Kapital (admin -> Admin)
          String roleRaw = data['role'] ?? "User";
          userRole = roleRaw[0].toUpperCase() + roleRaw.substring(1);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error";
        userRole = "Gagal memuat";
        isLoading = false;
      });
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);
    const Color softGrey = Color(0xFFC9D0D6);
    const Color bgGrey = Color(0xFFD9E0E6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header Profile DINAMIS
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF424242),
                        child: Icon(Icons.person, size: 35, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, $userName!", // MENGGUNAKAN NAMA DARI DATABASE
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            userRole, // MENGGUNAKAN ROLE DARI DATABASE
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // Statistik Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard("Total alat", "50", bgGrey),
                      _buildStatCard("Pinjaman aktif", "25", bgGrey),
                      _buildStatCard("Barang rusak", "3", bgGrey),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Grafik Section
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Grafik alat paling sering dipinjam",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildChartSection(primaryBlue, bgGrey),
                  const SizedBox(height: 40),

                  // Riwayat Aktivitas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history, color: Colors.black, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "Riwayat aktivitas",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgGrey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Detail",
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildActivityItem("Ailen", "12/01/2026", "Petugas", primaryBlue),
                  _buildActivityItem("Monica", "12/01/2026", "Peminjam", softGrey),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(primaryBlue),
    );
  }

  // --- WIDGET HELPER (Tetap Sama Seperti Sebelumnya) ---

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.27,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartSection(Color blue, Color grey) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text("( Jumlah alat yang dipinjam )", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => _buildYAxisLine((200 - (index * 50)).toString())),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Proyektor", 150, blue),
                      _buildBar("Tv", 140, grey),
                      _buildBar("Bola basket", 120, blue),
                      _buildBar("Remot", 80, grey),
                      _buildBar("Meja", 60, blue),
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
        SizedBox(width: 25, child: Text(val, style: GoogleFonts.poppins(fontSize: 10))),
        const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildActivityItem(String nama, String tanggal, String role, Color roleColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 65, child: Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                    const Text(":  "),
                    Text(nama, style: GoogleFonts.poppins(fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: roleColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(role, style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 65, child: Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                    const Text(":  "),
                    Text(tanggal, style: GoogleFonts.poppins(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color blue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      height: 75,
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Dashboard", true),
          _buildNavItem(Icons.inventory_2_outlined, "Alat", false),
          _buildNavItem(Icons.people_outline, "Pengguna", false),
          _buildNavItem(Icons.assignment_outlined, "Aktivitas", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 26),
        Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 22,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          )
      ],
    );
  }
}
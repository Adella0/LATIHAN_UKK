import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPetugasScreen extends StatefulWidget {
  const DashboardPetugasScreen({super.key});

  @override
  State<DashboardPetugasScreen> createState() => _DashboardPetugasScreenState();
}

class _DashboardPetugasScreenState extends State<DashboardPetugasScreen> {
  String userName = "Loading...";
  String userRole = "...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Mengambil nama_lengkap dan role dari tabel users
        final data = await Supabase.instance.client
            .from('users')
            .select('nama_lengkap, role')
            .eq('id_user', user.id)
            .single();

        setState(() {
          userName = data['nama_lengkap'] ?? "User";
          String roleRaw = data['role'] ?? "petugas";
          userRole = roleRaw[0].toUpperCase() + roleRaw.substring(1);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error";
        userRole = "Petugas";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);
    const Color softGrey = Color(0xFFD9E0E6);

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
                    // Header Profile
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: Color(0xFF424242),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $userName!",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              userRole,
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
                    _buildChartSection(primaryBlue, softGrey),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),

                    // Alat yang sedang dipinjam Section
                    _buildSectionHeader("Alat yang sedang dipinjam"),
                    const SizedBox(height: 15),
                    _buildToolItem("Proyektor", "Elektronik", "1", "assets/proyektor.png"),
                    _buildToolItem("Gitar", "Alat musik", "1", "assets/gitar.png"),

                    const SizedBox(height: 25),

                    // Daftar alat segera dikembalikan Section
                    _buildSectionHeader("Daftar alat segera dikembalikan"),
                    const SizedBox(height: 15),
                    _buildToolItem("Proyektor", "Elektronik", "1", "assets/proyektor.png"),
                    _buildToolItem("Gitar", "Alat musik", "1", "assets/gitar.png"),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(primaryBlue),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD9E0E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text("Detail", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
              const Icon(Icons.chevron_right, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(String name, String category, String unit, String imgPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Placeholder Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey), 
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(category, style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text("($unit) unit", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartSection(Color blue, Color grey) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text("( Jumlah alat yang dipinjam )", style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54)),
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
        SizedBox(width: 25, child: Text(val, style: GoogleFonts.poppins(fontSize: 9))),
        const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomNav(Color blue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      height: 70,
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Dashboard", true),
          _buildNavItem(Icons.verified_outlined, "Persetujuan", false),
          _buildNavItem(Icons.assignment_return_outlined, "Pengembalian", false),
          _buildNavItem(Icons.insert_drive_file_outlined, "Laporan", false),
          _buildNavItem(Icons.settings_outlined, "Setting", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 8)),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 18,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          )
      ],
    );
  }
}
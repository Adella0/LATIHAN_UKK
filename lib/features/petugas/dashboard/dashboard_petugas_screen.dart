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
                    // Header Profile sesuai Gambar
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: Color(0xFF34495E), // Warna avatar gelap
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, $userName!",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            Text(
                              userRole,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Grafik Section
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Grafik alat paling sering dipinjam",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildChartSection(primaryBlue, softGrey),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Divider(color: Colors.black12, thickness: 1.5),
                    ),

                    // Alat yang sedang dipinjam Section
                    _buildSectionHeader("Alat yang sedang dipinjam"),
                    const SizedBox(height: 15),
                    _buildToolItem("Proyektor", "Elektronik", "1", primaryBlue),
                    _buildToolItem("Gitar", "Alat musik", "1", primaryBlue),

                    const SizedBox(height: 30),

                    // Daftar alat segera dikembalikan Section
                    _buildSectionHeader("Daftar alat segera dikembalikan"),
                    const SizedBox(height: 15),
                    _buildToolItem("Proyektor", "Elektronik", "1", primaryBlue),
                    _buildToolItem("Gitar", "Alat musik", "1", primaryBlue),

                    const SizedBox(height: 120), // Padding bawah agar tidak tertutup nav
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD9E0E6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text("Detail", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(String name, String category, String unit, Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          // Gambar Alat (Disesuaikan dengan aset yang ada atau placeholder)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(category, style: GoogleFonts.poppins(color: primaryBlue, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text("($unit) unit", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBlue)),
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
            child: Text("( Jumlah alat yang dipinjam )", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => _buildYAxisLine((200 - (index * 50)).toString())),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Proyektor", 160, blue),
                      _buildBar("Tv", 150, grey),
                      _buildBar("Bola basket", 130, blue),
                      _buildBar("Remot", 90, grey),
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
        SizedBox(width: 30, child: Text(val, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500))),
        const Expanded(child: Divider(color: Colors.black26, thickness: 1)),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
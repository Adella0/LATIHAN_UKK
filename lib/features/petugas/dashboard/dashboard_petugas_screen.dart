import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; // Import untuk Pie Chart
import '../ui/profil.dart';

class DashboardPetugasScreen extends StatefulWidget {
  const DashboardPetugasScreen({super.key});

  @override
  State<DashboardPetugasScreen> createState() => _DashboardPetugasScreenState();
}

class _DashboardPetugasScreenState extends State<DashboardPetugasScreen> {
  String userName = "Loading...";
  String userRole = "...";
  bool isLoading = true;

  // Variabel Warna Utama
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _accentBlue = const Color(0xFF3498DB);
  final Color _bgLight = const Color(0xFFF8FAFC);

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
            .select('nama, role')
            .eq('id_user', user.id)
            .single();

        setState(() {
          userName = data['nama'] ?? user.email!.split('@')[0];
          String roleRaw = data['role'] ?? "petugas";
          userRole = roleRaw[0].toUpperCase() + roleRaw.substring(1);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: _primaryDark))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 35),
                    
                    // Card Statistik Utama (Pie Chart)
                    _buildStatCard(),

                    const SizedBox(height: 35),

                    // Section: Alat yang sedang dipinjam
                    _buildSectionTitle("Sedang Dipinjam"),
                    const SizedBox(height: 15),
                    _buildToolItem("Proyektor Epson", "Elektronik", "2"),
                    _buildToolItem("Gitar Yamaha", "Alat Musik", "1"),

                    const SizedBox(height: 30),

                    // Section: Segera Dikembalikan
                    _buildSectionTitle("Segera Dikembalikan"),
                    const SizedBox(height: 15),
                    _buildToolItem("Kamera Canon", "Dokumentasi", "1"),
                    
                    const SizedBox(height: 100), // Spasi bawah agar tidak tertutup navbar
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat Bekerja,",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: _primaryDark,
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Paling Sering Dipinjam", 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: _primaryDark)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      sections: [
                        PieChartSectionData(value: 40, color: _primaryDark, radius: 15, showTitle: false),
                        PieChartSectionData(value: 25, color: _accentBlue, radius: 15, showTitle: false),
                        PieChartSectionData(value: 20, color: const Color(0xFF1ED72D), radius: 15, showTitle: false),
                        PieChartSectionData(value: 15, color: Colors.orange, radius: 15, showTitle: false),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChartLegend(_primaryDark, "Proyektor"),
                      _buildChartLegend(_accentBlue, "TV"),
                      _buildChartLegend(const Color(0xFF1ED72D), "Bola"),
                      _buildChartLegend(Colors.orange, "Lainnya"),
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

  Widget _buildChartLegend(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryDark)),
        Text("Lihat Semua", style: GoogleFonts.poppins(fontSize: 12, color: _accentBlue, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildToolItem(String name, String category, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(color: _bgLight, borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.inventory_2_outlined, color: _primaryDark, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(category, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _primaryDark.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Text("$unit Unit", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryDark)),
          ),
        ],
      ),
    );
  }
}
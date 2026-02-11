import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../ui/profil.dart';
import 'detail_denda.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final supabase = Supabase.instance.client;
  
  String userName = "Admin"; 
  String totalAlat = "0";
  String penggunaAktif = "0";
  String totalDendaStr = "0"; // Untuk tampilan singkat di card (misal: 50k)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // LOGIKA FETCH DATA REAL-TIME
 Future<void> _fetchDashboardData() async {
  try {
    setState(() => isLoading = true);

    // 1. Ambil Jumlah Total Alat & User (Gunakan .count() versi terbaru)
    final resAlat = await supabase.from('alat').select('*').count(CountOption.exact);
    final resUser = await supabase.from('users').select('*').count(CountOption.exact);

    // 2. Ambil data denda
    final List<dynamic> resDenda = await supabase.from('denda').select('total_denda');
    
    double akumulasiDenda = 0;
    for (var item in resDenda) {
      // Gunakan .toDouble() untuk keamanan perhitungan numeric/decimal
      akumulasiDenda += (item['total_denda'] as num? ?? 0).toDouble();
    }

    if (mounted) {
      setState(() {
        totalAlat = resAlat.count.toString();
        penggunaAktif = resUser.count.toString();
        
        // --- LOGIKA FORMATTING "k" ---
        if (akumulasiDenda >= 1000) {
          // Menghasilkan format seperti "10k" atau "10.5k"
          double inK = akumulasiDenda / 1000;
          // Jika angka bulat (misal 10.0), tampilkan "10k". Jika tidak, tampilkan 1 desimal "10.5k"
          totalDendaStr = inK == inK.toInt() 
              ? "${inK.toInt()}k" 
              : "${inK.toStringAsFixed(1)}k";
        } else {
          totalDendaStr = akumulasiDenda.toInt().toString();
        }
        
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("Error Fetch Dashboard: $e");
    if (mounted) setState(() {
      totalDendaStr = "0"; // Default jika error
      isLoading = false;
    });
  }
}

  final List<Map<String, dynamic>> pieChartData = [
    {"label": "Kipas", "value": 35.0, "color": const Color(0xFF1A3D8F)},
    {"label": "Proyektor", "value": 12.0, "color": const Color(0xFF3A7BD5)},
    {"label": "Tv LED", "value": 6.0, "color": const Color(0xFF74ABE2)},
    {"label": "Bola Basket", "value": 3.0, "color": const Color(0xFF0D1B3E)},
  ];

  final Color _primaryColor = const Color(0xFF02182F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 50, bottom: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatSection(),
                        const SizedBox(height: 30),
                        _buildModernDonutChart(), 
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Aktivitas Terbaru", 
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryColor)),
                              Text("Lihat Semua", 
                                style: GoogleFonts.poppins(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Expanded(child: _buildLogList()),
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
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dashboard Admin", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text("Selamat Datang, $userName", 
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
            ],
          ),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(Icons.person_outline, color: _primaryColor, size: 24),
      ),
    );
  }

  Widget _buildStatSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard("Alat", totalAlat, Icons.inventory_2_outlined, const Color(0xFFE3F2FD), Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("User", penggunaAktif, Icons.people_outline, const Color(0xFFFFF3E0), Colors.orange)),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                // Refresh dashboard saat kembali dari halaman detail denda
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailDendaPage()));
                _fetchDashboardData();
              },
              child: _buildStatCard("Denda", "Rp $totalDendaStr", Icons.account_balance_wallet_outlined, const Color(0xFFFFEBEE), Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 15),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor), overflow: TextOverflow.ellipsis),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildModernDonutChart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          SizedBox(
            height: 120, width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 30,
                sections: pieChartData.map((data) => PieChartSectionData(
                  color: data['color'], value: data['value'], radius: 18, showTitle: false,
                )).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Statistik Alat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryColor)),
                const SizedBox(height: 8),
                ...pieChartData.take(4).map((data) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(data['label'], style: GoogleFonts.poppins(fontSize: 10), overflow: TextOverflow.ellipsis)),
                      Text("${data['value'].toInt()}%", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll utama di handle oleh RefreshIndicator/Column
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      itemCount: 5, 
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade50),
          ),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFF1F5F9), child: Icon(Icons.history, color: _primaryColor, size: 18)),
            title: Text("Aktivitas Petugas", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text("Pembaruan status peminjaman", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            trailing: Text("Now", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
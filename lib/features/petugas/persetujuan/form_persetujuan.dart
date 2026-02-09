import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPersetujuan extends StatefulWidget {
  const FormPersetujuan({super.key});

  @override
  State<FormPersetujuan> createState() => _FormPersetujuanState();
}

class _FormPersetujuanState extends State<FormPersetujuan> with TickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _pengajuanPending = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Mengambil data peminjaman yang statusnya 'pending'
      final data = await supabase
          .from('peminjaman')
          .select('*, users(nama, role)')
          .eq('status', 'pending');
      
      setState(() {
        _pengajuanPending = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await supabase.from('peminjaman').update({'status': status}).eq('id_peminjaman', id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pengajuan $status")),
      );
      _fetchData(); // Refresh data
    } catch (e) {
      debugPrint("Error update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Persetujuan",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF02182F),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- SEARCH BAR (Sesuai Gambar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DEE3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10),

            // --- TAB BAR (Sesuai Gambar) ---
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF02182F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF02182F),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: "Proses pengajuan"),
                Tab(text: "Riwayat pengajuan"),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: PROSES PENGAJUAN
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildListProses(),
                  
                  // TAB 2: RIWAYAT (Bisa diisi nanti)
                  const Center(child: Text("Halaman Riwayat")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListProses() {
    if (_pengajuanPending.isEmpty) {
      return const Center(child: Text("Tidak ada pengajuan pending"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pengajuanPending.length,
      itemBuilder: (context, index) {
        final item = _pengajuanPending[index];
        return _buildCardPersetujuan(item);
      },
    );
  }

  Widget _buildCardPersetujuan(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          // Garis handle di atas (Sesuai Desain)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile_placeholder.png'), // Ganti sesuai assetmu
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['users']['nama'] ?? "User",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Peminjam",
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tombol Aksi (Tolak & Setuju)
                    Row(
                      children: [
                        _buildActionBtn("Tolak", Colors.red, () => _updateStatus(item['id_peminjaman'], 'ditolak')),
                        const SizedBox(width: 8),
                        _buildActionBtn("Setuju", Colors.green, () => _updateStatus(item['id_peminjaman'], 'disetujui')),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                
                // Info Pengambilan, Tenggat, Alat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Pengambilan", item['tgl_pinjam'].toString().substring(0,10)),
                    _buildInfoColumn("Tenggat", item['tgl_kembali'].toString().substring(0,10)),
                    _buildInfoColumn("Alat", "${item['total_item']}", isBlue: true),
                  ],
                ),
                
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Lihat detail >",
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        child: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isBlue = false}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
        const SizedBox(height: 5),
        Text(
          value, 
          style: GoogleFonts.poppins(
            fontSize: 11, 
            color: isBlue ? Colors.blue : Colors.black87,
            fontWeight: isBlue ? FontWeight.bold : FontWeight.normal
          )
        ),
      ],
    );
  }
}
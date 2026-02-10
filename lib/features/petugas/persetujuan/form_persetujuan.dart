import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // 1. Sesuaikan query dengan nama tabel 'users' dan kolom 'status_transaksi'
      final data = await supabase
          .from('peminjaman')
          .select('*, users!peminjam_id(nama, role)') // Join menggunakan FK peminjam_id
          .eq('status_transaksi', 'pending')
          .order('pengambilan', ascending: true);
      
      if (mounted) {
        setState(() {
          _pengajuanPending = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk update status sekaligus mencatat di Log Aktivitas
  Future<void> _updateStatus(int idPinjam, String statusBaru, String namaPeminjam) async {
    try {
      final petugas = supabase.auth.currentUser;
      
      // 1. Update status transaksi di tabel peminjaman
      await supabase.from('peminjaman').update({
        'status_transaksi': statusBaru,
        'petugas_id': petugas?.id // Catat siapa petugas yang memproses
      }).eq('id_pinjam', idPinjam);

      // 2. Insert ke tabel log_aktivitas
      await supabase.from('log_aktivitas').insert({
        'user_id': petugas?.id,
        'aksi': 'Persetujuan Alat',
        'keterangan': 'Petugas telah $statusBaru pengajuan dari $namaPeminjam',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil: Pengajuan $statusBaru"), backgroundColor: Colors.green),
        );
        _fetchData(); // Refresh list
      }
    } catch (e) {
      debugPrint("Error update: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memproses data"), backgroundColor: Colors.red),
        );
      }
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
            
            // Search Bar
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
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildListProses(),
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
      return Center(
        child: Text("Tidak ada pengajuan pending", style: GoogleFonts.poppins(color: Colors.grey)),
      );
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
    final String namaUser = item['users']?['nama'] ?? "User";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
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
                      backgroundColor: Color(0xFFD9DEE3),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaUser,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F2F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Peminjam",
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Row(
                      children: [
                        _buildActionBtn("Tolak", Colors.red, () => _updateStatus(item['id_pinjam'], 'ditolak', namaUser)),
                        const SizedBox(width: 8),
                        _buildActionBtn("Setuju", Colors.green, () => _updateStatus(item['id_pinjam'], 'aktif', namaUser)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Pengambilan", _formatDate(item['pengambilan'])),
                    _buildInfoColumn("Tenggat", _formatDate(item['tenggat'])),
                    // Count alat bisa didapat jika Anda sudah menghitung total_unit di tabel peminjaman
                    _buildInfoColumn("Alat", "Detail", isBlue: true), 
                  ],
                ),
                
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Lihat detail >",
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    DateTime dt = DateTime.parse(dateStr).toLocal();
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
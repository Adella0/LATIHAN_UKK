import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'penolakan.dart';
import 'riwayat_persetujuan.dart';
import '../persetujuan/detail_peminjaman.dart';

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
      // Perbaikan Query: Memastikan relasi ke users benar
      final data = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)') 
          .eq('status_transaksi', 'pending')
          .order('pengambilan', ascending: true);
      
      if (mounted) {
        setState(() {
          _pengajuanPending = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Persetujuan: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int idPinjam, String statusBaru, String namaPeminjam) async {
    try {
      final petugas = supabase.auth.currentUser;
      
      await supabase.from('peminjaman').update({
        'status_transaksi': statusBaru,
        'petugas_id': petugas?.id
      }).eq('id_pinjam', idPinjam);

      await supabase.from('log_aktivitas').insert({
        'user_id': petugas?.id,
        'aksi': statusBaru == 'aktif' ? 'Persetujuan Alat' : 'Penolakan Pinjaman',
        'keterangan': 'Petugas telah $statusBaru pengajuan dari $namaPeminjam',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil: Pengajuan $statusBaru"), backgroundColor: Colors.green),
        );
        _fetchData(); 
      }
    } catch (e) {
      debugPrint("Error update: $e");
    }
  }

  void _openTolakDialog(int idPinjam, String namaPeminjam) {
    showDialog(
      context: context,
      builder: (context) => PenolakanDialog(
        namaPeminjam: namaPeminjam,
        onConfirm: (alasan) async {
          await supabase.from('peminjaman').update({
            'status_transaksi': 'ditolak',
            'alasan_penolakan': alasan,
            'petugas_id': supabase.auth.currentUser?.id
          }).eq('id_pinjam', idPinjam);
          
          _updateStatus(idPinjam, 'ditolak', namaPeminjam);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Persetujuan", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
            const SizedBox(height: 20),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFD9DEE3), borderRadius: BorderRadius.circular(30)),
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
              indicatorColor: const Color(0xFF02182F),
              tabs: const [Tab(text: "Proses pengajuan"), Tab(text: "Riwayat pengajuan")],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isLoading ? const Center(child: CircularProgressIndicator()) : _buildListProses(),
                  const RiwayatPersetujuan(),
                  
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
      return Center(child: Text("Tidak ada pengajuan pending", style: GoogleFonts.poppins(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pengajuanPending.length,
      itemBuilder: (context, index) => _buildCardPersetujuan(_pengajuanPending[index]),
    );
  }

  Widget _buildCardPersetujuan(dynamic item) {
    final String namaUser = item['peminjam']?['nama'] ?? "User Tidak Diketahui";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material( // Tambahkan Material agar efek klik (ripple) terlihat
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            // NAVIGASI KE DETAIL
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => DetailPinjamanScreen(idPinjam: item['id_pinjam'])
              )
            ).then((_) => _fetchData()); // Refresh list saat balik dari detail
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFD9DEE3),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaUser, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Peminjam", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Tombol Aksi (Gunakan Row agar tidak terpicu onTap kartu)
                    Row(
                      children: [
                        _buildActionBtn("Tolak", Colors.red, () => _openTolakDialog(item['id_pinjam'], namaUser)),
                        const SizedBox(width: 8),
                        _buildActionBtn("Setuju", Colors.green, () => _updateStatus(item['id_pinjam'], 'aktif', namaUser)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("Pengambilan", _formatDate(item['pengambilan'])),
                    _buildInfoColumn("Tenggat", _formatDate(item['tenggat'])),
                    _buildInfoColumn("Alat", "Detail >", isBlue: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr).toLocal());
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isBlue = false}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.poppins(fontSize: 10, color: isBlue ? Colors.blue : Colors.black)),
      ],
    );
  }
}
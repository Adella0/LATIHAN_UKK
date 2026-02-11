import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../pengembalian/detail_pengembalian.dart';

class ListPengembalian extends StatefulWidget {
  const ListPengembalian({super.key});

  @override
  State<ListPengembalian> createState() => _ListPengembalianState();
}

class _ListPengembalianState extends State<ListPengembalian> with TickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _listProses = [];
  List<dynamic> _listRiwayat = [];
  
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _screenBg = const Color(0xFFF1F4F8); 
  RealtimeChannel? _peminjamanSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    if (_peminjamanSubscription != null) {
      supabase.removeChannel(_peminjamanSubscription!);
    }
    _tabController.dispose();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _peminjamanSubscription = supabase
        .channel('public:peminjaman')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'peminjaman',
          callback: (payload) {
            _fetchData();
          },
        )
        .subscribe();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil data yang sedang mengajukan (dikembalikan)
      final proses = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('status_transaksi', 'dikembalikan')
          .eq('petugas_id', user.id)
          .order('Pengembalian', ascending: false);

      // Ambil data yang sudah selesai
      final riwayat = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('status_transaksi', 'selesai')
          .eq('petugas_id', user.id)
          .order('Pengembalian', ascending: false);

      if (mounted) {
        setState(() {
          _listProses = proses;
          _listRiwayat = riwayat;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Pengembalian", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _primaryDark, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: _primaryDark,
        child: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8), 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari peminjam...",
                    hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            
            // TabBar - URUTAN: Mengajukan dulu baru Riwayat
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: _primaryDark,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _primaryDark,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "Mengajukan"),
                  Tab(text: "Riwayat")
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Mengajukan
                  _isLoading ? _loader() : _buildList(_listProses, isRiwayat: false),
                  // Tab 2: Riwayat
                  _isLoading ? _loader() : _buildList(_listRiwayat, isRiwayat: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loader() => Center(child: CircularProgressIndicator(color: _primaryDark));

  Widget _buildList(List<dynamic> data, {required bool isRiwayat}) {
    if (data.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.black12),
          const SizedBox(height: 10),
          Center(child: Text("Tidak ada data pengembalian", style: GoogleFonts.poppins(color: Colors.grey))),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildCard(data[index], isRiwayat),
    );
  }

  Widget _buildCard(dynamic item, bool isRiwayat) {
    final String namaUser = item['peminjam']?['nama'] ?? "User";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // KLIK KARTU MASUK KE DETAIL
            final refresh = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailKonfirmasiKembali(data: item))
            );
            if (refresh == true) _fetchData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _primaryDark.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          namaUser[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: _primaryDark, fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaUser, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: _primaryDark)),
                          Text("ID: #${item['id_pinjam']}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    _statusBadge(isRiwayat),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 0.6, color: Color(0xFFF1F1F1)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem(Icons.login_rounded, "Pinjam", _fmt(item['pengambilan'])),
                    _infoItem(Icons.logout_rounded, "Kembali", _fmt(item['Pengembalian'])),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tampilkan teks konfirmasi hanya jika bukan di tab riwayat
                if (!isRiwayat)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Konfirmasi Pengembalian", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.blueAccent),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isRiwayat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRiwayat ? const Color(0xFFE8F9EE) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isRiwayat ? "Selesai" : "Mengajukan",
        style: GoogleFonts.poppins(
          color: isRiwayat ? const Color(0xFF28C76F) : const Color(0xFFFFA800),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _primaryDark)),
      ],
    );
  }

  String _fmt(String? d) {
    if (d == null) return "-";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(d).toLocal());
    } catch (e) {
      return "-";
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
  
  // Variabel untuk menyimpan subscription agar bisa dibatalkan saat page ditutup
  RealtimeChannel? _peminjamanSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    _setupRealtimeSubscription(); // Jalankan fungsi sakti ini
  }

  @override
  void dispose() {
    // Hapus subscription saat widget dihancurkan agar tidak memory leak
    if (_peminjamanSubscription != null) {
      supabase.removeChannel(_peminjamanSubscription!);
    }
    _tabController.dispose();
    super.dispose();
  }

  // LOGIKA REALTIME: Mendengarkan perubahan di tabel peminjaman secara langsung
  void _setupRealtimeSubscription() {
    _peminjamanSubscription = supabase
        .channel('public:peminjaman')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Pantau Insert, Update, dan Delete
          schema: 'public',
          table: 'peminjaman',
          callback: (payload) {
            debugPrint('Ada perubahan data: ${payload.toString()}');
            _fetchData(); // Ambil data ulang secara otomatis saat ada perubahan
          },
        )
        .subscribe();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    // Hilangkan isLoading true di sini agar tidak muncul loading terus menerus saat realtime update
    try {
      final proses = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('status_transaksi', 'proses_kembali')
          .order('pengembalian', ascending: false);

      final riwayat = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('status_transaksi', 'selesai')
          .order('pengembalian', ascending: false);

      if (mounted) {
        setState(() {
          _listProses = proses;
          _listRiwayat = riwayat;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tambahkan RefreshIndicator agar bisa ditarik ke bawah (manual refresh)
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFF02182F),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text("Pengembalian", 
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
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
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF02182F),
                tabs: const [
                  Tab(text: "Mengajukan"),
                  Tab(text: "Riwayat")
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _isLoading ? const Center(child: CircularProgressIndicator()) : _buildList(_listProses, isRiwayat: false),
                    _isLoading ? const Center(child: CircularProgressIndicator()) : _buildList(_listRiwayat, isRiwayat: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> data, {required bool isRiwayat}) {
    if (data.isEmpty) {
      return ListView( // Gunakan ListView agar RefreshIndicator tetap bekerja saat kosong
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(child: Text("Tidak ada data pengembalian", style: GoogleFonts.poppins(color: Colors.grey))),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildCard(data[index], isRiwayat),
    );
  }

  Widget _buildCard(dynamic item, bool isRiwayat) {
    final String namaUser = item['peminjam']?['nama'] ?? "User";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
           // Navigasi ke detail pengembalian (akan kita buat nanti)
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isRiwayat ? const Color(0xFF4B4B4B) : const Color(0xFF1ED71E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      isRiwayat ? "Selesai" : "Pengajuan",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCol("Pengambilan", _fmt(item['pengambilan'])),
                  _infoCol("Tenggat", _fmt(item['tenggat'])),
                  Column(
                    children: [
                      Text("Alat", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Lihat detail >", style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCol(String label, String val) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(val, style: GoogleFonts.poppins(fontSize: 10)),
      ],
    );
  }

  String _fmt(String? d) {
    if (d == null) return "-";
    try {
      return DateFormat('dd/MM/yyyy | HH.mm').format(DateTime.parse(d).toLocal());
    } catch (e) {
      return "-";
    }
  }
}
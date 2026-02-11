import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../pinjaman/detail_pinjaman_peminjam.dart';

class PinjamanSayaScreen extends StatefulWidget {
  const PinjamanSayaScreen({super.key});

  @override
  State<PinjamanSayaScreen> createState() => _PinjamanSayaScreenState();
}

class _PinjamanSayaScreenState extends State<PinjamanSayaScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _listPinjaman = [];

  // Variabel Warna Sesuai Request
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _softGrey = const Color(0xFFC9D0D6);
  final Color _mediumGrey = const Color(0xFF8F8E90);

  @override
  void initState() {
    super.initState();
    _fetchMyLoans();
  }

  Future<void> _fetchMyLoans() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('peminjaman')
          .select('*, users!peminjam_id(nama)')
          .eq('peminjam_id', user.id)
          .order('id_pinjam', ascending: false); 

      if (mounted) {
        setState(() {
          _listPinjaman = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Pinjaman: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _getStatusStyle(dynamic item) {
    String statusStr = item['status_transaksi'].toString().toLowerCase();
    DateTime tenggat = DateTime.parse(item['tenggat']);
    DateTime sekarang = DateTime.now();

    if (statusStr == 'aktif' && sekarang.isAfter(tenggat)) {
      return {'label': 'Terlambat', 'color': const Color(0xFFE52121), 'icon': Icons.warning_amber_rounded};
    }

    switch (statusStr) {
      case 'pending':
        return {'label': 'Menunggu', 'color': _primaryDark, 'icon': Icons.hourglass_bottom_rounded};
      case 'aktif':
        return {'label': 'Berjalan', 'color': const Color(0xFF1ED72D), 'icon': Icons.sync_rounded};
      case 'ditolak':
        return {'label': 'Ditolak', 'color': _mediumGrey, 'icon': Icons.cancel_outlined};
      case 'selesai':
        return {'label': 'Selesai', 'color': const Color(0xFF3A7BD5), 'icon': Icons.check_circle_outline};
      default:
        return {'label': statusStr.toUpperCase(), 'color': Colors.orange, 'icon': Icons.info_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aktivitas Saya",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primaryDark,
                        ),
                      ),
                      Text(
                        "Riwayat peminjaman alat Anda",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: _softGrey.withOpacity(0.3),
                    child: Icon(Icons.history_rounded, color: _primaryDark),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari riwayat pinjaman...",
                    hintStyle: GoogleFonts.poppins(color: _mediumGrey, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: _mediumGrey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: _primaryDark))
                : _listPinjaman.isEmpty 
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchMyLoans,
                      color: _primaryDark,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(25, 5, 25, 20),
                        itemCount: _listPinjaman.length,
                        itemBuilder: (context, index) {
                          return _buildAktivitasCard(_listPinjaman[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 70, color: _softGrey),
          const SizedBox(height: 10),
          Text(
            "Belum ada aktivitas",
            style: GoogleFonts.poppins(color: _mediumGrey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasCard(dynamic item) {
    final statusStyle = _getStatusStyle(item);
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(item['pengambilan']));
    String idTampil = item['id_pinjam'].toString().padLeft(4, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPinjamanScreen(idPinjam: item['id_pinjam']))
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _softGrey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            children: [
              // Icon Status Bulat
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusStyle['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusStyle['icon'], color: statusStyle['color'], size: 24),
              ),
              const SizedBox(width: 15),
              
              // Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ID Pinjam #$idTampil",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _mediumGrey,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _mediumGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['users']?['nama'] ?? "User",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusStyle['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusStyle['label'],
                        style: GoogleFonts.poppins(
                          color: statusStyle['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _softGrey),
            ],
          ),
        ),
      ),
    );
  }
}
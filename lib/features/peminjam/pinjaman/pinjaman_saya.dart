import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
// Import file detail pinjaman kamu di sini
import 'detail_pinjaman.dart'; 

class PinjamanSayaScreen extends StatefulWidget {
  const PinjamanSayaScreen({super.key});

  @override
  State<PinjamanSayaScreen> createState() => _PinjamanSayaScreenState();
}

class _PinjamanSayaScreenState extends State<PinjamanSayaScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _listPinjaman = [];

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

      // UPDATE: Mengurutkan berdasarkan id_pinjam terbaru (Descending)
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
      return {'label': 'Terlambat', 'color': const Color(0xFFE52121)};
    }

    switch (statusStr) {
      case 'pending':
        return {'label': 'Pending', 'color': const Color(0xFF02182F)};
      case 'aktif':
        return {'label': 'Aktif', 'color': const Color(0xFF1ED72D)};
      case 'ditolak':
        return {'label': 'Ditolak', 'color': Colors.grey};
      default:
        return {'label': statusStr.toUpperCase(), 'color': Colors.orange};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Aktivitas",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF02182F),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D8E0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _listPinjaman.isEmpty 
                  ? Center(child: Text("Belum ada aktivitas pinjaman", style: GoogleFonts.poppins()))
                  : RefreshIndicator(
                      onRefresh: _fetchMyLoans,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
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

  Widget _buildAktivitasCard(dynamic item) {
    final statusStyle = _getStatusStyle(item);
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(item['pengambilan']));

    // UPDATE: Menambahkan GestureDetector agar card bisa diklik
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPinjamanScreen(idPinjam: item['id_pinjam']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInfoRow("Nama", item['users']?['nama'] ?? "User"),
                  const SizedBox(height: 5),
                  _buildInfoRow("Tanggal", formattedDate),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusStyle['color'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusStyle['label'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF02182F),
            ),
          ),
        ),
        Text(
          ":   $value",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF02182F),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ListRiwayatPengembalian extends StatefulWidget {
  const ListRiwayatPengembalian({super.key});

  @override
  State<ListRiwayatPengembalian> createState() => _ListRiwayatPengembalianState();
}

class _ListRiwayatPengembalianState extends State<ListRiwayatPengembalian> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _listRiwayat = [];
  final Color _primaryDark = const Color(0xFF02182F);

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      setState(() => _isLoading = true);
      final data = await supabase
          .from('peminjaman')
          .select('*, peminjam:users!peminjam_id(nama)')
          .eq('status_transaksi', 'selesai') // HANYA YANG SUDAH SELESAI
          .order('Pengembalian', ascending: false);

      setState(() {
        _listRiwayat = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text("Riwayat Selesai", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: _primaryDark,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _listRiwayat.isEmpty 
          ? Center(child: Text("Belum ada riwayat", style: GoogleFonts.poppins()))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _listRiwayat.length,
              itemBuilder: (context, index) => _buildRiwayatCard(_listRiwayat[index]),
            ),
    );
  }

  Widget _buildRiwayatCard(dynamic item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(item['peminjam']['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text("Selesai pada: ${DateFormat('dd MMM yyyy').format(DateTime.parse(item['Pengembalian']))}"),
        trailing: Text("#${item['id_pinjam']}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ),
    );
  }
}
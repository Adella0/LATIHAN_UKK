import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailDendaPage extends StatefulWidget {
  const DetailDendaPage({super.key});

  @override
  State<DetailDendaPage> createState() => _DetailDendaPageState();
}

class _DetailDendaPageState extends State<DetailDendaPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _listDenda = [];

  @override
  void initState() {
    super.initState();
    _fetchDendaBulanan();
  }

  Future<void> _fetchDendaBulanan() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('denda').select('''
              id_denda,
              total_denda,
              jumlah_terlambat,
              peminjaman:id_kembali (
                users:peminjam_id (
                  nama
                )
              )
            ''');

      if (mounted) {
        setState(() {
          _listDenda = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDenda = 0;
    for (var item in _listDenda) {
      totalDenda += (item['total_denda'] as num? ?? 0).toInt();
    }

    return Scaffold(
      // MENGUBAH BACKGROUND MENJADI PUTIH
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Laporan Denda",
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              // Shadow tipis agar tetap terlihat elegan di background putih
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Text("Total Pendapatan Denda",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(totalDenda),
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listDenda.isEmpty
                    ? const Center(child: Text("Data tidak ditemukan"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _listDenda.length,
                        itemBuilder: (context, index) {
                          final item = _listDenda[index];

                          final String namaUser =
                              item['peminjaman']?['users']?['nama'] ??
                                  "User #${item['id_kembali']}";
                          final int terlambat = item['jumlah_terlambat'] ?? 0;
                          final int nominal =
                              (item['total_denda'] as num? ?? 0).toInt();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: Colors.white, // Card tetap putih
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade100),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                // MENGUBAH AVATAR MENJADI ABU-ABU
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(Icons.person,
                                    color: Colors.grey.shade600),
                              ),
                              title: Text(namaUser,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              subtitle: Text("Terlambat: $terlambat Hari",
                                  style: GoogleFonts.poppins(fontSize: 11)),
                              trailing: Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(nominal),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                    fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
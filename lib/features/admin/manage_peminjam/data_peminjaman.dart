import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../manage_peminjam/detail_peminjaman.dart';

class DataPeminjamScreen extends StatefulWidget {
  const DataPeminjamScreen({super.key});

  @override
  State<DataPeminjamScreen> createState() => _DataPeminjamScreenState();
}

class _DataPeminjamScreenState extends State<DataPeminjamScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> riwayatPeminjaman = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  String selectedCategory = "Riwayat peminjaman";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataPeminjam();
  }

  // --- AMBIL DATA ---
  Future<void> _fetchDataPeminjam() async {
    setState(() => isLoading = true);
    try {
      String statusFilter = selectedCategory == "Riwayat peminjaman" ? "disetujui" : "ditolak";

      final response = await supabase
          .from('peminjaman')
          .select('''
            *,
            users:peminjam_id(nama, role),
            detail_peminjaman!detail_peminjaman_id_pinjam_fkey(
              jumlah,
              alat!detail_peminjaman_id_alat_fkey(
                nama_alat, 
                foto_url,
                kategori(nama_kategori)
              )
            )
          ''')
          .eq('status_transaksi', statusFilter);

      setState(() {
        riwayatPeminjaman = List<Map<String, dynamic>>.from(response);
        filteredData = riwayatPeminjaman;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR_DATABASE_CEK: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      filteredData = riwayatPeminjaman
          .where((item) =>
              item['users']['nama'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteData(dynamic idPinjam) async {
    try {
      await supabase.from('peminjaman').delete().eq('id_pinjam', idPinjam);
      _fetchDataPeminjam();
    } catch (e) {
      debugPrint("Gagal hapus: $e");
    }
  }

  void _showDeleteDialog(dynamic idPinjam) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Hapus?", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text("Apakah kamu yakin menghapus riwayat data tersebut?", 
                textAlign: TextAlign.center, 
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1D8E0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Tidak", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteData(idPinjam);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02182F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Iya", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
            Text(
              "Data peminjam",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF02182F)),
            ),
            const SizedBox(height: 25),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9D0D6).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterSearch,
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    icon: const Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabItem("Riwayat peminjaman"),
                  _buildTabItem("Riwayat ditolak"),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)))
                  : filteredData.isEmpty
                      ? Center(child: Text("Data tidak ditemukan", style: GoogleFonts.poppins()))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) => _buildCardPeminjam(filteredData[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title) {
    bool isActive = selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = title);
        _fetchDataPeminjam();
      },
      child: Column(
        children: [
          Text(title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? const Color(0xFF02182F) : const Color(0xFF6E7C87),
            ),
          ),
          const SizedBox(height: 5),
          if (isActive)
            Container(height: 2.5, width: 100, decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildCardPeminjam(Map<String, dynamic> data) {
    final String nama = data['users']?['nama'] ?? "User";
    final String role = data['users']?['role'] ?? "Peminjam";
    final String status = data['status_transaksi'] ?? "disetujui";

    // --- FUNGSI FORMAT TANGGAL ---
    String formatTanggal(String? rawDate) {
      if (rawDate == null || rawDate == "-") return "-";
      try {
        DateTime dt = DateTime.parse(rawDate);
        String day = dt.day.toString().padLeft(2, '0');
        String month = dt.month.toString().padLeft(2, '0');
        String year = dt.year.toString();
        String hour = dt.hour.toString().padLeft(2, '0');
        String minute = dt.minute.toString().padLeft(2, '0');
        return "$day/$month/$year | $hour.$minute";
      } catch (e) {
        return rawDate;
      }
    }

    String tglPengambilan = formatTanggal(data['pengambilan']);
    String tglTenggat = formatTanggal(data['tenggat']);

    List details = data['detail_peminjaman'] ?? [];
    int totalUnit = 0;
    for (var item in details) {
      totalUnit += (item['jumlah'] as int? ?? 0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20, 
                backgroundColor: Color(0xFF2D3748), 
                child: Icon(Icons.person, color: Colors.white, size: 20)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF02182F))),
                    Text(role, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == "ditolak" ? const Color(0xFFB91C1C) : const Color(0xFF4A4E54),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showDeleteDialog(data['id_pinjam']),
                child: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C), size: 18),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menggunakan Expanded agar teks tanggal tidak overflow (tabrakan)
              Expanded(flex: 4, child: _buildInfoItem("Pengambilan", tglPengambilan)),
              Expanded(flex: 4, child: _buildInfoItem("Tenggat", tglTenggat)),
              Expanded(flex: 2, child: _buildInfoItem("Alat", "$totalUnit Unit")), 
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPeminjamanScreen(data: data)),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Lihat detail", style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue[700], decoration: TextDecoration.underline)),
                  Icon(Icons.chevron_right, size: 14, color: Colors.blue[700]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, 
          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF02182F))
        ),
      ],
    );
  }
}
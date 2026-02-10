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
  List<Map<String, dynamic>> _allDenda = []; 
  List<Map<String, dynamic>> _filteredDenda = []; 
  
  final List<String> _hariNama = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
  
  // Perbaikan: Inisialisasi index agar sesuai dengan hari hari ini
  // Senin = 0, Selasa = 1 ... Minggu = 6
  int _selectedDayIndex = DateTime.now().weekday - 1; 

  @override
  void initState() {
    super.initState();
    _fetchDendaMingguan();
  }

  Future<void> _fetchDendaMingguan() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('denda').select('''
              id_denda,
              total_denda,
              jumlah_terlambat,
              peminjaman:id_kembali (
                Pengembalian, 
                users:peminjam_id (
                  nama
                )
              )
            ''');

      if (mounted) {
        setState(() {
          _allDenda = List<Map<String, dynamic>>.from(response);
          // Langsung jalankan filter untuk hari ini
          _applyFilter(_selectedDayIndex); 
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR FETCH: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(int dayIndex) {
    setState(() {
      _selectedDayIndex = dayIndex;

      // Logika Penentuan Tanggal Target di Minggu Ini
      DateTime sekarang = DateTime.now();
      // Cari tanggal hari Senin di minggu ini
      DateTime awalMingguIni = sekarang.subtract(Duration(days: sekarang.weekday - 1));
      // Tentukan tanggal yang dicari berdasarkan index yang diklik
      DateTime tanggalTarget = awalMingguIni.add(Duration(days: dayIndex));

      _filteredDenda = _allDenda.where((item) {
        final tglRaw = item['peminjaman']?['Pengembalian'];
        if (tglRaw == null) return false;

        try {
          DateTime tglData = DateTime.parse(tglRaw).toLocal();
          
          // PERBAIKAN: Bandingkan Tanggal, Bulan, dan Tahun agar 
          // hanya muncul data di minggu ini saja (bukan Senin bulan lalu)
          return tglData.year == tanggalTarget.year &&
                 tglData.month == tanggalTarget.month &&
                 tglData.day == tanggalTarget.day;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalDendaTerfilter = 0;
    for (var item in _filteredDenda) {
      totalDendaTerfilter += (item['total_denda'] as num? ?? 0).toInt();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Laporan Denda Mingguan",
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildDayFilter(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D1B3E)))
                : _filteredDenda.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 50, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text("Tidak ada denda di hari ${_hariNama[_selectedDayIndex]}", 
                               style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _filteredDenda.length,
                        itemBuilder: (context, index) {
                          final item = _filteredDenda[index];
                          final String namaUser = item['peminjaman']?['users']?['nama'] ?? "User";
                          final int terlambat = item['jumlah_terlambat'] ?? 0;
                          final int nominal = (item['total_denda'] as num? ?? 0).toInt();

                          return _buildDendaCard(namaUser, terlambat, nominal);
                        },
                      ),
          ),
          _buildBottomSummary(totalDendaTerfilter),
        ],
      ),
    );
  }

  Widget _buildDayFilter() {
    int currentWeekday = DateTime.now().weekday; 

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: 7,
        itemBuilder: (context, index) {
          // index 0=Senin, 6=Minggu. currentWeekday 1=Senin, 7=Minggu.
          bool isFuture = (index + 1) > currentWeekday; 
          bool isSelected = _selectedDayIndex == index;

          return GestureDetector(
            onTap: isFuture ? null : () => _applyFilter(index), 
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D1B3E) : (isFuture ? Colors.grey.shade100 : Colors.white),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0D1B3E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_hariNama[index],
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : (isFuture ? Colors.grey.shade400 : Colors.black87))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDendaCard(String nama, int hari, int nominal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0F2F5),
          child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : "?", 
                 style: const TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold)),
        ),
        title: Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Terlambat: $hari Hari", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Text(
          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(nominal),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBottomSummary(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total Denda", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(_hariNama[_selectedDayIndex], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }
}
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
  
  final List<String> _hariNama = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
  final List<String> _hariSingkat = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
  
  int _selectedDayIndex = DateTime.now().weekday - 1; 

  // Variabel Warna Sesuai Request
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _softGrey = const Color(0xFFC9D0D6);
  final Color _mediumGrey = const Color(0xFF8F8E90);
  final Color _accentRed = const Color(0xFFE52121);

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
      DateTime sekarang = DateTime.now();
      DateTime awalMingguIni = sekarang.subtract(Duration(days: sekarang.weekday - 1));
      DateTime tanggalTarget = awalMingguIni.add(Duration(days: dayIndex));

      _filteredDenda = _allDenda.where((item) {
        final tglRaw = item['peminjaman']?['Pengembalian'];
        if (tglRaw == null) return false;
        try {
          DateTime tglData = DateTime.parse(tglRaw).toLocal();
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
      backgroundColor: const Color(0xFFF8FAFC), // Background abu sangat muda agar elemen menonjol
      appBar: AppBar(
        title: Text("Laporan Denda",
            style: GoogleFonts.poppins(color: _primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Text("Pilih Hari", style: GoogleFonts.poppins(color: _mediumGrey, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          _buildDayFilter(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: _primaryDark))
                  : _filteredDenda.isEmpty
                      ? _buildEmptyState()
                      : _buildDendaList(),
            ),
          ),
          _buildBottomSummary(totalDendaTerfilter),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: _softGrey),
          const SizedBox(height: 15),
          Text("Bebas Denda!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark)),
          Text("Tidak ada denda tercatat hari ${_hariSingkat[_selectedDayIndex]}", 
            style: GoogleFonts.poppins(color: _mediumGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDendaList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
      itemCount: _filteredDenda.length,
      itemBuilder: (context, index) {
        final item = _filteredDenda[index];
        final String namaUser = item['peminjaman']?['users']?['nama'] ?? "User";
        final int terlambat = item['jumlah_terlambat'] ?? 0;
        final int nominal = (item['total_denda'] as num? ?? 0).toInt();
        return _buildDendaCard(namaUser, terlambat, nominal);
      },
    );
  }

  Widget _buildDayFilter() {
    int currentWeekday = DateTime.now().weekday; 
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isFuture = (index + 1) > currentWeekday; 
          bool isSelected = _selectedDayIndex == index;

          return GestureDetector(
            onTap: isFuture ? null : () => _applyFilter(index), 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _primaryDark : (isFuture ? Colors.grey.shade50 : Colors.white),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected 
                    ? [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
                    : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
                border: Border.all(color: isSelected ? Colors.transparent : _softGrey.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_hariSingkat[index],
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : (isFuture ? _softGrey : _primaryDark))),
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGrey.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _softGrey.withOpacity(0.2),
            child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : "?", 
                 style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: _primaryDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: _mediumGrey),
                    const SizedBox(width: 4),
                    Text("Terlambat $hari Hari", style: GoogleFonts.poppins(fontSize: 12, color: _mediumGrey)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(nominal),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _accentRed, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 35),
      decoration: BoxDecoration(
        color: _primaryDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total Hari ${_hariNama[_selectedDayIndex]}", style: GoogleFonts.poppins(fontSize: 12, color: _softGrey)),
              const SizedBox(height: 2),
              Text("Akumulasi Denda", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
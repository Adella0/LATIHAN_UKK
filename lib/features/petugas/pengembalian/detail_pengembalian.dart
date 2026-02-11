import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailKonfirmasiKembali extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailKonfirmasiKembali({super.key, required this.data});

  @override
  State<DetailKonfirmasiKembali> createState() => _DetailKonfirmasiKembaliState();
}

class _DetailKonfirmasiKembaliState extends State<DetailKonfirmasiKembali> {
  final supabase = Supabase.instance.client;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;
  late bool _isSelesai;

  final Color _primaryDark = const Color(0xFF02182F);
  final Color _accentBlue = const Color(0xFF3498DB);
  final Color _accentRed = const Color(0xFFE52121);

  @override
  void initState() {
    super.initState();
    _isSelesai = widget.data['status_transaksi'] == 'selesai';
    
    // Inisialisasi waktu dari data atau waktu sekarang
    String? tglKembaliRaw = widget.data['Pengembalian'];
    DateTime initialDate = (tglKembaliRaw != null) 
        ? DateTime.parse(tglKembaliRaw).toLocal() 
        : DateTime.now();

    _selectedDate = initialDate;
    _selectedTime = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
  }

  // Hitung selisih hari berdasarkan kalender (Tenggat vs Pengembalian)
  int get _selisihHari {
    // Jika data denda sudah ada di database (untuk status selesai)
    if (_isSelesai && widget.data['denda'] != null) {
      return widget.data['denda']['jumlah_terlambat'] ?? 0;
    }

    // Ambil tanggal tenggat (sesuai ERD tabel peminjaman)
    DateTime tenggatRaw = DateTime.parse(widget.data['tenggat']).toLocal();
    DateTime tenggatDateOnly = DateTime(tenggatRaw.year, tenggatRaw.month, tenggatRaw.day);
    
    // Ambil tanggal pengembalian inputan
    DateTime kembaliDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (kembaliDateOnly.isAfter(tenggatDateOnly)) {
      return kembaliDateOnly.difference(tenggatDateOnly).inDays;
    }
    return 0;
  }

  // Fungsi Konfirmasi Utama
 Future<void> _konfirmasiSelesai() async {
  setState(() => _isLoading = true);
  try {
    // 1. Ambil waktu pengembalian sesuai pilihan picker
    DateTime tglFix = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _selectedTime.hour, _selectedTime.minute
    );
    
    int hariTerlambat = _selisihHari;
    // Pastikan ID pinjam ada dan dikonversi ke tipe data yang benar (misal: int)
    final int idPinjam = int.parse(widget.data['id_pinjam'].toString());

    // 2. UPDATE TABEL PEMINJAMAN
    await supabase.from('peminjaman').update({
      'status_transaksi': 'selesai',
      'Pengembalian': tglFix.toIso8601String(), // Gunakan ISO8601 agar filter tanggal berfungsi
    }).eq('id_pinjam', idPinjam);

    // 3. INSERT KE TABEL DENDA (Hanya jika terlambat)
    if (hariTerlambat > 0) {
      final insertDenda = {
        'id_kembali': idPinjam, // ID Pinjam masuk sebagai FK
        'jumlah_terlambat': hariTerlambat,
        'tarif_per_hari': 5000,
        // total_denda dikosongkan karena Generated Column
      };
      
      debugPrint("Mencoba Insert Denda: $insertDenda");

      final dendaResponse = await supabase.from('denda').insert(insertDenda).select();
      
      debugPrint("Hasil Insert Denda: $dendaResponse");
    }

    if (mounted) {
      Navigator.pop(context, true); // Kirim 'true' agar halaman sebelumnya refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: hariTerlambat > 0 ? _accentRed : Colors.green,
          content: Text(hariTerlambat > 0 
            ? "Konfirmasi Berhasil! Denda tercatat $hariTerlambat hari." 
            : "Konfirmasi Berhasil! Pengembalian tepat waktu."),
        ),
      );
    }
  } catch (e) {
    debugPrint("ERROR DETAIL: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Simpan: $e"), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    int hari = _selisihHari;
    bool hasDenda = hari > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isSelesai ? "Detail Riwayat" : "Konfirmasi Kembali", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _primaryDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildIdentitasCard(),
            const SizedBox(height: 25),
            _buildDateInfoBox(),
            const SizedBox(height: 30),
            _buildPickerSection(),
            const SizedBox(height: 25),
            
            // BOX INFORMASI TERLAMBAT & DENDA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: hasDenda ? const Color(0xFFFFEBEB) : const Color(0xFFF1F4F8), 
                borderRadius: BorderRadius.circular(12),
                border: hasDenda ? Border.all(color: _accentRed.withOpacity(0.2)) : null,
              ),
              child: Row(
                children: [
                  Icon(hasDenda ? Icons.report_problem_rounded : Icons.check_circle_outline, 
                    color: hasDenda ? _accentRed : Colors.green),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hasDenda ? "Status: Terlambat" : "Status: Tepat Waktu", 
                        style: GoogleFonts.poppins(fontSize: 11, color: hasDenda ? _accentRed : Colors.grey)),
                      Text(hasDenda 
                        ? "Denda: Rp${NumberFormat('#,###').format(hari * 5000)} ($hari Hari)" 
                        : "Tidak ada denda tambahan", 
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: hasDenda ? _accentRed : _primaryDark)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
            if (!_isSelesai) _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildIdentitasCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: _primaryDark.withOpacity(0.1), child: const Icon(Icons.person)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.data['peminjam_id'] ?? "Peminjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text("ID Pinjam: #${widget.data['id_pinjam']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          _statusBadge(),
        ],
      ),
    );
  }

  Widget _buildDateInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dateCol("Pinjam", widget.data['pengambilan']),
          const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 16),
          _dateCol("Tenggat", widget.data['tenggat']),
        ],
      ),
    );
  }

  Widget _dateCol(String title, String? val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        Text(val == null ? "-" : DateFormat('dd MMM yyyy').format(DateTime.parse(val)), 
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPickerSection() {
    return Row(
      children: [
        Expanded(child: _buildTile(DateFormat('dd MMM yyyy').format(_selectedDate), Icons.calendar_month, _pickDate)),
        const SizedBox(width: 12),
        Expanded(child: _buildTile(_selectedTime.format(context), Icons.access_time, _pickTime)),
      ],
    );
  }

  Widget _buildTile(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: _isSelesai ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: _accentBlue), const SizedBox(width: 8), Text(label)]),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: _primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: _isLoading ? null : _konfirmasiSelesai,
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("KONFIRMASI SELESAI", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _isSelesai ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(_isSelesai ? "Selesai" : "Proses", style: GoogleFonts.poppins(fontSize: 10, color: _isSelesai ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _pickDate() async {
    DateTime? p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2024), lastDate: DateTime(2101));
    if (p != null) setState(() => _selectedDate = p);
  }

  Future<void> _pickTime() async {
    TimeOfDay? p = await showTimePicker(context: context, initialTime: _selectedTime);
    if (p != null) setState(() => _selectedTime = p);
  }
}
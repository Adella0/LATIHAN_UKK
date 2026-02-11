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

  @override
  void initState() {
    super.initState();
    // Cek apakah status sudah selesai
    _isSelesai = widget.data['status_transaksi'] == 'selesai';
    
    // Jika sudah selesai, gunakan tanggal pengembalian dari DB. Jika belum, gunakan waktu sekarang.
    String? tglKembaliRaw = widget.data['Pengembalian'];
    DateTime initialDate = (tglKembaliRaw != null) ? DateTime.parse(tglKembaliRaw).toLocal() : DateTime.now();

    _selectedDate = initialDate;
    _selectedTime = TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
  }

  int get _selisihHari {
    // Jika sudah selesai, kita tidak perlu menghitung ulang secara real-time dari picker
    if (_isSelesai) return 0; // Logika denda biasanya sudah tercatat di tabel denda

    DateTime tenggat = DateTime.parse(widget.data['tenggat']).toLocal();
    DateTime tglKembali = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute
    );

    if (tglKembali.isAfter(tenggat)) {
      int diff = tglKembali.difference(tenggat).inDays;
      // Tambah 1 hari jika lewat jam pada hari yang sama atau sisa jam di hari berikutnya
      return diff + (tglKembali.hour > tenggat.hour ? 1 : 0);
    }
    return 0;
  }

  int get _totalDenda => _selisihHari * 5000;

  Future<void> _konfirmasiSelesai() async {
    setState(() => _isLoading = true);
    try {
      DateTime tglFix = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

      await supabase.from('peminjaman').update({
        'status_transaksi': 'selesai',
        'Pengembalian': tglFix.toIso8601String(),
      }).eq('id_pinjam', widget.data['id_pinjam']);

      if (_totalDenda > 0) {
        await supabase.from('denda').insert({
          'id_kembali': widget.data['id_pinjam'],
          'jumlah_terlambat': _selisihHari,
          'tarif_per_hari': 5000,
          'total_denda': _totalDenda,
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengembalian Berhasil Dikonfirmasi")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isSelesai ? "Detail Riwayat" : "Konfirmasi Kembali", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF02182F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama Peminjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            _buildField(widget.data['peminjam']['nama']),
            
            const SizedBox(height: 20),
            _buildDateInfoBox(),

            const SizedBox(height: 25),
            Text("Daftar Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            _buildAlatPlaceholder(), // Tambahkan list alat di sini
            
            const SizedBox(height: 25),
            Text(_isSelesai ? "Tanggal Dikembalikan:" : "Set Tanggal Kembali:", 
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildPickerTile(
                  DateFormat('dd/MM/yyyy').format(_selectedDate), 
                  Icons.calendar_month, 
                  _isSelesai ? null : _pickDate // Jika selesai, onTap null
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildPickerTile(
                  _selectedTime.format(context), 
                  Icons.access_time, 
                  _isSelesai ? null : _pickTime
                )),
              ],
            ),

            if (!_isSelesai) ...[
              const SizedBox(height: 20),
              Text("Estimasi Denda Terlambat:", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
              _buildField(_selisihHari > 0 ? "Rp${NumberFormat('#,###').format(_totalDenda)}" : "Tidak ada denda"),
            ],

            const SizedBox(height: 40),
            
            // Tombol hanya muncul jika belum selesai
            if (!_isSelesai)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _konfirmasiSelesai,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("KONFIRMASI SELESAI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String val) => Container(
    width: double.infinity, padding: const EdgeInsets.all(15), margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
    child: Text(val, style: GoogleFonts.poppins()),
  );

  Widget _buildPickerTile(String label, IconData icon, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: onTap == null ? Colors.grey[100] : Colors.white,
        border: Border.all(color: Colors.grey.shade300), 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(children: [Icon(icon, size: 18, color: Colors.grey[600]), const SizedBox(width: 8), Text(label)]),
    ),
  );

  Widget _buildDateInfoBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dateCol("Pinjam", widget.data['pengambilan']),
          _dateCol("Tenggat", widget.data['tenggat']),
          _dateCol("Status", _isSelesai ? "Selesai" : "Proses", isStatus: true),
        ],
      ),
    );
  }

  Widget _dateCol(String title, String? val, {bool isStatus = false}) => Column(
    children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      Text(
        (val == null || val == "-") ? "-" : (isStatus ? val : DateFormat('dd/MM/yyyy').format(DateTime.parse(val))), 
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)
      ),
    ],
  );

  Widget _buildAlatPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text("ID Transaksi: #${widget.data['id_pinjam']}", style: GoogleFonts.poppins(color: Colors.blueGrey)),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
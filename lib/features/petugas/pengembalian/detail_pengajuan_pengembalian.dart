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
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  // Hitung selisih hari dan denda
  int get _selisihHari {
    DateTime tenggat = DateTime.parse(widget.data['tenggat']).toLocal();
    DateTime tglKembali = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute
    );

    if (tglKembali.isAfter(tenggat)) {
      return tglKembali.difference(tenggat).inDays + (tglKembali.hour > tenggat.hour ? 1 : 0);
    }
    return 0;
  }

  int get _totalDenda => _selisihHari * 5000; // Contoh denda 5rb/hari

  Future<void> _konfirmasiSelesai() async {
    setState(() => _isLoading = true);
    try {
      DateTime tglFix = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

      // 1. Update status peminjaman jadi SELESAI
      await supabase.from('peminjaman').update({
        'status_transaksi': 'selesai',
        'Pengembalian': tglFix.toIso8601String(),
      }).eq('id_pinjam', widget.data['id_pinjam']);

      // 2. Jika ada denda, masukkan ke tabel denda
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
      appBar: AppBar(title: Text("Detail pengembalian", style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            _buildField(widget.data['peminjam']['nama']),
            
            const SizedBox(height: 20),
            _buildDateInfoBox(),

            const SizedBox(height: 25),
            Text("Alat:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            // Disini panggil widget list alat kamu seperti di screen sebelumnya
            
            const SizedBox(height: 25),
            Text("Pengembalian:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: _buildPickerTile(DateFormat('dd/MM/yyyy').format(_selectedDate), Icons.calendar_month, _pickDate)),
                const SizedBox(width: 10),
                Expanded(child: _buildPickerTile(_selectedTime.format(context), Icons.access_time, _pickTime)),
              ],
            ),

            const SizedBox(height: 20),
            Text("Denda terlambat:", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
            _buildField(_selisihHari > 0 ? "Rp${NumberFormat('#,###').format(_totalDenda)}" : "-"),

            const SizedBox(height: 40),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02182F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: _konfirmasiSelesai,
                    child: Text("Konfirmasi pengembalian", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
          ],
        ),
      ),
    );
  }

  // Widget pendukung (Field statis, Box info, dll)
  Widget _buildField(String val) => Container(
    width: double.infinity, padding: const EdgeInsets.all(15), margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
    child: Text(val, style: GoogleFonts.poppins()),
  );

  Widget _buildPickerTile(String label, IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)]),
    ),
  );

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Widget _buildDateInfoBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dateCol("Pengambilan", widget.data['pengambilan']),
          _dateCol("Tenggat", widget.data['tenggat']),
          _dateCol("Pengembalian", "-"),
        ],
      ),
    );
  }

  Widget _dateCol(String title, String? val) => Column(
    children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
      Text(val == "-" ? "-" : DateFormat('dd/MM/yyyy').format(DateTime.parse(val!)), style: GoogleFonts.poppins(fontSize: 10)),
    ],
  );
}
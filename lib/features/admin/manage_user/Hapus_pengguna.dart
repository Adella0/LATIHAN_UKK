import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HapusPenggunaDialog extends StatelessWidget {
  // idUser sekarang String agar cocok dengan UUID di Supabase
  final String idUser; 
  final String nama;

  const HapusPenggunaDialog({
    super.key,
    required this.idUser,
    required this.nama,
  });

  Future<void> _prosesHapus(BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      // Melakukan delete berdasarkan id_user
      // Pastikan ID dikirim sebagai string yang bersih
      await supabase.from('users').delete().eq('id_user', idUser.toString());

      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog setelah berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pengguna '$nama' berhasil dihapus"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Jika gagal (biasanya karena Foreign Key/Data masih dipakai di tabel lain)
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus: Data sedang digunakan di tabel lain"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Konfirmasi Hapus",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Text(
        "Apakah anda yakin ingin menghapus pengguna '$nama'?",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // TOMBOL TIDAK
        SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("Tidak", style: GoogleFonts.poppins()),
          ),
        ),
        // TOMBOL IYA
        SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () => _prosesHapus(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52121),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("Iya", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
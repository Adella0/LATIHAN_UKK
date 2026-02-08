import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HapusPeminjaman {
  static void konfirmasiHapus({
    required BuildContext context,
    required dynamic idPinjam,
    required Function onSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hapus?",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF02182F),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Apakah kamu yakin menghapus riwayat data tersebut?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    // Tombol TIDAK
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD1D8E0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Tidak", 
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF02182F), 
                            fontWeight: FontWeight.w700
                          )
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Tombol IYA
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // Tutup dialog
                          await _eksekusiHapus(idPinjam);
                          onSuccess(); // Panggil fungsi refresh di halaman utama
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02182F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Iya", 
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontWeight: FontWeight.w700
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi internal untuk menghapus ke Database Supabase
  static Future<void> _eksekusiHapus(dynamic idPinjam) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('peminjaman')
          .delete()
          .eq('id_pinjam', idPinjam);
      debugPrint("Data $idPinjam berhasil dihapus dari tabel peminjaman");
    } catch (e) {
      debugPrint("Gagal menghapus data: $e");
    }
  }
}
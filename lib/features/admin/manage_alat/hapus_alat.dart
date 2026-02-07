
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HapusAlatDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const HapusAlatDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        // INI KUNCINYA: Membatasi lebar dialog agar tidak terlalu besar
        constraints: const BoxConstraints(maxWidth: 300), 
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Sesuai dengan isi saja
            children: [
              Text(
                "Hapus?",
                style: GoogleFonts.poppins(
                  fontSize: 20, // Sedikit dikecilkan agar proporsional
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF011931),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Apakah kamu yakin\nmenghapus alat tersebut?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13, // Dikecilkan agar pas
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9D0D6),
                          borderRadius: BorderRadius.circular(15), // Radius disesuaikan
                        ),
                        child: Center(
                          child: Text(
                            "Tidak",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF011931),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF011931),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Iya",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
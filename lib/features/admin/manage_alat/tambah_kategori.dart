import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahKategoriScreen extends StatelessWidget {
  const TambahKategoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Inset padding horizontal diperbesar agar card tidak terlalu lebar kesamping
      insetPadding: const EdgeInsets.symmetric(horizontal: 40), 
      child: Container(
        width: double.infinity,
        // Padding vertikal dikurangi dari 25 menjadi 15 agar lebih pendek
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25), 
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
          mainAxisSize: MainAxisSize.min, // Card akan mengikuti tinggi konten saja
          children: [
            // Handle Bar lebih pendek
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10), // Jarak dikurangi
            Text(
              "Kelola kategori alat",
              style: GoogleFonts.poppins(
                fontSize: 18, // Font diperkecil sedikit
                fontWeight: FontWeight.w700,
                color: const Color(0xFF011931),
              ),
            ),
            const SizedBox(height: 15),

            // Daftar Item Kategori (Jarak margin diperkecil)
           _buildCategoryItem("Elektronik"),
            _buildCategoryItem("Olahraga"),
            _buildCategoryItem("Alat musik"),

            // SPASI KOSONG TAMBAHAN (Sesuai permintaan Anda)
            const SizedBox(height: 35), // Jarak ini memberikan ruang kosong sebelum area input

            // Input Field untuk kategori baru
            TextField(
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Masukkan nama kategori",
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF011931), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Tambah (Padding vertikal dikurangi)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF011931),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF011931).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Tambah kategori",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Margin dikurangi
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Padding lebih tipis
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15, // Ukuran teks dikurangi
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
        ],
      ),
    );
  }
}
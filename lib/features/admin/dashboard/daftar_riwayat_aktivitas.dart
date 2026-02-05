import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarRiwayatAktivitas extends StatelessWidget {
  const DaftarRiwayatAktivitas({super.key});

  // --- FUNGSI POP-UP DETAIL (TETAP SAMA) ---
  void _showActivityDetail(BuildContext context, String nama, String tanggal, String role, Color badgeColor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.12,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF343A40),
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF02182F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tanggal,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF02182F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                "Aktivitas",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF02182F),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  role == "Petugas"
                      ? "Menyetujui peminjaman alat\n1 proyektor"
                      : "Melakukan peminjaman alat\n1 proyektor",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF02182F),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);
    const Color searchGrey = Color(0xFFC9D0D6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Detail aktivitas",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: searchGrey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --- LIST DENGAN DESAIN CARD YANG DISAMAKAN ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 20),
                children: [
                  _buildHistoryCard(context, "Ailen", "12/01/2026", "Petugas"),
                  _buildHistoryCard(context, "Monica", "12/01/2026", "Peminjam"),
                  _buildHistoryCard(context, "Ailen", "12/01/2026", "Petugas"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CARD YANG DISAMAKAN PERSIS DENGAN DASHBOARD ---
  Widget _buildHistoryCard(BuildContext context, String nama, String tanggal, String role) {
    const Color darkBlue = Color(0xFF02182F);
    final Color badgeColor = role == 'Petugas' ? darkBlue : const Color(0xFFADB5BD);

    return GestureDetector(
      onTap: () => _showActivityDetail(context, nama, tanggal, role, badgeColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), // Sesuai dashboard
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInfoRow("Nama", nama, role, badgeColor),
                  const SizedBox(height: 6),
                  _buildInfoRow("Tanggal", tanggal, null, null),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black), // Ikon disamakan
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String? role, Color? badgeColor) {
    return Row(
      children: [
        SizedBox(
          width: 75, // Menjaga titik dua tetap sejajar sesuai dashboard
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF02182F)),
          ),
        ),
        const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF02182F)),
        ),
        if (role != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              role,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ]
      ],
    );
  }
}
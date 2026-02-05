import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailAlatScreen extends StatefulWidget {
  final Map<String, dynamic> alatData; // Data dari card yang dipencet

  const DetailAlatScreen({super.key, required this.alatData});

  @override
  State<DetailAlatScreen> createState() => _DetailAlatScreenState();
}

class _DetailAlatScreenState extends State<DetailAlatScreen> {
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  String? _selectedKategori;

  // List kategori harus sinkron dengan tabel 'kategori' di DB
  final List<String> _kategoriList = ["Elektronik", "Olahraga", "Alat musik", "Umum"];

  @override
  void initState() {
    super.initState();
    // LOGIKA 1: Field otomatis terisi dari tabel 'alat'
    _namaController = TextEditingController(text: widget.alatData['nama_alat']);
    _stokController = TextEditingController(text: widget.alatData['stok_total'].toString());
    
    // LOGIKA: Kategori otomatis terisi sesuai database
    if (_kategoriList.contains(widget.alatData['nama_kategori'])) {
      _selectedKategori = widget.alatData['nama_kategori'];
    }
  }

  // --- FUNGSI UPDATE DATABASE ---
  Future<void> _updateAlat() async {
    // Di sini kamu panggil fungsi Supabase/Provider/API kamu
    // Contoh logic:
    // await supabase.from('alat').update({
    //   'nama_alat': _namaController.text,
    //   'stok_total': int.parse(_stokController.text),
    //   'kategori_id': ... (ambil ID dari kategori terpilih)
    // }).eq('id_alat', widget.alatData['id_alat']);
    
    Navigator.pop(context, true); // Kembali dan refresh list
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF02182F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: darkBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Detail alat",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 45), 
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // BOX GAMBAR (Sesuai Gambar 11499b.png)
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: widget.alatData['foto_url'] != null
                      ? Image.network(widget.alatData['foto_url'], fit: BoxFit.contain)
                      : const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 25),

              // TOMBOL UBAH GAMBAR (Shadow Tebal & Ikon +)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {}, // Logika ganti file gambar
                  icon: const Icon(Icons.add_circle, color: Colors.white, size: 24),
                  label: Text(
                    "Ubah gambar",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BAGIAN FORM (Padding 35 agar tidak terlalu mepet) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Nama"),
                    _buildTextField(_namaController, "Proyektor"),
                    const SizedBox(height: 20),
                    
                    _buildLabel("Stok"),
                    _buildTextField(_stokController, "5", isNumber: true),
                    const SizedBox(height: 20),
                    
                    _buildLabel("Kategori"),
                    _buildDropdown(),
                    const SizedBox(height: 50),

                    // TOMBOL BATAL & SIMPAN
                    Row(
                      children: [
                        Expanded(child: _buildButton("Batal", const Color(0xFFC9D0D6), darkBlue, () => Navigator.pop(context))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildButton("Simpan", darkBlue, Colors.white, _updateAlat)),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black54), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF02182F), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black54),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKategori,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 35),
          items: _kategoriList.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins()))).toList(),
          onChanged: (v) => setState(() => _selectedKategori = v),
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color txt, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: GoogleFonts.poppins(color: txt, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
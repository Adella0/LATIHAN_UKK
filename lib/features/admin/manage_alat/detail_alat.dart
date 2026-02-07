import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailAlatScreen extends StatefulWidget {
  final Map<String, dynamic> alatData;

  const DetailAlatScreen({super.key, required this.alatData});

  @override
  State<DetailAlatScreen> createState() => _DetailAlatScreenState();
}

class _DetailAlatScreenState extends State<DetailAlatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  String? _selectedKategori;
  File? _imageFile; 
  Uint8List? _webImage; 
  bool _isLoading = false;

  // 1. DAFTAR KATEGORI (Pastikan sama persis dengan tabel kategori di DB)
  final List<String> _kategoriList = [
    "Elektronik", 
    "Olahraga", 
    "Alat musik", 
    "bebas", 
    "YYYYY"
  ];

  @override
void initState() {
  super.initState();
  
  _namaController = TextEditingController(text: widget.alatData['nama_alat']?.toString() ?? '');
  _stokController = TextEditingController(text: widget.alatData['stok_total']?.toString() ?? '0');
  
  // Ambil ID Kategori dari database (pasti berupa angka)
  // Berdasarkan gambar database kamu, nama kolomnya adalah 'kategori_id'
  var idKategoriDb = widget.alatData['kategori_id'];

  if (idKategoriDb != null) {
    // Karena id_kategori di database kamu mulai dari 1, 2, 3, 6, 7 (sesuai gambar)
    // Kita harus mencocokkan ID tersebut dengan teks yang benar.
    
    setState(() {
      if (idKategoriDb == 1) _selectedKategori = "Elektronik";
      else if (idKategoriDb == 2) _selectedKategori = "Olahraga";
      else if (idKategoriDb == 3) _selectedKategori = "Alat musik";
      else if (idKategoriDb == 6) _selectedKategori = "bebas";
      else if (idKategoriDb == 7) _selectedKategori = "YYYYY";
    });
  }
  
  debugPrint("DEBUG: ID Kategori dari DB adalah $idKategoriDb, terpilih: $_selectedKategori");
}

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _imageFile = File(pickedFile.path));
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil gambar: $e");
    }
  }

  // 3. PERBAIKAN FUNGSI SIMPAN (UPDATE)
 Future<void> _updateAlat() async {
  setState(() => _isLoading = true);
  
  try {
    // 1. Simpan URL foto yang sudah ada sebagai default
    String? newFotoUrl = widget.alatData['foto_url']; 

    // 2. JIKA ADA GAMBAR BARU, UPLOAD KE BUCKET 'gambar_alat_ukk'
  // JIKA ADA GAMBAR BARU, UPLOAD KE BUCKET 'gambar_alat_ukk'
    if (_imageFile != null || _webImage != null) {
      final fileName = "alat_${DateTime.now().millisecondsSinceEpoch}.jpg";
      
      if (kIsWeb && _webImage != null) {
        // GUNAKAN uploadBinary untuk versi Web
        await supabase.storage.from('gambar_alat_ukk').uploadBinary(fileName, _webImage!);
      } else if (_imageFile != null) {
        // Tetap gunakan upload untuk Mobile
        await supabase.storage.from('gambar_alat_ukk').upload(fileName, _imageFile!);
      }
      
      // Ambil URL publik
      newFotoUrl = supabase.storage.from('gambar_alat_ukk').getPublicUrl(fileName);
    }

    // 3. LOGIKA ID KATEGORI (Tetap seperti sebelumnya)
    int idUntukDb = 1; 
    if (_selectedKategori == "Olahraga") idUntukDb = 2;
    else if (_selectedKategori == "Alat musik") idUntukDb = 3;
    else if (_selectedKategori == "bebas") idUntukDb = 6;
    else if (_selectedKategori == "YYYYY") idUntukDb = 7;

    // 4. UPDATE DATABASE (Sekarang foto_url ikut diupdate)
   // 4. UPDATE DATABASE
    await supabase.from('alat').update({
      'nama_alat': _namaController.text,
      'stok_total': int.tryParse(_stokController.text) ?? 0,
      'kategori_id': idUntukDb,
      'foto_url': newFotoUrl, 
    }).eq('id_alat', widget.alatData['id_alat']);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Berhasil Diperbarui!")),
      );
      // KUNCINYA DI SINI: Harus kirim 'true' agar halaman List tahu ada perubahan
      Navigator.pop(context, true); 
    }
  } catch (e) {
    print("Error Update: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Update: $e")),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF02182F);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: darkBlue))
          : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: darkBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Detail alat",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), 
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- TAMPILAN GAMBAR ---
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _displayImage(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
                label: Text("Ubah gambar", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
              const SizedBox(height: 30),

              // --- FORM INPUT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Nama"),
                    _buildTextField(_namaController, "Nama Alat"),
                    const SizedBox(height: 15),
                    
                    _buildLabel("Stok"),
                    _buildTextField(_stokController, "Jumlah Stok", isNumber: true),
                    const SizedBox(height: 15),
                    
                    _buildLabel("Kategori"),
                    _buildDropdown(),
                    const SizedBox(height: 40),

                    // TOMBOL AKSI
                    Row(
                      children: [
                        Expanded(child: _buildButton("Batal", const Color(0xFFC9D0D6), darkBlue, () => Navigator.pop(context))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildButton("Simpan", darkBlue, Colors.white, _updateAlat)),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle tampilan gambar agar tidak error di Web maupun Mobile
  Widget _displayImage() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && _imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (widget.alatData['foto_url'] != null) {
      return Image.network(widget.alatData['foto_url'], fit: BoxFit.contain, 
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60));
    } else {
      return const Icon(Icons.image, size: 60, color: Colors.grey);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKategori,
          isExpanded: true,
          hint: const Text("Pilih Kategori"),
          items: _kategoriList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _selectedKategori = v),
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color txt, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: txt, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
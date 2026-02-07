
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;

  // Variabel untuk Gambar
  File? _imageFile; // Untuk Mobile
  Uint8List? _webImage; // Untuk Web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final data = await supabase.from('kategori').select();
    setState(() {
      _categories = List<Map<String, dynamic>>.from(data);
    });
  }

  // Fungsi Pilih Gambar
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  // FUNGSI TAMBAH DATA KE DATABASE
  Future<void> _tambahAlat() async {
  if (_namaController.text.isEmpty || _stokController.text.isEmpty || _selectedCategoryId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Harap isi semua data!")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    String? imageUrl;
    // Bagian Upload Gambar (Gunakan try-catch kecil di sini agar jika storage gagal, data tetap masuk)
    try {
      if (_imageFile != null || _webImage != null) {
        final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.jpg';
        if (kIsWeb && _webImage != null) {
          await supabase.storage.from('gambar_alat_ukk').uploadBinary(fileName, _webImage!);
        } else if (_imageFile != null) {
          await supabase.storage.from('gambar_alat_ukk').upload(fileName, _imageFile!);
        }
        imageUrl = supabase.storage.from('gambar_alat_ukk').getPublicUrl(fileName);
      }
    } catch (storageError) {
      print("Storage Error (Abaikan jika tidak pakai upload): $storageError");
    }

    // PROSES INSERT - Pastikan nama kolom sama persis dengan di Gambar ERD
    await supabase.from('alat').insert({
      'nama_alat': _namaController.text,         // Sesuai tabel
      'stok_total': int.parse(_stokController.text), // Sesuai tabel
      'kategori_id': int.parse(_selectedCategoryId!), // Sesuai tabel
      'foto_url': imageUrl,                       // Sesuai tabel
    });

    if (mounted) {
      Navigator.pop(context, true); // Ini akan menutup halaman dan refresh list
    }
  } catch (e) {
    print("DETAIL ERROR: $e"); // Cek ini di Debug Console!
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF02182F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Tambah alat",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF02182F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer penyeimbang tombol back
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    // Image Placeholder
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: _displayImage(),
                          ),
                          const SizedBox(height: 15),
                          // Tombol Tambah Photo
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_circle, size: 20, color: Colors.white),
                              label: Text(
                                "Tambah Photo", 
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF02182F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Form Inputs
                    _buildLabel("Nama"),
                    _buildTextField(_namaController, "Masukkan nama"),
                    
                    const SizedBox(height: 20),
                    _buildLabel("Stok"),
                    _buildTextField(_stokController, "Masukkan stok", isNumber: true),

                    const SizedBox(height: 20),
                    _buildLabel("Kategori"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 28),
                          hint: Text("Pilih kategori", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                          value: _selectedCategoryId,
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['id_kategori'].toString(),
                              child: Text(cat['nama_kategori'], style: GoogleFonts.poppins(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                    // Submit Button
                    Center(
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _tambahAlat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF02182F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                "Tambah",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper Tampilan Gambar
  Widget _displayImage() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.memory(_webImage!, fit: BoxFit.cover));
    } else if (!kIsWeb && _imageFile != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, fit: BoxFit.cover));
    }
    return const Icon(Icons.image_outlined, size: 50, color: Color(0xFF02182F));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold, 
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF02182F), width: 1.5),
        ),
      ),
    );
  }
}
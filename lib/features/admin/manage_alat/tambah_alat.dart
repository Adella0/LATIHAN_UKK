import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  
  String? _selectedKategori;
  List<Map<String, dynamic>> _categories = [];
  
  // Variabel untuk menangani file di Mobile dan Bytes di Web
  File? _imageFile;
  Uint8List? _webImage; 
  
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // Jika di Web, ambil datanya sebagai bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = File(image.path); 
        });
      } else {
        // Jika di Mobile, gunakan File seperti biasa
        setState(() {
          _imageFile = File(image.path);
        });
      }
    }
  }

  Future<void> _simpanAlat() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi foto (cek salah satu)
    if (_imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih foto dulu")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'public/$fileName.png';
      
      // Logika Upload: Gunakan uploadBinary untuk Web
      if (kIsWeb) {
        await supabase.storage.from('gambar_alat_ukk').uploadBinary(path, _webImage!);
      } else {
        await supabase.storage.from('gambar_alat_ukk').upload(path, _imageFile!);
      }

      final String imageUrl = supabase.storage.from('gambar_alat_ukk').getPublicUrl(path);

      await supabase.from('alat').insert({
        'nama_alat': _namaController.text.trim(),
        'stok': int.tryParse(_stokController.text.trim()) ?? 0,
        'foto': imageUrl,
        'kategori_id': _selectedKategori, 
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alat Berhasil Ditambahkan!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF02182F), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Tambah alat",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500, color: const Color(0xFF02182F)),
                      ),
                    ),
                    const SizedBox(width: 40), 
                  ],
                ),
                const SizedBox(height: 40),

                // Frame Foto dengan perbaikan Error Web
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _webImage != null || _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb 
                                ? Image.memory(_webImage!, fit: BoxFit.cover) 
                                : Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Tambah Photo", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: 40),

                _buildLabel("Nama"),
                _buildTextField(_namaController, "Masukkan nama"),

                const SizedBox(height: 20),
                _buildLabel("Stok"),
                _buildTextField(_stokController, "Masukkan stok", isNumber: true),

                const SizedBox(height: 20),
                _buildLabel("Kategori"),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: _inputDecoration("Pilih kategori"),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat['id_kategori'].toString(),
                      child: Text(cat['nama_kategori']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedKategori = val),
                  validator: (value) => value == null ? "Pilih kategori" : null,
                ),

                const SizedBox(height: 50),
                SizedBox(
                  width: 180,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanAlat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02182F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : Text("Tambah", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 5),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class TambahPenggunaDialog extends StatefulWidget {
  const TambahPenggunaDialog({super.key});

  @override
  State<TambahPenggunaDialog> createState() => _TambahPenggunaDialogState();
}

class _TambahPenggunaDialogState extends State<TambahPenggunaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

 Future<void> _tambahPengguna() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // KITA TIDAK PAKAI supabase.auth.signUp agar Admin tidak Logout.
    // Kita langsung simpan ke tabel 'users'.
    
    await supabase.from('users').insert({
      // Karena tidak lewat Auth, kita buat ID unik sementara (misal: pakai timestamp)
      // ATAU biarkan database yang meng-generate ID-nya.
      'nama': _namaController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(), // Simpan teks biasa (Hanya untuk latihan/tugas)
      'role': _selectedRole?.toLowerCase(),
    });

    if (mounted) {
      Navigator.pop(context); // Tutup dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User berhasil ditambahkan ke list!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("DETAIL ERROR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal Simpan: $e"), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GARIS HANDLE ATAS (Sesuai Desain Figma)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Tambah Pengguna",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF02182F),
                  ),
                ),
                const SizedBox(height: 25),
                
                _buildInput("Nama", _namaController, false, "Masukkan Nama"),
                _buildInput("Email", _emailController, false, "Masukkan Email"),
                _buildInput("Password", _passwordController, true, "Masukkan Password"),
                _buildDropdown(),

                const SizedBox(height: 35),
                
                // TOMBOL TAMBAH
                ElevatedButton(
                  onPressed: _isLoading ? null : _tambahPengguna,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    minimumSize: const Size(160, 48),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Tambah",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isPass, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black38, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF02182F), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "$label wajib diisi";
            if (isPass && value.length < 6) return "Minimal 6 karakter";
            return null;
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sebagai",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black38, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF02182F), width: 1.5),
            ),
          ),
          hint: Text("Pilih role", style: GoogleFonts.poppins(color: Colors.black26, fontSize: 13)),
          items: ["Admin", "Petugas", "Peminjam"].map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRole = val),
          validator: (val) => val == null ? "Pilih role" : null,
        ),
      ],
    );
  }
}
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

  // FUNGSI SIMPAN AKUN YANG SUDAH DIPERBAIKI
  Future<void> _simpanAkun() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Daftarkan di Auth Supabase
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        // Metadata opsional agar nama tersimpan juga di sistem Auth
        data: {'nama': _namaController.text.trim()}, 
      );

      final String? idOtomatis = response.user?.id;

      if (idOtomatis != null) {
        // 2. Masukkan ke tabel 'users' di public schema
        await supabase.from('users').insert({
          'id_user': idOtomatis, // ID dari Auth
          'nama': _namaController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole?.toLowerCase(), // Mengambil role dari dropdown
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pengguna Berhasil Ditambahkan")),
          );
          Navigator.pop(context, true); // Tutup dialog dan beri sinyal refresh
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan sistem"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _simpanAkun, // Pastikan memanggil _simpanAkun
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    minimumSize: const Size(double.infinity, 48), // Dibuat full width agar lebih rapi
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

  // Widget _buildInput dan _buildDropdown tetap sama seperti milikmu
  Widget _buildInput(String label, TextEditingController controller, bool isPass, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
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
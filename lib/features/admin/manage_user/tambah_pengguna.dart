import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahPenggunaDialog extends StatefulWidget {
  const TambahPenggunaDialog({super.key});

  @override
  State<TambahPenggunaDialog> createState() => _TambahPenggunaDialogState();
}

class _TambahPenggunaDialogState extends State<TambahPenggunaDialog> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi
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
    // 1. Membersihkan input dari spasi liar
    final emailClean = _emailController.text.trim();
    final passwordClean = _passwordController.text.trim();
    final namaClean = _namaController.text.trim();

    // 2. Mendaftarkan ke Supabase Auth
    final AuthResponse res = await supabase.auth.signUp(
      email: emailClean,
      password: passwordClean,
    );

    final String? newUserId = res.user?.id;

    if (newUserId != null) {
      // 3. Masukkan ke Tabel Publik 'users'
      // Gunakan UPSERT agar jika ID sudah ada, dia hanya mengupdate (mencegah Duplicate Key Error)
      await supabase.from('users').upsert({
        'id_user': newUserId,
        'nama': namaClean,
        'email': emailClean,
        'role': _selectedRole,
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengguna Berhasil Ditambahkan dan Sinkron!")),
        );
      }
    }
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal Auth: ${e.message}")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal Database: $e")),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey, // Pasang form key di sini
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Tambah Pengguna", 
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
                const SizedBox(height: 25),
                
                _buildInput("Nama", _namaController, false),
                _buildInput("Email", _emailController, false),
                _buildInput("Password", _passwordController, true),

                const SizedBox(height: 10),
                _buildDropdown(),

                const SizedBox(height: 35),
                // Tombol Simpan
                ElevatedButton(
                  onPressed: _isLoading ? null : _tambahPengguna,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    minimumSize: const Size(150, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Tambah", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isPass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          decoration: InputDecoration(
            hintText: "Masukkan $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          // VALIDATOR: Ini yang membuat error muncul di bawah field
          validator: (value) {
            if (value == null || value.isEmpty) return "$label tidak boleh kosong";
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
        Text("Sebagai", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          hint: const Text("Pilih role"),
          items: ["Admin", "Petugas", "Peminjam"].map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
          onChanged: (val) => setState(() => _selectedRole = val),
          validator: (val) => val == null ? "Pilih role" : null,
        ),
      ],
    );
  }
}
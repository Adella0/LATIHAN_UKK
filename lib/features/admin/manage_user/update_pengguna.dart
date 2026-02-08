import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePenggunaDialog extends StatefulWidget {
  final Map<String, dynamic> user;

  const UpdatePenggunaDialog({super.key, required this.user});

  @override
  State<UpdatePenggunaDialog> createState() => _UpdatePenggunaDialogState();
}

class _UpdatePenggunaDialogState extends State<UpdatePenggunaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  bool _isLoading = false;
  late String _initialStars; 
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user['nama']);
    _emailController = TextEditingController(text: widget.user['email']);
    
    // Ambil password dari database (jika ada), kalau tidak ada tampilkan 6 bintang
    String rawPass = widget.user['password']?.toString() ?? "******";
    _initialStars = "*" * rawPass.length; 
    _passwordController = TextEditingController(text: _initialStars);
    
    _selectedRole = _capitalize(widget.user['role']);
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return "Peminjam";
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _updatePengguna() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // 1. SIAPKAN DATA UNTUK UPDATE
      Map<String, dynamic> updateData = {
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole?.toLowerCase(),
      };

      // 2. CEK APAKAH PASSWORD DIGANTI
      // Jika isi controller tidak sama dengan bintang-bintang awal,
      // artinya Admin mengetikkan password baru.
      if (_passwordController.text != _initialStars && _passwordController.text.isNotEmpty) {
        updateData['password'] = _passwordController.text.trim();
      }

      // 3. EKSEKUSI UPDATE KE TABEL 'users'
      // Kita tidak lagi memanggil supabase.auth.updateUser!
      // Jadi password admin yang login TIDAK AKAN TERGANTI.
      await supabase
          .from('users')
          .update(updateData)
          .eq('id_user', widget.user['id_user']); // ID user yang sedang diedit

      if (mounted) {
        Navigator.pop(context, true); // Kirim 'true' agar halaman daftar user tahu ada perubahan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Pengguna Berhasil Diperbarui!"),
            backgroundColor: Color(0xFF02182F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50, height: 4,
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                Text("Update Pengguna",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF02182F))),
                const SizedBox(height: 25),
                
                _buildField("Nama", _namaController),
                _buildField("Email", _emailController),
                _buildPasswordField(), 
                _buildRoleDropdown(),

                const SizedBox(height: 35),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePengguna,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02182F),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Simpan Perubahan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: true, 
          style: GoogleFonts.poppins(fontSize: 13),
          onTap: () {
            // Jika user klik kolom password, langsung bersihkan bintang agar bisa ngetik baru
            if (_passwordController.text == _initialStars) {
              _passwordController.clear();
            }
          },
          decoration: InputDecoration(
            hintText: "Isi untuk ganti password",
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sebagai", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: ["Admin", "Petugas", "Peminjam"].contains(_selectedRole) ? _selectedRole : null,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: ["Admin", "Petugas", "Peminjam"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => _selectedRole = v),
        ),
      ],
    );
  }
}
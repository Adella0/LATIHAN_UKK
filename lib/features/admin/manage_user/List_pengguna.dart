import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../manage_user/tambah_pengguna.dart';
import '../manage_user/Hapus_pengguna.dart';
import '../manage_user/update_pengguna.dart';

class ListPenggunaScreen extends StatefulWidget {
  const ListPenggunaScreen({super.key});

  @override
  State<ListPenggunaScreen> createState() => _ListPenggunaScreenState();
}

class _ListPenggunaScreenState extends State<ListPenggunaScreen> {
  final supabase = Supabase.instance.client;
  String selectedRole = "Petugas"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- HEADER TITLE ---
            Center(
              child: Text(
                "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600, // Lebih Bold sesuai Figma
                  color: const Color(0xFF02182F),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildRoleFilter(),
            const SizedBox(height: 20),
            
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      floatingActionButton: _buildFabCustom(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF2), // Warna abu-abu soft figma
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Cari...",
            hintStyle: GoogleFonts.poppins(color: Colors.black45, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    List<String> roles = ["Admin", "Petugas", "Peminjam"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: roles.map((role) {
          bool isSelected = selectedRole == role;
          return GestureDetector(
            onTap: () => setState(() => selectedRole = role),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF02182F) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFF02182F) : Colors.black26,
                  width: 1,
                ),
              ),
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : const Color(0xFF02182F),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

 Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('users')
          .stream(primaryKey: ['id_user']) // Pastikan di DB namanya 'id_user' (bukan 'id')
          .order('nama'),
      builder: (context, snapshot) {
        // Cek jika ada error dari Stream
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)));
        }

        final allUsers = snapshot.data ?? [];
        
        // Melakukan filter berdasarkan role yang dipilih di UI
        final filteredUsers = allUsers.where((u) => 
          (u['role'] ?? "").toString().toLowerCase() == selectedRole.toLowerCase()
        ).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text("Tidak ada data $selectedRole", 
              style: GoogleFonts.poppins(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(25, 5, 25, 120),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // IKON USER SESUAI FIGMA
          const Icon(Icons.person, size: 30, color: Color(0xFF424242)),
          const SizedBox(width: 15),
          
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user['nama'] ?? "User",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF02182F),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSmallBadge(user['role'] ?? ""),
              ],
            ),
          ),

          // ACTION BUTTONS
          Row(
            children: [
             IconButton(
              onPressed: () async {
                // Tambahkan 'await' sebelum showDialog
                await showDialog(
                  context: context,
                  builder: (context) => HapusPenggunaDialog(
                    idUser: user['id_user'].toString(),
                    nama: user['nama'] ?? "User",
                  ),
                );
                
                // KODE INI PENTING:
                // Setelah dialog Hapus ditutup (Navigator.pop), 
                // baris di bawah ini akan dijalankan dan memicu build ulang.
                setState(() {
                  // Ini akan memaksa StreamBuilder untuk mengecek ulang data terbaru
                });
              },
              icon: const Icon(Icons.delete, color: Color(0xFFE52121), size: 20),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
              IconButton(
              onPressed: () async {
                // Memanggil dialog update sambil mengirim data user saat ini
                await showDialog(
                  context: context,
                  builder: (context) => UpdatePenggunaDialog(user: user),
                );
                // Refresh list setelah dialog ditutup
                setState(() {});
              },
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF02182F), size: 20),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF02182F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toLowerCase(), // Disamakan kecil semua seperti di gambar
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 7, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildFabCustom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10), 
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02182F).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
        ),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.5), 
              builder: (context) => const TambahPenggunaDialog(),
            );
          },
          backgroundColor: const Color(0xFF02182F),
          shape: const CircleBorder(),
          elevation: 0, // Elevation 0 karena sudah pakai Shadow manual di atas
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
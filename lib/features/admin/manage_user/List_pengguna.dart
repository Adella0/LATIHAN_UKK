import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../manage_user/tambah_pengguna.dart';
import '../manage_user/Hapus_pengguna.dart';

class ListPenggunaScreen extends StatefulWidget {
  const ListPenggunaScreen({super.key});

  @override
  State<ListPenggunaScreen> createState() => _ListPenggunaScreenState();
}

class _ListPenggunaScreenState extends State<ListPenggunaScreen> {
  final supabase = Supabase.instance.client;
  String selectedRole = "Petugas"; // Default filter sesuai gambar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // --- HEADER ---
            Center(
              child: Text(
                "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF02182F),
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            _buildSearchBar(),
            const SizedBox(height: 25),
            _buildRoleFilter(),
            const SizedBox(height: 15),
            
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
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari...",
          hintStyle: GoogleFonts.poppins(color: Colors.black54),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: const Color(0xFFC9D0D6).withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), 
            borderSide: BorderSide.none
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF02182F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF02182F) : Colors.black45,
                  width: 1,
                ),
              ),
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
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
          .stream(primaryKey: ['id_user'])
          .order('nama'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final allUsers = snapshot.data ?? [];
        
        final filteredUsers = allUsers.where((u) => 
          (u['role'] ?? "").toString().toLowerCase() == selectedRole.toLowerCase()
        ).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("Tidak ada data $selectedRole", 
                  style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 150),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 35, color: Color(0xFF424242)),
          const SizedBox(width: 15),
          
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user['nama'] ?? "User",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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

          Row(
            children: [
              // TOMBOL HAPUS - Memanggil dialog dari file Hapus_pengguna.dart
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>HapusPenggunaDialog(
                    idUser: user['id_user'].toString(), // Tambahkan .toString() untuk jaga-jaga
                    nama: user['nama'] ?? "User",
                  )
                  );
                },
                icon: const Icon(Icons.delete, color: Color(0xFFE52121), size: 22),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // TOMBOL EDIT
              IconButton(
                onPressed: () {
                   // Logika edit bisa ditambahkan di sini nanti
                },
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF02182F), size: 22),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF02182F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 8, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildFabCustom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100, right: 10), 
      child: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.5), 
              builder: (context) => const TambahPenggunaDialog(),
            );
          },
          backgroundColor: const Color(0xFF02182F),
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
    );
  }
}
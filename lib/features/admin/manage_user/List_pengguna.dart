import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../manage_user/tambah_pengguna.dart';

class ListPenggunaScreen extends StatefulWidget {
  const ListPenggunaScreen({super.key});

  @override
  State<ListPenggunaScreen> createState() => _ListPenggunaScreenState();
}

class _ListPenggunaScreenState extends State<ListPenggunaScreen> {
  final supabase = Supabase.instance.client;
  String selectedRole = "Petugas"; // Default filter seperti di gambar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // --- HEADER TENGAH ---
            Center(
              child: Text(
                "Pengguna",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w400, // Lebih tipis sesuai permintaan
                  color: const Color(0xFF02182F),
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            _buildSearchBar(),
            const SizedBox(height: 28),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFC9D0D6).withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    List<String> roles = ["Admin", "Petugas", "Peminjam"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: roles.map((role) {
        bool isSelected = selectedRole == role;
        return GestureDetector(
          onTap: () => setState(() => selectedRole = role),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF02182F) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? const Color(0xFF02182F) : Colors.black45,
              ),
            ),
            child: Text(
              role,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: supabase
          .from('users')
          .stream(primaryKey: ['id_user'])
          .order('nama'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter data berdasarkan role yang dipilih
        final users = snapshot.data!.where((u) => u['role'] == selectedRole).toList();

        if (users.isEmpty) {
          return Center(child: Text("Tidak ada data $selectedRole"));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 100),
          itemCount: users.length,
          itemBuilder: (context, index) => _buildUserCard(users[index]),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 35, color: Colors.black87),
          const SizedBox(width: 15),
          Expanded(
            child: Row(
              children: [
                Text(
                  user['nama'] ?? "User",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02182F),
                  ),
                ),
                const SizedBox(width: 10),
                _buildSmallBadge(user['role'] ?? ""),
              ],
            ),
          ),
          // Ikon Aksi sesuai Gambar (Hapus & Edit)
          Row(
            children: [
              const Icon(Icons.delete, color: Color(0xFFE52121), size: 22),
              const SizedBox(width: 15),
              const Icon(Icons.edit, color: Color(0xFF02182F), size: 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF02182F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

 Widget _buildFabCustom() {
  return Padding(
    // Nilai bottom ditambah agar posisi tombol lebih naik ke atas
    padding: const EdgeInsets.only(bottom: 120, right: 10), 
    child: FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          // barrierColor memberikan efek latar belakang redup (abu-abu transparan)
          barrierColor: Colors.black.withOpacity(0.5), 
          builder: (context) => const TambahPenggunaDialog(),
        );
      },
      backgroundColor: const Color(0xFF02182F),
      elevation: 8,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 35),
    ),
  );
}
}
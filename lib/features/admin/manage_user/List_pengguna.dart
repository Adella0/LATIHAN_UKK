import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/profil.dart';


class ListPenggunaScreen extends StatefulWidget {
  const ListPenggunaScreen({super.key});

  @override
  State<ListPenggunaScreen> createState() => _ListPenggunaScreenState();
}

class _ListPenggunaScreenState extends State<ListPenggunaScreen> {
  final supabase = Supabase.instance.client;
  String userName = "Loading...";
  String userRole = "...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data user yang sedang login untuk Header
  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('users')
            .select('nama, role')
            .eq('id_user', user.id)
            .single();

        setState(() {
          String rawName = userData['nama'] ?? "";
          userName = rawName.isNotEmpty ? rawName : (user.email?.split('@')[0] ?? "User");
          userName = userName[0].toUpperCase() + userName.substring(1);

          String roleRaw = userData['role'] ?? "Admin";
          userRole = roleRaw[0].toUpperCase() + roleRaw.substring(1);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70), // Presisi jarak atas sesuai dashboard
            _buildHeader(),
            const SizedBox(height: 28),
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      floatingActionButton: _buildFabCustom(),
    );
  }

 Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Row(
      children: [
        // TAMBAHKAN GestureDetector DISINI
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilScreen()),
            );
          },
          child: const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF424242),
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $userName!",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              userRole,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6C757D),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    ),
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
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: supabase.from('users').stream(primaryKey: ['id_user']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 100),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserCard(users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Icon(Icons.person, size: 40, color: Color(0xFF424242)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['nama'] ?? "User",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleBadge(user['role'] ?? "Peminjam"),
                  ],
                ),
              ],
            ),
          ),
          // Icon Sampah Merah
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFC62828)),
            onPressed: () {
              // Logika hapus user
            },
          ),
          // Icon Edit Biru Gelap
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF011931)),
            onPressed: () {
              // Logika edit user
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF011931),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFabCustom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10),
      child: FloatingActionButton(
        onPressed: () {
          // Navigasi ke tambah pengguna
        },
        backgroundColor: const Color(0xFF011931),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
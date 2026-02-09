import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPeminjamScreen extends StatefulWidget {
  const DashboardPeminjamScreen({super.key});

  @override
  State<DashboardPeminjamScreen> createState() => _DashboardPeminjamScreenState();
}

class _DashboardPeminjamScreenState extends State<DashboardPeminjamScreen> {
  final supabase = Supabase.instance.client;
  String selectedKategori = "All";
  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int cartCount = 2; // Contoh jumlah unit di keranjang sesuai gambar

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data = await supabase.from('users').select().eq('id_user', user.id).single();
      setState(() => userData = data);
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final catData = await supabase.from('kategori').select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(catData);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            _buildHeader(),
            const SizedBox(height: 25),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategoryList(),
            const SizedBox(height: 10),
            Expanded(child: _buildAlatGrid()),
          ],
        ),
      ),
      floatingActionButton: _buildCartFab(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFBDC3C7),
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${userData?['nama'] ?? 'User'}!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF02182F),
                ),
              ),
              Text(
                userData?['role'] ?? 'Peminjam',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
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
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D8E0), // Abu-abu sedikit kebiruan sesuai gambar
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Cari...",
            hintStyle: GoogleFonts.poppins(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Colors.black87),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          String name = index == 0 ? "All" : (categories[index - 1]['nama_kategori'] ?? "");
          bool isSelected = selectedKategori == name;
          return GestureDetector(
            onTap: () => setState(() => selectedKategori = name),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF02182F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF02182F)),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : const Color(0xFF02182F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlatGrid() {
    return FutureBuilder(
      future: supabase.from('alat').select('*, kategori(nama_kategori)').order('id_alat'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final dataAlat = snapshot.data as List<dynamic>? ?? [];

        final filteredAlat = selectedKategori == "All"
            ? dataAlat
            : dataAlat.where((a) => a['kategori']['nama_kategori'] == selectedKategori).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(25),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: filteredAlat.length,
          itemBuilder: (context, index) => _buildAlatCard(filteredAlat[index]),
        );
      },
    );
  }

  Widget _buildAlatCard(dynamic item) {
    final int stok = item['stok_total'] ?? 0;
    final bool isAvailable = stok > 0;
    final String kategoriName = item['kategori']?['nama_kategori'] ?? "Umum";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: item['foto_url'] != null
                      ? Image.network(item['foto_url'], fit: BoxFit.contain)
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
              _buildCardFooter(item, isAvailable),
            ],
          ),
          // Icon Plus Sesuai Gambar
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () { /* Logika Tambah ke Keranjang */ },
              child: const Icon(Icons.add_circle, color: Color(0xFF02182F), size: 28),
            ),
          ),
          // Label Kategori di pojok kanan atas gambar
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF02182F),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                kategoriName,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(dynamic item, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Stok : $isAvailable unit", style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFF1ED72D) : const Color(0xFFE52121),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isAvailable ? "TERSEDIA" : "KOSONG",
                  style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF02182F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['nama_alat'] ?? "",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFab() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton.extended(
        onPressed: () { /* Navigasi ke Keranjang */ },
        backgroundColor: const Color(0xFF02182F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        label: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Text("($cartCount)unit", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
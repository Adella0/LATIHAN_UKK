import 'package:apk_peminjaman/features/admin/manage_alat/detail_alat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_alat.dart'; 
import 'tambah_kategori.dart'; // Pastikan file ini sudah dibuat

class ListAlatScreen extends StatefulWidget {
  const ListAlatScreen({super.key});

  @override
  State<ListAlatScreen> createState() => _ListAlatScreenState();
}

class _ListAlatScreenState extends State<ListAlatScreen> {
  final supabase = Supabase.instance.client;
  String selectedKategori = "All";
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final catData = await supabase.from('kategori').select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(catData);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryList(),
            Expanded(child: _buildAlatGrid()),
          ],
        ),
      ),
      // --- TOMBOL FLOATING ACTION ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFabCustom(
            icon: Icons.inventory_2_outlined,
            label: "Tambah alat",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahAlatScreen()),
              ).then((value) {
                _fetchInitialData();
              });
            },
          ),
          const SizedBox(height: 15),
          _buildFabCustom(
            icon: Icons.grid_view_rounded,
            label: "Kategori alat",
            onTap: () {
              // Menampilkan Modal Bottom Sheet sesuai permintaan
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, 
                backgroundColor: Colors.transparent, 
                builder: (context) => const TambahKategoriScreen(),
              ).then((_) => _fetchInitialData()); // Refresh data saat modal ditutup
            },
          ),
          const SizedBox(height: 80), 
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK FAB CUSTOM ---
  Widget _buildFabCustom({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF02182F),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          const Icon(Icons.account_circle, size: 60, color: Color(0xFF424242)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, Adella!",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Admin",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
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

  Widget _buildCategoryList() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          String name =
              index == 0 ? "All" : categories[index - 1]['nama_kategori'];
          bool isSelected = selectedKategori == name;

          return GestureDetector(
            onTap: () => setState(() => selectedKategori = name),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF02182F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
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
      future: supabase.from('alat').select(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(child: Text("Tidak ada data alat"));
        }

        final dataAlat = snapshot.data as List<dynamic>;
        final filteredAlat = selectedKategori == "All"
            ? dataAlat
            : dataAlat.where((a) {
                final cat = categories.firstWhere(
                    (c) => c['nama_kategori'] == selectedKategori,
                    orElse: () => {});
                return a['kategori_id'] == cat['id_kategori'];
              }).toList();

        return GridView.builder(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: 100,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: filteredAlat.length,
          itemBuilder: (context, index) {
            return _buildAlatCard(filteredAlat[index]);
          },
        );
      },
    );
  }

 Widget _buildAlatCard(dynamic item) {
  bool isAvailable = item['status_ketersediaan'] == 'Tersedia';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailAlatScreen(alatData: item),
        ),
      ).then((value) => _fetchInitialData());
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Gambar Alat
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 45, 10, 5),
                    child: Center(
                      child: item['foto_url'] != null
                          ? Image.network(item['foto_url'], fit: BoxFit.contain)
                          : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                
                // 2. Baris Stok dan Status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Stok : ${item['stok_total']} unit",
                          style: GoogleFonts.poppins(
                            fontSize: 10, // Disesuaikan agar tidak overflow
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF02182F),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable ? const Color(0xFF1ED72D) : const Color(0xFFE52121),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status_ketersediaan'].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7, 
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 3. Nama Alat (Tombol bawah)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02182F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['nama_alat'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 4. Icon Delete (Pojok Kiri Atas)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF02182F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 14),
              ),
            ),

            // 5. Badge Kategori (Pojok Kanan Atas)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 80), // Membatasi lebar teks kategori
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF02182F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  categories.firstWhere(
                    (c) => c['id_kategori'] == item['kategori_id'],
                    orElse: () => {'nama_kategori': 'Umum'},
                  )['nama_kategori'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
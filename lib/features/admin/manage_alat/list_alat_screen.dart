import 'package:apk_peminjaman/features/admin/manage_alat/detail_alat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_alat.dart'; 
import 'tambah_kategori.dart'; 

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
            // Perbaikan Header agar sama dengan Dashboard
              const SizedBox(height: 6),
            _buildHeader(),
            _buildSearchBar(),
            // Perbaikan Scroll Kategori agar terpotong sesuai margin
            _buildCategoryList(),
            Expanded(child: _buildAlatGrid()),
          ],
        ),
      ),
    floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 5, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildFabCustom(
              icon: Icons.add_box_outlined, // Ikon tambah sesuai gambar
              label: "Tambah alat",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahAlatScreen()),
                ).then((value) => _fetchInitialData());
              },
            ),
            const SizedBox(height: 12), // Jarak antar tombol yang lebih rapat
            _buildFabCustom(
              icon: Icons.grid_view_rounded, // Ikon grid untuk kategori
              label: "Kategori alat",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, 
                  backgroundColor: Colors.transparent, 
                  builder: (context) => const TambahKategoriScreen(),
                ).then((_) => _fetchInitialData());
              },
            ),
            const SizedBox(height: 70), // Jarak dari bottom navbar
          ],
        ),
      ),
    );
  }

  Widget _buildFabCustom({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Ukuran disesuaikan agar pas (tidak terlalu besar)
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF02182F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24), // Ukuran ikon standar
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 8, // Font lebih kecil agar muat dalam lingkaran
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN HEADER (DISAMAKAN DENGAN DASHBOARD) ---
  Widget _buildHeader() {
    return Padding(
      // Padding disamakan dengan dashboard agar jarak ke atas pas
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ukuran CircleAvatar disesuaikan agar sama besarnya dengan dashboard
          const CircleAvatar(
            radius: 30, // Ukuran ini lebih mendekati dashboard Anda
            backgroundColor: Color(0xFF424242),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hi, Admin1!",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800, // Lebih tebal sesuai dashboard
                  fontSize: 22, // Ukuran teks ditingkatkan agar sama
                  color: Colors.black,
                  height: 1.2, // Mengatur kerapatan baris teks
                ),
              ),
              Text(
                "Admin",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400, // Abu-abu lebih muda sesuai dashboard
                  fontSize: 15, 
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
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

  // --- PERBAIKAN LIST KATEGORI (SCROLL TERBATAS MARGIN) ---
 Widget _buildCategoryList() {
  return Container(
    height: 38,
    margin: const EdgeInsets.only(top: 15, bottom: 10),
    // 1. Tambahkan padding horizontal agar ListView sejajar dengan elemen lain
    padding: const EdgeInsets.symmetric(horizontal: 25), 
    child: ClipRect( // 2. Tambahkan ClipRect agar konten yang di-scroll tidak tembus ke margin
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // 3. PENTING: Set padding ListView ke zero karena sudah diatur oleh Container di atasnya
        padding: EdgeInsets.zero, 
        // 4. Atur physics agar scroll terasa lebih halus
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          String name = index == 0 ? "All" : categories[index - 1]['nama_kategori'];
          bool isSelected = selectedKategori == name;

          return GestureDetector(
            onTap: () => setState(() => selectedKategori = name),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF02182F) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? const Color(0xFF02182F) : Colors.black,
                ),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
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
            top: 10,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Stok : ${item['stok_total']} unit",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
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
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 80),
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
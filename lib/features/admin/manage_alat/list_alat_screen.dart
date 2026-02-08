import '../manage_alat/hapus_alat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_alat.dart'; 
import 'tambah_kategori.dart'; 
import '../manage_alat/detail_alat.dart';

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

  Future<void> _prosesHapusAlat(int? idAlat) async {
    if (idAlat == null) return;
    try {
      await supabase.from('alat').delete().eq('id_alat', idAlat);
      await _fetchInitialData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alat berhasil dihapus")),
        );
      }
    } catch (e) {
      debugPrint("Gagal hapus: $e");
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
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 18), // Memberi ruang agar kategori tidak menempel search bar
            _buildCategoryList(),
            const SizedBox(height: 8), // JARAK RAPAT: Antara kategori dan grid alat
            Expanded(child: _buildAlatGrid()),
          ],
        ),
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        "Alat",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF02182F),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(30), // RADIUS BULAT SEMPURNA
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "Cari...",
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, size: 22, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Padding(
      // Memberikan padding kiri-kanan agar sejajar dengan Search Bar
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // Hilangkan padding internal agar mepet ke sisi padding induk
          padding: EdgeInsets.zero, 
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            String name = index == 0 ? "All" : (categories[index - 1]['nama_kategori'] ?? "");
            bool isSelected = selectedKategori == name;

            return GestureDetector(
              onTap: () => setState(() => selectedKategori = name),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF02182F) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF02182F),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : const Color(0xFF02182F),
                    fontSize: 12,
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
      future: supabase.from('alat').select().order('id_alat', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final dataAlat = snapshot.data as List<dynamic>? ?? [];
        
        final filteredAlat = selectedKategori == "All"
            ? dataAlat
            : dataAlat.where((a) {
                final cat = categories.firstWhere((c) => c['nama_kategori'] == selectedKategori, orElse: () => {'id_kategori': null});
                return a['kategori_id'] == cat['id_kategori'];
              }).toList();

        return GridView.builder(
          key: UniqueKey(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85, // Sesuai proporsi card Figma
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
    // Logika: Jika stok > 0 maka true (Tersedia), jika 0 maka false (Kosong)
    final int stok = item['stok_total'] ?? 0;
    final bool isAvailable = stok > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailAlatScreen(alatData: item)));
              if (result == true) setState(() {});
            },
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: item['foto_url'] != null
                        ? Image.network(item['foto_url'], fit: BoxFit.contain)
                        : const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                  ),
                ),
                // Kirim status isAvailable hasil perhitungan stok
                _buildCardFooter(item, isAvailable),
              ],
            ),
          ),
          Positioned(
            top: 10, left: 10,
            child: GestureDetector(
              onTap: () => showDialog(context: context, builder: (c) => HapusAlatDialog(onConfirm: () => _prosesHapusAlat(item['id_alat']))),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF02182F), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(dynamic item, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Stok: ${item['stok_total']} unit", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFF1ED72D) : const Color(0xFFE52121),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isAvailable ? "TERSEDIA" : "KOSONG", 
                  style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item['nama_alat'] ?? "", 
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenu() {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFabCustom(
            icon: Icons.grid_view_rounded, 
            label: "Tambah alat",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahAlatScreen())).then((v) => _fetchInitialData()),
          ),
          const SizedBox(height: 12),
          _buildFabCustom(
            icon: Icons.widgets_rounded, 
            label: "Kategori alat",
            onTap: () => showDialog(context: context, builder: (c) => const TambahKategoriScreen()).then((v) => _fetchInitialData()),
          ),
        ],
      ),
    );
  }

  Widget _buildFabCustom({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62, height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFF02182F), 
          shape: BoxShape.circle, 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
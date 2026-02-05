import 'package:apk_peminjaman/features/admin/manage_alat/detail_alat.dart';
import 'package:apk_peminjaman/features/admin/manage_alat/hapus_alat.dart';
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

  String userName = "Loading...";
  String userRole = "...";

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _loadUserData();
  }

  Future<void> _hapusDataAlat(int id) async {
    try {
      await supabase.from('alat').delete().eq('id_alat', id);
      _fetchInitialData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alat berhasil dihapus")),
        );
      }
    } catch (e) {
      debugPrint("Error hapus data: $e");
    }
  }

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
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
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
      debugPrint("Error fetching data: $e");
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
            const SizedBox(height: 40), 
            _buildHeader(),
            const SizedBox(height: 28),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryList(),
            Expanded(child: _buildAlatGrid()),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildFabCustom(
              icon: Icons.grid_view_rounded, 
              label: "Tambah alat",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahAlatScreen()),
                ).then((value) => _fetchInitialData());
              },
            ),
            const SizedBox(height: 12),
            _buildFabCustom(
              icon: Icons.widgets_rounded, 
              label: "Kategori alat",
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true, 
                  builder: (BuildContext context) => const TambahKategoriScreen(),
                ).then((value) => _fetchInitialData());
              },
            ),
            const SizedBox(height: 100), // Memberi ruang agar tidak tertutup Navbar
          ],
        ),
      ),
    );
  }

 Widget _buildHeader() {
    return Center( // Menggunakan Center agar judul berada tepat di tengah sesuai gambar
      child: Text(
        "Alat",
        style: GoogleFonts.poppins(
          fontSize: 24, // Ukuran font lebih besar untuk judul utama
          fontWeight: FontWeight.w400,
          color: const Color(0xFF02182F),
        ),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 15, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          String name = index == 0 ? "All" : (categories[index - 1]['nama_kategori'] ?? "Uncategorized");
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
                border: Border.all(color: isSelected ? const Color(0xFF02182F) : Colors.black),
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
    );
  }

  Widget _buildAlatGrid() {
    return FutureBuilder(
      future: supabase.from('alat').select(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) return const Center(child: Text("Tidak ada data alat"));

        final dataAlat = snapshot.data as List<dynamic>;
        final filteredAlat = selectedKategori == "All"
            ? dataAlat
            : dataAlat.where((a) {
                final cat = categories.firstWhere((c) => c['nama_kategori'] == selectedKategori, orElse: () => {});
                return a['kategori_id'] == cat['id_kategori'];
              }).toList();

        return GridView.builder(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 100, top: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
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
    bool isAvailable = item['status_ketersediaan'] == 'Tersedia';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailAlatScreen(alatData: item)),
        ).then((value) => _fetchInitialData());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
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
                  _buildCardFooter(item, isAvailable),
                ],
              ),
              Positioned(
                top: 8, left: 8,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => HapusAlatDialog(
                        onConfirm: () => _hapusDataAlat(item['id_alat']),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Color(0xFF02182F), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                  ),
                ),
              ),
              _buildCategoryBadge(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFooter(dynamic item, bool isAvailable) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(child: Text("Stok : ${item['stok_total'] ?? 0} unit", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF02182F)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: isAvailable ? const Color(0xFF1ED72D) : const Color(0xFFE52121), borderRadius: BorderRadius.circular(6)),
                // PERBAIKAN: Tambahkan Null Check sebelum toUpperCase()
                child: Text((item['status_ketersediaan'] ?? "Kosong").toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(10)),
            // PERBAIKAN: Tambahkan Null Check untuk nama alat
            child: Text(item['nama_alat'] ?? "Tanpa Nama", textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(dynamic item) {
    return Positioned(
      top: 8, right: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(12)),
        child: Text(
          categories.firstWhere((c) => c['id_kategori'] == item['kategori_id'], orElse: () => {'nama_kategori': 'Umum'})['nama_kategori'] ?? 'Umum',
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFabCustom({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65, height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF02182F), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, height: 1)),
          ],
        ),
      ),
    );
  }
}
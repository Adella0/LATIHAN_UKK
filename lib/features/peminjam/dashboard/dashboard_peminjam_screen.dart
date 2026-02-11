import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../dashboard/keranjang.dart';
import '../ui/profil.dart';

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

  // Variabel Warna
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _accentGreen = const Color(0xFF1ED72D);
  final Color _errorRed = const Color(0xFFE52121);
  final Color _bgLight = const Color(0xFFF4F7FA);

  Map<int, int> cartItems = {};
  late Future<List<dynamic>> _alatFuture;

  int get cartCount {
    int total = 0;
    cartItems.forEach((id, qty) => total += qty);
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchInitialData();
    _alatFuture = _getAlatData();
  }

  Future<List<dynamic>> _getAlatData() async {
    final data = await supabase.from('alat').select('*, kategori(nama_kategori)').order('id_alat');
    return data as List<dynamic>;
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase.from('users').select().eq('id_user', user.id).maybeSingle();
        if (data != null) setState(() => userData = data);
      } catch (e) {
        debugPrint("Error loading user data: $e");
      }
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

  void _addToCart(int idAlat, int stokMaksimal) {
    int currentQty = cartItems[idAlat] ?? 0;
    if (currentQty < stokMaksimal) {
      setState(() {
        cartItems[idAlat] = currentQty + 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil menambah 1 unit", style: GoogleFonts.poppins(fontSize: 12)),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Batas stok tercapai"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
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
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilScreen())),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF424242),
                child: Icon(Icons.person_rounded, size: 35, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${userData?['nama'] ?? 'User'}!",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark),
              ),
              Text(
                userData?['role'] ?? 'Peminjam',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
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
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Cari alat praktikum...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _primaryDark),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          String name = index == 0 ? "All" : (categories[index - 1]['nama_kategori'] ?? "");
          bool isSelected = selectedKategori == name;
          return GestureDetector(
            onTap: () => setState(() => selectedKategori = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected ? [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                border: Border.all(color: isSelected ? _primaryDark : Colors.transparent),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : _primaryDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      future: _alatFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _primaryDark));
        final dataAlat = snapshot.data as List<dynamic>? ?? [];
        final filteredAlat = selectedKategori == "All"
            ? dataAlat
            : dataAlat.where((a) => a['kategori']['nama_kategori'] == selectedKategori).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(25),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
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
    final int countInCart = cartItems[item['id_alat']] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: item['foto_url'] != null
                        ? Image.network(item['foto_url'], fit: BoxFit.contain)
                        : Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey[300]),
                  ),
                ),
              ),
              _buildCardFooter(item, isAvailable),
            ],
          ),
          // Icon Plus dengan Badge (Struktur Kamu)
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: () => _addToCart(item['id_alat'], stok),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      Icons.add_circle,
                      color: countInCart > 0 ? _accentGreen : _primaryDark,
                      size: 32,
                    ),
                  ),
                  if (countInCart > 0)
                    Transform.translate(
                      offset: const Offset(2, -2),
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(countInCart.toString(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Label Kategori (Pojok Kanan Atas)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kategoriName,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(dynamic item, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Stok: ${item['stok_total']}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAvailable ? _accentGreen.withOpacity(0.15) : _errorRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAvailable ? "TERSEDIA" : "KOSONG",
                  style: TextStyle(color: isAvailable ? _accentGreen : _errorRed, fontSize: 7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _primaryDark,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: Text(
              item['nama_alat'] ?? "",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFab() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KeranjangScreen(),
            settings: RouteSettings(arguments: cartItems),
          ),
        );
        if (result != null && result is Map<int, int>) {
          setState(() {
            cartItems = result;
          });
        }
      },
      backgroundColor: _primaryDark,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            "$cartCount Unit",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
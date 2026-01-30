import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPeminjamScreen extends StatefulWidget {
  const DashboardPeminjamScreen({super.key});

  @override
  State<DashboardPeminjamScreen> createState() => _DashboardPeminjamScreenState();
}

class _DashboardPeminjamScreenState extends State<DashboardPeminjamScreen> {
  String userName = "Loading...";
  String selectedCategory = "All";
  int cartCount = 0;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> categories = ["All", "Elektronik", "Olahraga", "Alat musik", "Umum"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('users')
          .select('nama_lengkap')
          .eq('id_user', user.id)
          .single();
      setState(() {
        userName = data['nama_lengkap'] ?? "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF02182F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header Profile
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFF424242),
                        child: Icon(Icons.person, size: 45, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hi, $userName!", 
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Peminjam", 
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E0E6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        hintStyle: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedCategory == categories[index];
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = categories[index]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? (categories[index] == "All" ? primaryBlue : const Color(0xFFC9D0D6))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.black26),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
                                style: GoogleFonts.poppins(
                                  color: isSelected && categories[index] == "All" ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Grid Alat
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75,
                    children: [
                      _buildToolCard("Proyektor", "Elektronik", "5", "TERSEDIA", true),
                      _buildToolCard("Gitar", "Alat musik", "0", "KOSONG", false),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Floating Cart Button
            Positioned(
              bottom: 110,
              right: 0,
              child: GestureDetector(
                onTap: () { /* Navigasi ke Keranjang */ },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text("($cartCount)unit", 
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(primaryBlue),
    );
  }

  Widget _buildToolCard(String name, String cat, String stock, String status, bool isAvailable) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),
              // Tombol Tambah [+]
              Positioned(
                top: 10, left: 10,
                child: GestureDetector(
                  onTap: () => setState(() => cartCount++),
                  child: const CircleAvatar(
                    radius: 12, backgroundColor: Color(0xFF02182F),
                    child: Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ),
              // Label Kategori
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(5)),
                  child: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stok : $stock unit", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color blue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      height: 70,
      decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(35)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Dashboard", true),
          _buildNavItem(Icons.shopping_cart_outlined, "Pinjaman saya", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 9)),
        if (isActive) Container(margin: const EdgeInsets.only(top: 4), height: 2, width: 20, color: Colors.white),
      ],
    );
  }
}
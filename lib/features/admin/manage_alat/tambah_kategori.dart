import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahKategoriScreen extends StatefulWidget {
  const TambahKategoriScreen({super.key});

  @override
  State<TambahKategoriScreen> createState() => _TambahKategoriScreenState();
}

class _TambahKategoriScreenState extends State<TambahKategoriScreen> {
  final TextEditingController _kategoriController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Ambil data saat dialog dibuka
  }

  // --- LOGIKA: AMBIL DATA DARI DATABASE ---
  Future<void> _fetchCategories() async {
    try {
      final data = await supabase
          .from('kategori')
          .select()
          .order('nama_kategori', ascending: true);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Error fetching: $e");
    }
  }

  // --- LOGIKA: SIMPAN KE DATABASE ---
  Future<void> _tambahKategori() async {
    final namaKategori = _kategoriController.text.trim();

    if (namaKategori.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await supabase.from('kategori').insert({
        'nama_kategori': namaKategori,
      });

      _kategoriController.clear(); // Kosongkan input
      _fetchCategories(); // Refresh list agar kategori baru muncul di atas
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kategori berhasil ditambahkan!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambah kategori: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA: HAPUS KATEGORI ---
  Future<void> _hapusKategori(int id) async {
    try {
      await supabase.from('kategori').delete().eq('id_kategori', id);
      _fetchCategories(); // Refresh list
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

 @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: double.infinity,
        // --- KUNCI: Tentukan tinggi tetap di sini agar tidak goyang ---
        height: 500, 
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          // Gunakan MainAxisSize.max karena kita sudah tentukan tinggi container
          mainAxisSize: MainAxisSize.max, 
          children: [
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Kelola kategori alat",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF011931),
              ),
            ),
            const SizedBox(height: 15),

            // --- AREA LIST: Dibuat Expanded agar mengambil sisa ruang yang ada ---
            Expanded(
              child: _categories.isEmpty
                  ? Center(
                      child: Text("Belum ada kategori", 
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    )
                  : ListView.builder(
                      // shrinkWrap false karena sudah dibungkus Expanded
                      shrinkWrap: false,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final item = _categories[index];
                        return _buildCategoryItem(
                          item['nama_kategori'], 
                          item['id_kategori']
                        );
                      },
                    ),
            ),

            const SizedBox(height: 15),
            const Divider(), // Garis pembatas tipis agar lebih rapi
            const SizedBox(height: 15),

            // Input Field (Posisinya sekarang akan selalu tetap di bawah)
            TextField(
              controller: _kategoriController,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Nama kategori baru...",
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF011931), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Tombol Tambah
            GestureDetector(
              onTap: _isLoading ? null : _tambahKategori,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF011931),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Tambah kategori",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _hapusKategori(id),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
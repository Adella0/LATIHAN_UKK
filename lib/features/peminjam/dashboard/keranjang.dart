import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();
  
  // Data Tanggal & Waktu
  DateTime? tglPengambilan;
  DateTime? tglTenggat;
  TimeOfDay? waktuPengambilan;
  TimeOfDay? waktuTenggat;

  Map<int, int> cartItems = {};
  List<dynamic> detailAlat = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil argumen cartItems dari halaman sebelumnya
    final args = ModalRoute.of(context)?.settings.arguments as Map<int, int>?;
    if (args != null && cartItems.isEmpty) {
      cartItems = Map.from(args);
      _fetchDetailAlat();
    }
  }

  // Fungsi mengambil detail alat dari DB berdasarkan ID di keranjang
 // Fungsi mengambil detail alat dari DB berdasarkan ID di keranjang
 Future<void> _fetchDetailAlat() async {
    try {
      final ids = cartItems.keys.toList();
      
      if (ids.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Gunakan .filter('id_alat', 'in', ids) sebagai alternatif jika .in_ bermasalah
      final data = await supabase
          .from('alat')
          .select('*, kategori(nama_kategori)')
          .filter('id_alat', 'in', ids); // Cara alternatif yang lebih stabil

      setState(() {
        detailAlat = data as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Fetch Detail: $e");
      setState(() => isLoading = false); // Agar loading berhenti jika error
    }
  }

  // Hitung total unit otomatis (Poin 2)
  int get totalUnit {
    int total = 0;
    cartItems.forEach((_, qty) => total += qty);
    return total;
  }

  // Fungsi Hapus Item (Poin 3)
  void _removeItem(int idAlat) {
  setState(() {
    // 1. Hapus dari Map cartItems (Data utama)
    cartItems.remove(idAlat);
    
    // 2. Hapus dari list detailAlat (Data tampilan gambar/nama)
    detailAlat.removeWhere((element) => element['id_alat'] == idAlat);
  });

  // Opsional: Pesan sukses
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Alat dihapus dari keranjang"), duration: Duration(milliseconds: 500)),
  );
}
  // Fungsi Pengajuan (Poin 5 & 6)
  Future<void> _ajukanPinjaman() async {
    if (_namaController.text.isEmpty || tglPengambilan == null || tglTenggat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data!")),
      );
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      
      // Simpan ke tabel peminjaman dengan status 'pending'
      final response = await supabase.from('peminjaman').insert({
        'id_user': user?.id,
        'nama_peminjam': _namaController.text,
        'tgl_pinjam': tglPengambilan!.toIso8601String(),
        'tgl_kembali': tglTenggat!.toIso8601String(),
        'status': 'pending',
        'total_item': totalUnit,
      }).select().single();

      // Logika simpan detail_peminjaman bisa ditambahkan di sini loop cartItems

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil! Menunggu konfirmasi petugas")),
      );
      Navigator.pop(context); // Kembali ke dashboard
    } catch (e) {
      debugPrint("Error simpan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          // KIRIM BALIK data cartItems terbaru ke Dashboard
          Navigator.pop(context, cartItems);
        },
      ),
      title: const Text("Form Pengajuan"
      ),
    ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Nama"),
                _buildTextField(_namaController, "Nama Lengkap"), // Poin 1

                const SizedBox(height: 15),
                _buildLabel("Jumlah"),
                _buildTextField(TextEditingController(text: totalUnit.toString()), "", enabled: false), // Poin 2

                const SizedBox(height: 20),
                _buildDateTimeSection(), // Poin 3

                const SizedBox(height: 25),
                _buildLabel("Alat:"),
                ...detailAlat.map((item) => _buildItemCard(item)).toList(), // Poin 3 (Card)

                const SizedBox(height: 15),
                // Tombol Tambah Alat (Poin 4)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, cartItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02182F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Tambah alat", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 40),
                // Tombol Ajukan (Poin 5)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _ajukanPinjaman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02182F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Ajukan pinjaman", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildDateColumn("Pengambilan", tglPengambilan, (val) => setState(() => tglPengambilan = val)),
          const VerticalDivider(),
          _buildDateColumn("Tenggat", tglTenggat, (val) => setState(() => tglTenggat = val)),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime? date, Function(DateTime) onSelect) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Tanggal: ", style: const TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: const Color(0xFF02182F), borderRadius: BorderRadius.circular(5)),
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8)),
              )
            ],
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
              if (picked != null) onSelect(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16),
                  const SizedBox(width: 5),
                  Text(date == null ? "Tgl/Bln/Thn" : DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    int id = item['id_alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Image.network(item['foto_url'], width: 60, height: 60, fit: BoxFit.contain),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_alat'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item['kategori']['nama_kategori'], style: const TextStyle(fontSize: 10, color: Colors.blue)),
              ],
            ),
          ),
          Text("(${cartItems[id]}) unit", style: const TextStyle(fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeItem(id), // Poin 3 (Icon Sampah)
          )
        ],
      ),
    );
  }
}
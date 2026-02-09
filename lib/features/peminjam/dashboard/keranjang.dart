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
  
  DateTime? tglPengambilan;
  DateTime? tglTenggat;

  Map<int, int> cartItems = {};
  List<dynamic> detailAlat = [];
  bool isLoading = true;
  
  // Variabel untuk validasi status pending
  bool isPending = false; 

  @override
  void initState() {
    super.initState();
    // Cek status pengajuan saat halaman pertama kali dimuat
    _checkExistingLoan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<int, int>?;
    if (args != null && cartItems.isEmpty) {
      cartItems = Map.from(args);
      _fetchDetailAlat();
    }
  }

  // FUNGSI CEK APAKAH ADA PINJAMAN YANG BELUM DI-ACC
  Future<void> _checkExistingLoan() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('peminjaman')
          .select()
          .eq('id_user', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (data != null) {
        setState(() {
          isPending = true;
        });
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    }
  }

  Future<void> _fetchDetailAlat() async {
    try {
      final ids = cartItems.keys.toList();
      if (ids.isEmpty) {
        setState(() => isLoading = false);
        return;
      }
      final data = await supabase
          .from('alat')
          .select('*, kategori(nama_kategori)')
          .filter('id_alat', 'in', ids);

      setState(() {
        detailAlat = data as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Fetch Detail: $e");
      setState(() => isLoading = false);
    }
  }

  int get totalUnit {
    int total = 0;
    cartItems.forEach((_, qty) => total += qty);
    return total;
  }

  void _removeItem(int idAlat) {
    setState(() {
      cartItems.remove(idAlat);
      detailAlat.removeWhere((element) => element['id_alat'] == idAlat);
    });
  }

  Future<void> _ajukanPinjaman() async {
    // Validasi Ganda sebelum Submit
    if (isPending) return;

    if (_namaController.text.isEmpty || tglPengambilan == null || tglTenggat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data!")),
      );
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      
      await supabase.from('peminjaman').insert({
        'id_user': user?.id,
        'nama_peminjam': _namaController.text,
        'tgl_pinjam': tglPengambilan!.toIso8601String(),
        'tgl_kembali': tglTenggat!.toIso8601String(),
        'status': 'pending',
        'total_item': totalUnit,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil! Menunggu konfirmasi petugas"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
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
          onPressed: () => Navigator.pop(context, cartItems),
        ),
        title: Text("Form Pengajuan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TAMPILAN PERINGATAN JIKA STATUS PENDING
                if (isPending)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hourglass_empty, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Anda tidak dapat mengajukan pinjaman baru karena masih ada pengajuan yang menunggu persetujuan.",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildLabel("Nama"),
                _buildTextField(_namaController, "Nama Lengkap", enabled: !isPending), 

                const SizedBox(height: 15),
                _buildLabel("Jumlah Total"),
                _buildTextField(TextEditingController(text: "$totalUnit unit"), "", enabled: false),

                const SizedBox(height: 20),
                _buildDateTimeSection(),

                const SizedBox(height: 25),
                _buildLabel("Daftar Alat:"),
                ...detailAlat.map((item) => _buildItemCard(item)).toList(),

                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPending ? null : () => Navigator.pop(context, cartItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending ? Colors.grey : const Color(0xFF02182F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Tambah alat", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isPending ? null : _ajukanPinjaman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending ? Colors.grey.shade400 : const Color(0xFF02182F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isPending ? "Menunggu Proses..." : "Ajukan pinjaman", 
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Helper method tetap sama seperti kode Anda sebelumnya
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey.shade100,
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
          const SizedBox(width: 10),
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
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: isPending ? null : () async {
              DateTime? picked = await showDatePicker(
                context: context, 
                initialDate: DateTime.now(), 
                firstDate: DateTime.now(), 
                lastDate: DateTime(2100)
              );
              if (picked != null) onSelect(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    date == null ? "Pilih Tgl" : DateFormat('dd/MM/yyyy').format(date), 
                    style: GoogleFonts.poppins(fontSize: 10)
                  ),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item['foto_url'], width: 50, height: 50, fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_alat'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(item['kategori']['nama_kategori'], style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text("${cartItems[id]} unit", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          if (!isPending)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _removeItem(id),
            )
        ],
      ),
    );
  }
}
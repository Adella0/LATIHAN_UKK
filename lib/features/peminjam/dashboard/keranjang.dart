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
    _checkExistingLoan();
    _loadUserFullname(); // Ambil nama otomatis saat init
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

  // FUNGSI AMBIL NAMA DARI AKUN LOGIN
 Future<void> _loadUserFullname() async {
  final user = supabase.auth.currentUser;
  if (user != null) {
    try {
      // Ambil data nama langsung dari tabel 'users' berdasarkan id_user
      final userData = await supabase
          .from('users')
          .select('nama')
          .eq('id_user', user.id)
          .maybeSingle();

      if (userData != null && userData['nama'] != null) {
        setState(() {
          _namaController.text = userData['nama'];
        });
      } else {
        // Jika di tabel users tidak ada, baru cek metadata
        final String? metaNama = user.userMetadata?['nama'] ?? user.userMetadata?['full_name'];
        setState(() {
          _namaController.text = metaNama ?? "Peminjam Terdaftar";
        });
      }
    } catch (e) {
      debugPrint("Error loading name: $e");
    }
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
          .eq('peminjam_id', user.id) // Sesuaikan dengan nama kolom FK di DB kamu
          .eq('status_transaksi', 'pending')
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
    if (isPending) return;

    if (tglPengambilan == null || tglTenggat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi tanggal pengambilan & tenggat!")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. INSERT KE TABEL PEMINJAMAN
      final peminjamanResponse = await supabase.from('peminjaman').insert({
        'peminjam_id': user.id,
        'pengambilan': tglPengambilan!.toIso8601String(),
        'tenggat': tglTenggat!.toIso8601String(),
        'status_transaksi': 'pending',
      }).select().single();

      final int idPeminjaman = peminjamanResponse['id_pinjam'];

      // 2. INSERT KE TABEL DETAIL_PEMINJAMAN
      final List<Map<String, dynamic>> detailData = [];
      cartItems.forEach((idAlat, qty) {
        detailData.add({
          'id_pinjam': idPeminjaman,
          'id_alat': idAlat,
          'jumlah': qty,
        });
      });

      await supabase.from('detail_peminjaman').insert(detailData);

      // 3. LOG AKTIVITAS
      await supabase.from('log_aktivitas').insert({
        'user_id': user.id,
        'aksi': 'Pengajuan Pinjaman',
        'keterangan': 'Mengajukan pinjaman untuk $totalUnit alat',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil! Menunggu konfirmasi petugas"), backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("Error simpan transaksi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengajukan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF02182F)),
          onPressed: () => Navigator.pop(context, cartItems),
        ),
        title: Text("Form Pengajuan", style: GoogleFonts.poppins(color: const Color(0xFF02182F), fontWeight: FontWeight.bold)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF02182F)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning jika ada status pending
                if (isPending) _buildPendingAlert(),

                _buildLabel("Nama Peminjam (Otomatis)"),
                _buildTextField(_namaController, "Memuat nama...", enabled: false), 

                const SizedBox(height: 15),
                _buildLabel("Jumlah Total"),
                _buildTextField(TextEditingController(text: "$totalUnit unit"), "", enabled: false),

                const SizedBox(height: 20),
                _buildDateTimeSection(),

                const SizedBox(height: 25),
                _buildLabel("Daftar Alat di Keranjang:"),
                ...detailAlat.map((item) => _buildItemCard(item)).toList(),

                const SizedBox(height: 15),
                if (!isPending) _buildAddMoreButton(),

                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildPendingAlert() {
    return Container(
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
              "Anda masih memiliki pengajuan pending. Selesaikan atau tunggu konfirmasi petugas.",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 14, color: Color(0xFF02182F)),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item['foto_url'], width: 45, height: 45, fit: BoxFit.cover, 
              errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 30)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_alat'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(item['kategori']['nama_kategori'], style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue)),
              ],
            ),
          ),
          Text("${cartItems[id]} unit", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
          if (!isPending)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _removeItem(id),
            )
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context, cartItems),
        icon: const Icon(Icons.add, size: 18),
        label: const Text("Tambah alat lain"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF02182F),
          side: const BorderSide(color: Color(0xFF02182F)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isPending ? null : _ajukanPinjaman,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPending ? Colors.grey : const Color(0xFF02182F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          isPending ? "PROSES PENDING..." : "AJUKAN PINJAMAN SEKARANG", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
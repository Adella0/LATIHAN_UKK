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
  bool isPending = false; 

  // Variabel Warna Sesuai Request & UI Modern
  final Color _primaryDark = const Color(0xFF02182F);
  final Color _softGrey = const Color(0xFFC9D0D6);
  final Color _mediumGrey = const Color(0xFF8F8E90);
  final Color _accentBlue = const Color(0xFF3A7BD5);

  @override
  void initState() {
    super.initState();
    _checkExistingLoan();
    _loadUserFullname();
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

  Future<void> _loadUserFullname() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
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

  Future<void> _checkExistingLoan() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('peminjaman')
          .select()
          .eq('peminjam_id', user.id)
          .eq('status_transaksi', 'pending')
          .maybeSingle();

      if (data != null) {
        setState(() => isPending = true);
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

      final peminjamanResponse = await supabase.from('peminjaman').insert({
        'peminjam_id': user.id,
        'pengambilan': tglPengambilan!.toIso8601String(),
        'tenggat': tglTenggat!.toIso8601String(),
        'status_transaksi': 'pending',
      }).select().single();

      final int idPeminjaman = peminjamanResponse['id_pinjam'];
      final List<Map<String, dynamic>> detailData = [];
      cartItems.forEach((idAlat, qty) {
        detailData.add({
          'id_pinjam': idPeminjaman,
          'id_alat': idAlat,
          'jumlah': qty,
        });
      });

      await supabase.from('detail_peminjaman').insert(detailData);
      await supabase.from('log_aktivitas').insert({
        'user_id': user.id,
        'aksi': 'Pengajuan Pinjaman',
        'keterangan': 'Mengajukan pinjaman untuk $totalUnit alat',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil! Menunggu konfirmasi"), backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 20),
          onPressed: () => Navigator.pop(context, cartItems),
        ),
        title: Text("Konfirmasi Pinjaman", 
          style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: _primaryDark))
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPending) _buildPendingAlert(),
                      
                      _buildSectionHeader("Informasi Peminjam"),
                      _buildInfoCard(),

                      const SizedBox(height: 25),
                      _buildSectionHeader("Durasi Peminjaman"),
                      _buildDateTimeSection(),

                      const SizedBox(height: 25),
                      _buildSectionHeader("Daftar Inventaris"),
                      ...detailAlat.map((item) => _buildItemCard(item)).toList(),

                      if (!isPending) _buildAddMoreButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryDark)),
    );
  }

  Widget _buildPendingAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Anda memiliki pengajuan yang masih diproses.",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, "Nama", _namaController.text),
          const Divider(height: 24),
          _buildInfoRow(Icons.shopping_bag_outlined, "Total Unit", "$totalUnit Alat"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _softGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: _primaryDark),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryDark)),
          ],
        )
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildDateSelector("Pengambilan", tglPengambilan, (val) => setState(() => tglPengambilan = val)),
          Container(height: 40, width: 1, color: _softGrey.withOpacity(0.5)),
          _buildDateSelector("Tenggat", tglTenggat, (val) => setState(() => tglTenggat = val)),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onSelect) {
    return Expanded(
      child: GestureDetector(
        onTap: isPending ? null : () async {
          DateTime? picked = await showDatePicker(
            context: context, 
            initialDate: DateTime.now(), 
            firstDate: DateTime.now(), 
            lastDate: DateTime(2100),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: _primaryDark)),
              child: child!,
            ),
          );
          if (picked != null) onSelect(picked);
        },
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
            const SizedBox(height: 4),
            Text(
              date == null ? "Pilih Tgl" : DateFormat('dd MMM yyyy').format(date), 
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: _accentBlue)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    int id = item['id_alat'];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(item['foto_url'], width: 60, height: 60, fit: BoxFit.cover, 
              errorBuilder: (_, __, ___) => Container(color: _softGrey, child: const Icon(Icons.inventory_2))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_alat'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryDark)),
                Text(item['kategori']['nama_kategori'], style: GoogleFonts.poppins(fontSize: 11, color: _mediumGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _primaryDark.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Text("${cartItems[id]}x", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryDark)),
          ),
          if (!isPending)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
              onPressed: () => _removeItem(id),
            )
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context, cartItems),
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: Text("Tambah Alat Lagi", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(foregroundColor: _accentBlue),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: isPending ? null : _ajukanPinjaman,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPending ? _mediumGrey : _primaryDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            isPending ? "PENGAJUAN SEDANG DIPROSES" : "KIRIM PENGAJUAN", 
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
        ),
      ),
    );
  }
}
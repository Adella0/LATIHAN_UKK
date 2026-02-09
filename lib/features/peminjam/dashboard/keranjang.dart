import 'package:flutter/material.dart';

class KeranjangScreen extends StatelessWidget {
  const KeranjangScreen({super.key});

          @override
        Widget build(BuildContext context) {
          // Ambil data, jika null berikan Map kosong {} agar tidak error
          final Map<int, int> items = (ModalRoute.of(context)?.settings.arguments as Map<int, int>?) ?? {};

          return Scaffold(
            appBar: AppBar(title: const Text("Keranjang")),
            body: items.isEmpty 
                ? const Center(child: Text("Keranjang kosong"))
                : ListView.builder(
                    itemCount: items.length,
              itemBuilder: (context, index) {
                int idAlat = items.keys.elementAt(index);
                int jumlah = items[idAlat]!;

                return ListTile(
                  title: Text("ID Alat: $idAlat"),
                  subtitle: Text("Jumlah dipinjam: $jumlah unit"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Logika hapus item (jika menggunakan state management)
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02182F)),
          onPressed: () {
            // Logika Checkout ke Supabase
          },
          child: const Text("Proses Peminjaman", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
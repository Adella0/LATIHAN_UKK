import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenolakanDialog extends StatefulWidget {
  final String namaPeminjam;
  final Function(String) onConfirm;

  const PenolakanDialog({
    super.key, 
    required this.namaPeminjam, 
    required this.onConfirm
  });

  @override
  State<PenolakanDialog> createState() => _PenolakanDialogState();
}

class _PenolakanDialogState extends State<PenolakanDialog> {
  final TextEditingController _alasanController = TextEditingController();
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ditolak!",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Alasan",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _alasanController,
            maxLines: 3,
            onChanged: (val) {
              if (val.isNotEmpty && _isError) setState(() => _isError = false);
            },
            decoration: InputDecoration(
              hintText: "Berikan alasan",
              hintStyle: GoogleFonts.poppins(fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _isError ? Colors.red : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _isError ? Colors.red : Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline, color: _isError ? Colors.red : Colors.grey, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "Jelaskan isi alasan penolakan dengan jelas",
                  style: GoogleFonts.poppins(
                    fontSize: 10, 
                    color: _isError ? Colors.red : Colors.grey.shade600
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                if (_alasanController.text.trim().isEmpty) {
                  setState(() => _isError = true);
                } else {
                  widget.onConfirm(_alasanController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02182F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text("Kirim", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sitikap/api/izin_api.dart';
import 'package:sitikap/utils/colors.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  final TextEditingController _alasanController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  String _errorMessage = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitIzin() async {
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Harap pilih tanggal izin';
      });
      return;
    }

    if (_alasanController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Harap isi alasan izin';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      await IzinApiService.submitIzin(
        date: dateString,
        alasanIzin: _alasanController.text,
      );

      setState(() {
        _selectedDate = null;
        _alasanController.clear();
        _isSubmitting = false;
      });

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Berhasil'),
            ],
          ),
          content: const Text('Pengajuan izin berhasil dikirim.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Pengajuan Izin',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: AppColors.neutralWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Text(
            //   'Form Pengajuan Izin',
            //   style: GoogleFonts.poppins(
            //     fontSize: 22,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // SizedBox(height: 8),
            Text(
              'Isi form berikut untuk mengajukan izin jika tidak masuk',

              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            // Date Picker
            const Text(
              'Tanggal Izin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal Izin'
                          : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reason Field
            const Text(
              'Alasan Izin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan mengapa Anda tidak dapat hadir...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jelaskan secara detail alasan Anda tidak dapat hadir',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.gradienbiru,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Ajukan Izin',
                          style: TextStyle(
                            color: AppColors.neutralWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: 52,
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       gradient: AppColors.gradienbiru,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.transparent,
            //         shadowColor: Colors.transparent,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       onPressed: () {
            //         _isSubmitting ? null : _submitIzin;
            //       },
            //       child: const Text(
            //         "Ajukan Izin",
            //         style: TextStyle(
            //           color: AppColors.neutralWhite,
            //           fontSize: 16,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/absen1_map_screen.dart';
import 'package:sitikap/views/absen_map_screen.dart';
import 'package:sitikap/views/home_screen.dart';
import 'package:sitikap/views/izin_screen.dart';
import 'package:sitikap/views/profile_screen.dart';
import 'package:sitikap/views/riwayat_screen.dart';

class Botnav extends StatefulWidget {
  final int initialPage; // Tambahkan parameter initialPage

  const Botnav({super.key, this.initialPage = 0}); // Default ke 0 (Home)

  static const id = "/botnav";

  @override
  State<Botnav> createState() => _BotnavState();
}

class _BotnavState extends State<Botnav> {
  late int currentPage; // Ubah jadi late

  final List<Widget> _pages = [
    const HomeScreen(),
    const RiwayatScreen(),
    const Center(
      child: Text("Absen", style: TextStyle(fontSize: 24)),
    ), // Placeholder untuk index 2
    const IzinScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set currentPage berdasarkan initialPage yang diterima
    currentPage = widget.initialPage;
  }

  void _handleIndexChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  // Function untuk navigate ke AbsenMapScreen
  void _navigateToAbsenMap() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AbsenMapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[currentPage],

      // FAB fingerprint - Navigate ke AbsenMapScreen
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAbsenMap,
        backgroundColor: AppColors.blue,
        shape: CircleBorder(),
        child: Icon(Icons.fingerprint, color: AppColors.neutralWhite, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BottomAppBar melayang dengan notch
      bottomNavigationBar: BottomAppBar(
        color: Colors.white.withOpacity(0.9),
        elevation: 10,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home_outlined,
                  size: 30,
                  color: currentPage == 0 ? AppColors.blue : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  size: 30,
                  color: currentPage == 1 ? AppColors.blue : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(1),
              ),
              SizedBox(width: 40), // spasi buat FAB
              IconButton(
                icon: Icon(
                  Icons.mail_outline_outlined,
                  size: 30,
                  color: currentPage == 3 ? AppColors.blue : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(3),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  size: 30,
                  color: currentPage == 4 ? AppColors.blue : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

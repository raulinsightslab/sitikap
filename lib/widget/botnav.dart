import 'package:flutter/material.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/home_screen.dart'; // pastikan path sesuai

class FloatingNavBarExample extends StatefulWidget {
  const FloatingNavBarExample({super.key});

  @override
  State<FloatingNavBarExample> createState() => _FloatingNavBarExampleState();
}

class _FloatingNavBarExampleState extends State<FloatingNavBarExample> {
  int _selectedIndex = 0;

  // daftar halaman sesuai navbar
  final List<Widget> _pages = [
    const HomeScreen(), // ini manggil HomeScreen
    const Center(child: Text("Riwayat")),
    const Center(child: Text("Pesan")),
    const Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex], // tampilkan sesuai index

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.fingerprint, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        height: 65,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: AppColors.neutralWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 28,
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0 ? AppColors.blue : Colors.grey,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 0),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 28,
                  icon: Icon(
                    Icons.history,
                    color: _selectedIndex == 1 ? AppColors.blue : Colors.grey,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(width: 40), // ruang buat FAB
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 28,
                  icon: Icon(
                    Icons.mail_outline,
                    color: _selectedIndex == 2 ? AppColors.blue : Colors.grey,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 2),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 28,
                  icon: Icon(
                    Icons.person_outline,
                    color: _selectedIndex == 3 ? AppColors.blue : Colors.grey,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

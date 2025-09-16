import 'package:flutter/material.dart';
import 'package:sitikap/views/home_screen.dart';

class FloatingNavBarExample extends StatefulWidget {
  const FloatingNavBarExample({super.key});
  static const id = "/botnav";

  @override
  State<FloatingNavBarExample> createState() => _FloatingNavBarExampleState();
}

class _FloatingNavBarExampleState extends State<FloatingNavBarExample> {
  int currentPage = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Riwayat", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Pesan", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Izin", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Profil", style: TextStyle(fontSize: 24))),
  ];

  void _handleIndexChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[currentPage],

      // FAB fingerprint
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleIndexChanged(2); // index fingerprint (tengah)
        },
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.fingerprint, color: Colors.black, size: 30),
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
                  color: currentPage == 0 ? Colors.black : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  size: 30,
                  color: currentPage == 1 ? Colors.black : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(1),
              ),
              SizedBox(width: 40), // spasi buat FAB
              IconButton(
                icon: Icon(
                  Icons.mail_outline_outlined,
                  size: 30,
                  color: currentPage == 3 ? Colors.black : Colors.grey,
                ),
                onPressed: () => _handleIndexChanged(3),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  size: 30,
                  color: currentPage == 4 ? Colors.black : Colors.grey,
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

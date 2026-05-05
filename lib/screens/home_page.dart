import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recruitment_mobile/widgets/menu_card.dart';
import 'package:recruitment_mobile/screens/setting_page.dart';
import 'package:recruitment_mobile/screens/profile_page.dart';
import 'package:recruitment_mobile/screens/registration_guide_page.dart';
import 'package:recruitment_mobile/screens/registration_form_page.dart';
import 'package:recruitment_mobile/screens/recruitment_status_page.dart';
import 'package:recruitment_mobile/screens/service_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeBody(),
    SettingPage(),
    ProfilePage(),
  ];

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(29, 93, 155, 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? const Color.fromRGBO(29, 93, 155, 1)
                  : Colors.grey,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color.fromRGBO(29, 93, 155, 1)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: Stack(
        children: [
          _pages[_selectedIndex],

          Positioned(
            bottom: 8,
            left: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 83, 83, 83).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color.fromARGB(255, 188, 188, 188).withOpacity(0.1),
                          const Color.fromARGB(255, 188, 188, 188).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_rounded, 'Home', 0),
                        _buildNavItem(Icons.settings_outlined, 'Setting', 1),
                        _buildNavItem(Icons.person_outline_rounded, 'Profile', 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final _searchController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;
  String _searchQuery = '';

  // Data semua menu
  final List<Map<String, dynamic>> _allMenus = [
    {
      'title': 'Panduan Registrasi',
      'color': const Color(0xFF26A69A),
      'icon': Icons.person,
      'page': const RegistrationGuidePage(),
    },
    {
      'title': 'Form Registrasi',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.list_alt,
      'page': const RegistrationFormPage(),
    },
    {
      'title': 'Status Perekrutan',
      'color': const Color(0xFFFFC107),
      'icon': Icons.how_to_reg,
      'page': const RecruitmentStatusPage(),
    },
    {
      'title': 'Pelayanan',
      'color': const Color(0xFFE53935),
      'icon': Icons.info,
      'page': const ServicePage(),
    },
  ];

  // Filter menu berdasarkan query
  List<Map<String, dynamic>> get _filteredMenus {
    if (_searchQuery.isEmpty) return _allMenus;
    return _allMenus.where((menu) {
      return menu['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(29, 93, 155, 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/huabao-logo.png', width: 36),
                    const SizedBox(width: 10),
                    const Text(
                      'Recruitment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _user?.photoURL != null
                        ? CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(_user!.photoURL!),
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      _getFirstName(_user?.displayName ?? 'Pengguna'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
              ),
              items: [
                _buildImageBanner('assets/images/banner1.png'),
                _buildImageBanner('assets/images/banner2.png'),
                _buildImageBanner('assets/images/banner3.png'),
              ],
            ),
          ],

          // ── SEARCH BAR ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          if (_searchQuery.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Hasil pencarian "$_searchQuery" : ${_filteredMenus.length} ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            if (_filteredMenus.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Menu tidak ditemukan',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _filteredMenus.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final menu = _filteredMenus[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (menu['color'] as Color)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          menu['icon'] as IconData,
                          color: menu['color'] as Color,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        menu['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.grey),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                menu['page'] as Widget),
                      ),
                    ),
                  );
                },
              ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _allMenus.map((menu) {
                  return MenuCard(
                    title: menu['title'] as String,
                    color: menu['color'] as Color,
                    icon: menu['icon'] as IconData,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => menu['page'] as Widget),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── INFORMASI ───────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Informasi :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(29, 93, 155, 1),
                ),
              ),
            ),
            _buildInfoItem(Icons.info_outline,
                'Pendaftaran online dibuka setiap hari'),
            _buildInfoItem(Icons.info_outline,
                'Bawa dokumen lengkap saat wawancara'),
            _buildInfoItem(Icons.info_outline,
                'Hasil seleksi diumumkan via email'),
          ],

          const SizedBox(height: 100),
        ],
      ),
      )
    );
  }

  Widget _buildImageBanner(String imagePath) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: const Color.fromRGBO(29, 93, 155, 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'Pengguna';
    return fullName.split(' ').first;
  }
}
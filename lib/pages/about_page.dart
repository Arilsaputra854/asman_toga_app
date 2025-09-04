import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Modern color palette - same as previous codes
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFFF8C42);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accentBlue = Color(0xFF3182CE);

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset("assets/logo.png", height: 80, width: 80),
          ),
          const SizedBox(height: 20),
          const Text(
            "ASMAN TOGA",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Plant Management System",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: textPrimary,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: textPrimary,
      //   title: const Text(
      //     "Tentang Aplikasi",
      //     style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.w700,
      //       color: textPrimary,
      //     ),
      //   ),
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: Container(
      //       padding: const EdgeInsets.all(8),
      //       decoration: BoxDecoration(
      //         color: backgroundColor,
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //       child: Icon(Icons.arrow_back_rounded, color: textPrimary),
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo Section with Modern Design
              _buildLogoSection(),

              // About Section
              _buildSectionTitle("Tentang Aplikasi", Icons.info_rounded),
              _buildModernCard(
                child: _buildContentCard(
                  "ASMAN TOGA adalah aplikasi manajemen tanaman obat keluarga yang dirancang untuk membantu masyarakat dalam mengelola dan memantau tanaman toga secara digital. "
                  "Aplikasi ini memungkinkan pengguna untuk mendokumentasikan lokasi tanaman, memantau pertumbuhan, dan mendapatkan informasi tentang manfaat serta cara perawatan tanaman obat tradisional. "
                  "Dengan teknologi modern dan antarmuka yang intuitif, ASMAN TOGA menjadi solusi terpercaya untuk pelestarian pengetahuan tentang tanaman obat keluarga.",
                ),
              ),

              // Team Section
              _buildSectionTitle("Tim Pengembang", Icons.group_rounded),
              _buildModernCard(
                child: Column(
                  children: [
                    _buildContentCard(
                      "Aplikasi ASMAN TOGA dikembangkan oleh tim yang berdedikasi untuk melestarikan pengetahuan tradisional tentang tanaman obat. "
                      "Tim kami terdiri dari pengembang berpengalaman, ahli tanaman obat, dan desainer UI/UX yang berkomitmen untuk memberikan solusi teknologi terbaik. "
                      "Kami percaya bahwa teknologi dapat menjadi jembatan untuk melestarikan kearifan lokal dan membuatnya lebih mudah diakses oleh generasi modern.",
                    ),
                    const SizedBox(height: 16),

                    // // Team Stats
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           gradient: LinearGradient(
                    //             colors: [primaryGreen, lightGreen],
                    //             begin: Alignment.topLeft,
                    //             end: Alignment.bottomRight,
                    //           ),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: const Column(
                    //           children: [
                    //             Icon(
                    //               Icons.code_rounded,
                    //               color: Colors.white,
                    //               size: 24,
                    //             ),
                    //             SizedBox(height: 8),
                    //             Text(
                    //               "5+",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.w700,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             Text(
                    //               "Developer",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           gradient: LinearGradient(
                    //             colors: [accentBlue, Colors.blue.shade300],
                    //             begin: Alignment.topLeft,
                    //             end: Alignment.bottomRight,
                    //           ),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: const Column(
                    //           children: [
                    //             Icon(
                    //               Icons.science_rounded,
                    //               color: Colors.white,
                    //               size: 24,
                    //             ),
                    //             SizedBox(height: 8),
                    //             Text(
                    //               "2+",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.w700,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             Text(
                    //               "Ahli Toga",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           gradient: LinearGradient(
                    //             colors: [warningOrange, Colors.orange.shade300],
                    //             begin: Alignment.topLeft,
                    //             end: Alignment.bottomRight,
                    //           ),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: const Column(
                    //           children: [
                    //             Icon(
                    //               Icons.design_services_rounded,
                    //               color: Colors.white,
                    //               size: 24,
                    //             ),
                    //             SizedBox(height: 8),
                    //             Text(
                    //               "3+",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.w700,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //             Text(
                    //               "Designer",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen.withOpacity(0.1), backgroundColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryGreen.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.eco_rounded, color: primaryGreen, size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      "Melestarikan Kearifan Lokal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

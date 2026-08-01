import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';

class PatientDrawer extends StatelessWidget {
  const PatientDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: AppColors.mainScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary700.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary700,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Yomna",
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Patient Account",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // MENU ITEMS
          _drawerItem(icon: Icons.person, label: "Profile", onTap: () {}),
          _drawerItem(
            icon: Icons.calendar_month,
            label: "Appointments",
            onTap: () {},
          ),
          _drawerItem(icon: Icons.favorite, label: "Favorites", onTap: () {}),
          _drawerItem(icon: Icons.settings, label: "Settings", onTap: () {}),
          _drawerItem(icon: Icons.language, label: "Language", onTap: () {}),

          const Spacer(),

          // LOGOUT
          Padding(
            padding: const EdgeInsets.all(20),
            child: _drawerItem(
              icon: Icons.logout,
              label: "Logout",
              onTap: () {},
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary700,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

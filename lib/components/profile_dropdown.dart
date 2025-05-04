import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/services/auth_service.dart';

class ProfileDropdown {
  static void show(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(child: AuthService().getProfileImage(size: 40)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AuthService().getUserName(),
                            style: GoogleFonts.livvic(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            AuthService().getUserEmail(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text(
                          'Confirm Logout',
                          style: GoogleFonts.livvic(fontWeight: FontWeight.w700),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF54AF75),
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (shouldLogout == true) {
                      await AuthService().signOut();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Log Out', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

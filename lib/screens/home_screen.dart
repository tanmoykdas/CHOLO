import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHOLO'),
      ),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '⚠️ Email Not Verified',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your email is not verified yet.\n\nPlease check your inbox and click the verification link, then try logging in again.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section at Top
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white24,
                                backgroundImage: user.profilePictureUrl.isNotEmpty
                                    ? NetworkImage(user.profilePictureUrl)
                                    : null,
                                child: user.profilePictureUrl.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (user.age != null || user.gender.isNotEmpty)
                                      Text(
                                        [
                                          if (user.age != null) '${user.age} years',
                                          if (user.gender.isNotEmpty) user.gender,
                                        ].join(' • '),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    if (user.universityName.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        user.universityName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      user.universityEmail,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rating Section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  user.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${user.ratingCount} reviews)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Divider
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade800,
                    height: 1,
                  ),
                  
                  // Four Options in 2x2 Grid
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.directions_car,
                                title: 'Share Ride',
                                onTap: () => Navigator.pushNamed(context, '/offer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.search,
                                title: 'Book Ride',
                                onTap: () => Navigator.pushNamed(context, '/search'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.list_alt,
                                title: 'Offered Rides',
                                onTap: () => Navigator.pushNamed(context, '/my_offered'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridButton(
                                context,
                                icon: Icons.book_online,
                                title: 'Booked Rides',
                                onTap: () => Navigator.pushNamed(context, '/my_booked'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Logout Button at Bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

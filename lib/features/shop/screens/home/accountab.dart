import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/authentication/screens/login/login.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const LoginScreen());
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            // Profile Section
            _buildProfileCard(user),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Settings Section
            _buildSettingsSection(),

            const SizedBox(height: TSizes.spaceBtwSections),

            // About Us Section
            _buildAboutUsSection(),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // 🔹 Profile Card UI
  Widget _buildProfileCard(User user) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: TColors.primary,
              child: const Icon(Iconsax.user, size: 40, color: Colors.white),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userMetadata?['full_name'] ?? 'No Name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email ?? 'No Email',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Settings Section
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: TSizes.spaceBtwItems),

        _buildSettingsTile(
          Iconsax.lock,
          "Change Password",
          onTap: () {
            // TODO: Navigate to change password screen
          },
        ),
      ],
    );
  }

  // 🔹 About Us Section
  Widget _buildAboutUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("About Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: TSizes.spaceBtwItems),
        const Text(
          "PrintEase is a smart printing solution for college students. Upload documents, set print preferences, and collect prints easily from designated shops.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // 🔹 Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Iconsax.logout),
      label: const Text("Logout"),
      onPressed: () => _confirmLogout(context),
    );
  }

  // 🔹 Custom Tile for Settings
  Widget _buildSettingsTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: TColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // 🔹 Logout Confirmation Dialog
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.pop(context);
              Get.offAll(() => const LoginScreen());
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
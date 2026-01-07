import 'package:flutter/material.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Hesap'),
          _buildItem(Icons.person_outline, 'Profili Düzenle'),
          _buildItem(Icons.notifications_none, 'Bildirimler'),
          _buildItem(Icons.lock_outline, 'Gizlilik'),
          
          const SizedBox(height: 24),
          _buildSection('Uygulama'),
          _buildItem(Icons.info_outline, 'Hakkında'),
          _buildItem(Icons.help_outline, 'Yardım & Destek'),
          _buildItem(Icons.description_outlined, 'KVKK Aydınlatma Metni'),
          
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 16),
          _buildDeleteAccountButton(),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.bodyMedium.copyWith(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: AppTypography.bodyLarge),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout),
      label: const Text('Çıkış Yap'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceLight,
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Hesabımı Sil',
        style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
      ),
    );
  }
}

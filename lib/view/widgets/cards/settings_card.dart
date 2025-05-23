import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String title;
  final VoidCallback onTap;

  const SettingCard({
    super.key,
    this.icon,
    this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: imageUrl != null
            ? Image.asset(
                imageUrl!,
                width: 24,
                height: 24,
              )
            : Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

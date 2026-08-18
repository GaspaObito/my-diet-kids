import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Widget child;

  const MenuCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),

      elevation: 3,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wms_durich/core/widgets/profile_dropdown.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        automaticallyImplyLeading: false,
        actions: [
          const ProfileDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Text(
          'Halaman Sales: Sedang dalam tahap pengembangan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

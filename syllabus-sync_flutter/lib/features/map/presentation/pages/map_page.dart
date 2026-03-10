import 'package:flutter/material.dart';

/// Map page — placeholder, full implementation in Phase 5.
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64),
            SizedBox(height: 16),
            Text('Campus Map — Coming in Phase 5'),
          ],
        ),
      ),
    );
  }
}

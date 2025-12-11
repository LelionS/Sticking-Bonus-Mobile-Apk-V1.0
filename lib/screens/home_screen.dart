import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import 'download_screen.dart';
import 'input_screen.dart';
import 'sync_screen.dart';
import 'view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Sticking App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Operations'),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MenuCard(
                  title: 'Data Input',
                  icon: Icons.input,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                  ),
                ),
                MenuCard(
                  title: 'View Data',
                  icon: Icons.view_list,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const SectionHeader(title: 'Data'),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MenuCard(
                  title: 'Download Data',
                  icon: Icons.download,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DownloadScreen()),
                  ),
                ),
                MenuCard(
                  title: 'Sync Data',
                  icon: Icons.sync,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SyncScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';

class MonitoringHubScreen extends StatelessWidget {
  const MonitoringHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outils de Monitoring'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Journalisations',
            items: [
              MonitoringItem(
                title: 'Journal',
                subtitle: 'Afficher les journaux de l\'application',
                icon: Icons.memory,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OremusLogger.createLogScreen(
                        appName: AppConstants.APP_NAME,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<MonitoringItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _buildItemTile(items[i]),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 72, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(MonitoringItem item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        child: Icon(item.icon, color: Colors.blue),
      ),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }
}

class MonitoringItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const MonitoringItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

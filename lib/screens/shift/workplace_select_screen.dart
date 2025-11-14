import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/workplace_model.dart';
import 'workplace_edit_screen.dart';

class WorkplaceSelectScreen extends StatelessWidget {
  const WorkplaceSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('勤務先を選択'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkplaceEditScreen()),
              );
            },
          ),
        ],
      ),
      body: dataProvider.workplaces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '勤務先が登録されていません',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkplaceEditScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('勤務先を追加'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataProvider.workplaces.length,
              itemBuilder: (context, index) {
                final workplace = dataProvider.workplaces[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.business)),
                    title: Text(
                      workplace.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      workplace.paymentType == PaymentType.hourly
                          ? '時給: ${workplace.baseRate.toStringAsFixed(0)}円'
                          : '日給: ${workplace.baseRate.toStringAsFixed(0)}円',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkplaceEditScreen(workplace: workplace),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context, workplace);
                    },
                  ),
                );
              },
            ),
    );
  }
}

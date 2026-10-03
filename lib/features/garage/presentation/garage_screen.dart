import 'package:flutter/material.dart';

import '../../profile/models/motorcycle.dart';
import '../../../core/widgets/glass_card.dart';
import 'motorcycle_form.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final List<Motorcycle> bikes = [
    Motorcycle(
      id: 'demo-1',
      manufacturer: 'Royal Enfield',
      model: 'Himalayan',
      displacementCc: 450,
      year: 2025,
      nickname: 'Snow Runner',
    ),
  ];

  void addBike() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: MotorcycleForm(
            onSaved: (bike) {
              setState(() => bikes.add(bike));
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void editBike(Motorcycle bike) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: MotorcycleForm(
            initial: bike,
            onSaved: (updated) {
              setState(() {
                final i = bikes.indexWhere((b) => b.id == updated.id);
                if (i != -1) bikes[i] = updated;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Universal Garage',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: addBike,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'No brand whitelist. Add any motorcycle, any model, any displacement.',
        ),
        const SizedBox(height: 18),
        ...bikes.map(
          (bike) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.two_wheeler),
                ),
                title: Text(bike.displayName),
                subtitle: Text(
                  '${bike.year}${bike.nickname == null ? '' : ' • ${bike.nickname}'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editBike(bike),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

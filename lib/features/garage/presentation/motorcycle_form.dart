import 'package:flutter/material.dart';

import '../../profile/models/motorcycle.dart';
import '../../../core/widgets/neon_button.dart';

class MotorcycleForm extends StatefulWidget {
  const MotorcycleForm({
    required this.onSaved,
    super.key,
    this.initial,
  });

  final Motorcycle? initial;
  final ValueChanged<Motorcycle> onSaved;

  @override
  State<MotorcycleForm> createState() => _MotorcycleFormState();
}

class _MotorcycleFormState extends State<MotorcycleForm> {
  final manufacturer = TextEditingController();
  final model = TextEditingController();
  final cc = TextEditingController();
  final year = TextEditingController();
  final nickname = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bike = widget.initial;
    if (bike != null) {
      manufacturer.text = bike.manufacturer;
      model.text = bike.model;
      cc.text = bike.displacementCc.toString();
      year.text = bike.year.toString();
      nickname.text = bike.nickname ?? '';
    }
  }

  @override
  void dispose() {
    manufacturer.dispose();
    model.dispose();
    cc.dispose();
    year.dispose();
    nickname.dispose();
    super.dispose();
  }

  void save() {
    final manufacturerValue = manufacturer.text.trim();
    final modelValue = model.text.trim();
    final ccValue = int.tryParse(cc.text.trim()) ?? 0;
    final yearValue = int.tryParse(year.text.trim()) ?? DateTime.now().year;

    if (manufacturerValue.isEmpty || modelValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manufacturer and model are required.')),
      );
      return;
    }

    widget.onSaved(
      Motorcycle(
        id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        manufacturer: manufacturerValue,
        model: modelValue,
        displacementCc: ccValue,
        year: yearValue,
        nickname: nickname.text.trim().isEmpty ? null : nickname.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: manufacturer,
          decoration: const InputDecoration(
            labelText: 'Manufacturer',
            hintText: 'Any brand — Royal Enfield, Yamaha, Honda...',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: model,
          decoration: const InputDecoration(
            labelText: 'Model',
            hintText: 'Any model — Himalayan, MT-15, Africa Twin...',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cc,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Displacement (cc)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: year,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nickname,
          decoration: const InputDecoration(
            labelText: 'Nickname (optional)',
            hintText: 'My Himalayan',
          ),
        ),
        const SizedBox(height: 18),
        NeonButton(
          label: widget.initial == null ? 'ADD MOTORCYCLE' : 'SAVE CHANGES',
          icon: Icons.save,
          onPressed: save,
        ),
      ],
    );
  }
}

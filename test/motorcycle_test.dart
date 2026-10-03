import 'package:flutter_test/flutter_test.dart';
import 'package:feel_it_official/features/profile/models/motorcycle.dart';

void main() {
  test('supports arbitrary motorcycle manufacturer and model', () {
    const bike = Motorcycle(
      id: '1',
      manufacturer: 'Ducati',
      model: 'Multistrada V4',
      displacementCc: 1158,
      year: 2024,
    );

    expect(bike.displayName, 'Ducati Multistrada V4 1158 cc');

    final restored = Motorcycle.fromJson(bike.toJson());
    expect(restored.manufacturer, 'Ducati');
    expect(restored.model, 'Multistrada V4');
    expect(restored.displacementCc, 1158);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_068/services/mongo_service.dart'; // Sesuaikan jika beda

void main() {
  group('MongoService Unit Tests (Homework Modul 4 - Cloud)', () {
    
    test('TC_HW_07 - deleteLog should process valid 24-char hex ID', () async {
      final service = MongoService();
      expect(
        () async => await service.deleteLog('5fffffffffffffffffffffff'),
        throwsA(predicate((e) => e.toString().contains('NotInitializedError') || e.toString().contains('MONGODB_URI'))),
        reason: "ID valid harus lolos validasi awal sebelum ke Cloud",
      );
    });

    test('TC_HW_08 - deleteLog should reject empty ID gracefully', () async {
      final service = MongoService();
      expect(
        () async => await service.deleteLog(''),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Format ID tidak valid'))),
        reason: "Sistem tidak boleh crash, harus menolak string kosong secara rapi",
      );
    });

    test('TC_HW_09 - deleteLog should reject short/invalid ID gracefully', () async {
      final service = MongoService();
      expect(
        () async => await service.deleteLog('123'),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Format ID tidak valid'))),
        reason: "Sistem tidak boleh crash, harus menolak string yang bukan 24 karakter",
      );
    });

  });
}
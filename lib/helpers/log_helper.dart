import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown", 
    int level = 2,
  }) async {
    // 1. Siapkan nilai default untuk konfigurasi log, sehingga jika terjadi error saat membaca .env, log tetap berjalan dengan nilai default yang sudah disiapkan.
    int configLevel = 2;
    String muteList = '';

    // 2. Coba baca konfigurasi dari .env, jika gagal, akan dilempar ke catch dan menggunakan nilai default.
    try {
      // Baca konfigurasi dari .env, jika gagal, akan dilempar ke catch dan menggunakan nilai default.
      configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
      muteList = dotenv.env['LOG_MUTE'] ?? '';
    } catch (e) {
      // Jika terjadi error saat membaca .env, log error tersebut dan lanjutkan dengan nilai default.
      // Log akan tetap berjalan dengan nilai default yang sudah disiapkan.
    }
    
    // 3. Cek level log dan mute list, jika level log lebih tinggi dari konfigurasi atau sumber log ada di mute list, maka log tidak akan ditulis.
    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      DateTime now = DateTime.now();
      String dateStr = DateFormat('dd-MM-yyyy').format(now);
      String timestamp = DateFormat('HH:mm:ss').format(now);
      String label = _getLabel(level);
      String color = _getColor(level);
      
      String logLine = '[$timestamp][$label][$source] -> $message';

      dev.log(message, name: source, time: now, level: level * 100);
      // ignore: avoid_print
      print('$color$logLine\x1B[0m');

      final directory = Directory('logs');
      if (!await directory.exists()) {
        await directory.create();
      }
      final file = File('logs/$dateStr.log');
      await file.writeAsString('$logLine\n', mode: FileMode.append);

    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m';
      case 2:
        return '\x1B[32m';
      case 3:
        return '\x1B[34m';
      default:
        return '\x1B[0m';
    }
  }
}
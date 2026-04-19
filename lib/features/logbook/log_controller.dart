import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:hive_flutter/hive_flutter.dart'; 

import 'package:logbook_app_068/features/logbook/models/log_model.dart';
import 'package:logbook_app_068/services/mongo_service.dart';
import 'package:logbook_app_068/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]); 

  final _myBox = Hive.box<LogModel>('offline_logs');

  // --- 1. FUNGSI LOAD DATA ---
  Future<void> loadLogs(String teamId) async {
    logsNotifier.value = _myBox.values.toList();
    filteredLogsNotifier.value = _myBox.values.toList();

    try {
      final cloudData = await MongoService().getLogs(teamId);

      await _myBox.clear();
      await _myBox.addAll(cloudData);

      logsNotifier.value = cloudData;
      filteredLogsNotifier.value = cloudData;
      
      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal", level: 2);
    }
  }

  // --- 2. FUNGSI PENCARIAN ---
  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogsNotifier.value = logsNotifier.value;
    } else {
      filteredLogsNotifier.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // --- 3. FUNGSI TAMBAH DATA ---
  Future<void> addLog(String title, String desc, String authorId, String teamId, bool isPublic) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
      category: 'Umum',
    );

    await _myBox.add(newLog);
    logsNotifier.value = _myBox.values.toList();
    filteredLogsNotifier.value = _myBox.values.toList();

    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog("SUCCESS: Tambah data tersinkron ke Cloud", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("WARNING: Tersimpan lokal, sinkron pending - $e", level: 1);
    }
  }

  // --- 4. FUNGSI UPDATE DATA ---
  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory, bool isPublic) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle, 
      description: newDesc, 
      date: DateTime.now().toString(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: isPublic,
      category: newCategory, 
    );

    final hiveIndex = _myBox.values.toList().indexWhere((log) => log.id == oldLog.id);
    if(hiveIndex != -1) {
      await _myBox.putAt(hiveIndex, updatedLog);
    }
    logsNotifier.value = _myBox.values.toList();
    filteredLogsNotifier.value = _myBox.values.toList();

    try {
      await MongoService().updateLog(updatedLog);
      await LogHelper.writeLog("SUCCESS: Update '${oldLog.title}' Berhasil", level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Update - $e", level: 1);
    }
  }

  // --- 5. FUNGSI HAPUS DATA ---
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    final hiveIndex = _myBox.values.toList().indexWhere((log) => log.id == targetLog.id);
    if(hiveIndex != -1) {
      await _myBox.deleteAt(hiveIndex);
    }
    logsNotifier.value = _myBox.values.toList();
    filteredLogsNotifier.value = _myBox.values.toList();

    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(targetLog.id!);
        await LogHelper.writeLog("SUCCESS: Hapus '${targetLog.title}' Berhasil", level: 2);
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Hapus - $e", level: 1);
    }
  }

  // --- 6. FUNGSI AUTO-SYNC (OFFLINE TO ONLINE) ---
  Future<void> syncPendingData() async {
    if (_myBox.isEmpty) return;
    
    final teamId = _myBox.values.first.teamId;

    try {
      // 1. Ambil daftar catatan yang sudah berhasil masuk ke Cloud
      final cloudData = await MongoService().getLogs(teamId);
      final cloudIds = cloudData.map((e) => e.id).toSet();

      // 2. Cari catatan di lokal (Hive) yang ID-nya belum ada di Cloud
      final pendingLogs = _myBox.values.where((log) => !cloudIds.contains(log.id)).toList();

      // Kalau tidak ada yang tertunda, hentikan fungsi
      if (pendingLogs.isEmpty) return;

      // 3. Unggah data yang tertunda satu per satu ke MongoDB
      for (var log in pendingLogs) {
        await MongoService().insertLog(log); 
      }

      // 4. Muat ulang data agar tampilan dan ID tersinkronisasi sempurna
      await loadLogs(teamId);
      await LogHelper.writeLog("AUTO-SYNC: Berhasil mengunggah ${pendingLogs.length} catatan.", level: 2);
    } catch (e) {
      await LogHelper.writeLog("AUTO-SYNC: Gagal - $e", level: 1);
    }
  }
}
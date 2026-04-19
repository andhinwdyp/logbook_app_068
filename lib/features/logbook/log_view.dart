import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'package:logbook_app_068/features/auth/login_view.dart';
import 'package:logbook_app_068/services/mongo_service.dart';
import 'package:logbook_app_068/helpers/log_helper.dart';
import 'package:logbook_app_068/features/logbook/log_editor_page.dart';
import 'package:logbook_app_068/features/vision/vision_view.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  late final Map<String, dynamic> currentUser;

  bool _isLoading = false;

  static const _bgColor = Color(0xFFFFF6E5);
  static const _primaryTextColor = Color(0xFF4A4A4A);
  static const _pinkColor = Color(0xFFF8C8DC);
  static const _greenColor = Color(0xFFB8E0D2);

  @override
  void initState() {
    super.initState();
    currentUser = {
      'uid': widget.username,
      'username': widget.username,
      'teamId': 'Kelompok_Praktikum_01', 
      'role': widget.username.toLowerCase() == 'admin' ? 'Ketua' : 'Anggota',
    };
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi ke MongoDB Atlas gagal: Timeout"),
      );
      await _controller.loadLogs(currentUser['teamId']);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 4) return 'Selamat Malam';
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tugas': return Colors.blue.shade200;
      case 'Reminder': return Colors.orange.shade200;
      case 'Urgent': return Colors.red.shade200;
      case 'Pribadi': default: return _greenColor;
    }
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: currentUser,
        ),
      ),
    );
  }

  // --- [BARU] FUNGSI MODE BACA (READ-ONLY BOTTOM SHEET) ---
  void _showLogDetail(LogModel log, Color catColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Biar layarnya bisa memanjang kalau teksnya banyak
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // Buka sebesar 60% layar
          maxChildSize: 0.9, // Maksimal mentok 90% layar
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Kategori & Tombol Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(15)),
                        child: Text(log.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Judul & Info Penulis
                  Text(log.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text("Oleh: ${log.authorId}", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 15),
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(DateFormat('dd MMM yyyy').format(DateTime.parse(log.date)), style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  // Isi Catatan (Render Markdown Lengkap)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: MarkdownBody(
                        data: log.description, // Teks yang panjang banget akan dirender rapi di sini
                        selectable: true, // Biar tamunya bisa copy-paste teksnya kalau butuh
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // --------------------------------------------------------

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("${_getGreeting()}, ${widget.username} [${currentUser['role']}]",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: _bgColor,
        foregroundColor: _primaryTextColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent),
            tooltip: 'Buka Smart-Patrol Vision',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisionView()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Color(0xFFFA8072)), onPressed: _handleLogout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _pinkColor,
        elevation: 0,
        onPressed: () => _goToEditor(),
        icon: const Icon(Icons.add, color: _primaryTextColor),
        label: const Text("Tambah Catatan", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                hintText: "Cari judul catatan...",
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF8C8DC)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFF8C8DC), width: 2)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: _pinkColor), SizedBox(height: 16), Text("Menghubungkan ke MongoDB Atlas...", style: TextStyle(color: Colors.grey))]))
                : ValueListenableBuilder<List<LogModel>>(
                    valueListenable: _controller.filteredLogsNotifier,
                    builder: (context, currentLogs, child) {
                      return RefreshIndicator(
                        color: _pinkColor,
                        onRefresh: _initDatabase,
                        child: currentLogs.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 50),
                                  Center(
                                    child: Column(
                                      children: [
                                        Image.network(
                                          "https://i.pinimg.com/1200x/51/47/cf/5147cfb30a10c2ba853db8d3094db2e4.jpg", 
                                          height: 200,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.cloud_off_rounded, size: 100, color: Color(0xFFF8C8DC)
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text("Belum ada catatan di tim ini.\nYuk buat catatan pertama!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 80),
                                itemCount: currentLogs.length,
                                itemBuilder: (context, index) {
                                  final log = currentLogs[index];
                                  final catColor = _getCategoryColor(log.category);

                                  final bool isOwner = log.authorId == currentUser['uid'];

                                  // Filter Privasi
                                  if (!isOwner && !log.isPublic) return const SizedBox.shrink(); 

                                  final bool canEdit = isOwner; 
                                  final bool canDelete = isOwner;

                                  return Dismissible(
                                    key: Key(log.id ?? log.date),
                                    direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
                                    background: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(15)),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (direction) async {
                                      int realIndex = _controller.logsNotifier.value.indexOf(log);
                                      if(realIndex != -1) await _controller.removeLog(realIndex); 
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: catColor.withValues(alpha: 0.5), width: 1.5)),
                                      elevation: 2,
                                      shadowColor: catColor.withValues(alpha: 0.2),
                                      child: ListTile(
                                        // [BARU] Pemicu Layar Mode Baca Saat Kartu Ditekan
                                        onTap: () => _showLogDetail(log, catColor), 
                                        
                                        contentPadding: const EdgeInsets.all(15),
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(color: catColor.withValues(alpha: 0.3), shape: BoxShape.circle),
                                          child: Icon(log.id != null ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined, color: catColor.withValues(alpha: 0.8)),
                                        ),
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(10)),
                                                  child: Text(log.category, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(log.isPublic ? Icons.public : Icons.lock_outline, size: 14, color: log.isPublic ? Colors.green : Colors.grey),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Oleh: ${log.authorId}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _pinkColor)),
                                            Text(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(log.date)), style: const TextStyle(fontSize: 10)),
                                            Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                        trailing: canEdit
                                            ? IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent), onPressed: () => _goToEditor(log: log, index: index))
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
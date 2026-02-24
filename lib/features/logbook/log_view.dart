import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'package:logbook_app_068/features/auth/login_view.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  static const _bgColor = Color(0xFFFFF6E5);
  static const _primaryTextColor = Color(0xFF4A4A4A);
  static const _pinkColor = Color(0xFFF8C8DC);
  static const _greenColor = Color(0xFFB8E0D2);

  @override
  void initState() {
    super.initState();
    _controller.loadData(widget.username);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 4) return 'Selamat Malam';
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // --- DIALOG TAMBAH DATA ---
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _greenColor, elevation: 0),
            onPressed: () {
              if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                _controller.addLog(_titleController.text, _contentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG EDIT DATA ---
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            const SizedBox(height: 10),
            TextField(controller: _contentController, maxLines: 3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _pinkColor, elevation: 0),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.updateLog(index, _titleController.text, _contentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Update", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false, 
              );
            },
            child: const Text(
              "Ya, Keluar", 
              style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold),
            ),
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
        title: Text(
          "${_getGreeting()}, ${widget.username}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: _bgColor,
        foregroundColor: _primaryTextColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _pinkColor,
        elevation: 0,
        highlightElevation: 0,
        onPressed: _showAddLogDialog,
        icon: const Icon(Icons.add, color: _primaryTextColor),
        label: const Text(
          "Tambah Catatan", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)
        ),
      ),
      
      // --- THE MAGIC: VALUE LISTENABLE BUILDER ---
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, currentLogs, child) {
          if (currentLogs.isEmpty) {
            return const Center(
              child: Text("Belum ada catatan logbook.\nYuk mulai mencatat!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final log = currentLogs[index];

              return Dismissible(
                key: Key(log.date),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _controller.removeLog(index);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catatan dihapus"), behavior: SnackBarBehavior.floating));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFEAF6F1), shape: BoxShape.circle),
                      child: const Icon(Icons.note_alt_outlined, color: _greenColor),
                    ),
                    title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                      onPressed: () => _showEditLogDialog(index, log),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

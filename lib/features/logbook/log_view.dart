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

  String _selectedCategory = 'Pribadi'; 
  final List<String> _categories = ['Pribadi', 'Reminder', 'Tugas', 'Urgent'];

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tugas':
        return Colors.blue.shade200;
      case 'Reminder':
        return Colors.orange.shade200;
      case 'Urgent':
        return Colors.red.shade200;
      case 'Pribadi':
      default:
        return _greenColor;
    }
  }

  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() => _selectedCategory = newValue);
                    }
                  },
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
                style: ElevatedButton.styleFrom(backgroundColor: _pinkColor, elevation: 0),
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                    _controller.addLog(_titleController.text, _contentController.text, _selectedCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;

    if (_categories.contains(log.category)) {
      _selectedCategory = log.category;
    } else {
      _selectedCategory = 'Pribadi'; 
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Edit Catatan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() => _selectedCategory = newValue);
                    }
                  },
                ),
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
                    _controller.updateLog(index, _titleController.text, _contentController.text, _selectedCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300, elevation: 0,),
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
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFA8072)),
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

      body: Column(
        children: [
          // 1. KOTAK PENCARIAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                hintText: "Cari judul catatan...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF8C8DC)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFF8C8DC), width: 2),
                ),
              ),
            ),
          ),

          // 2. DAFTAR CATATAN
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogsNotifier, 
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://i.pinimg.com/1200x/51/47/cf/5147cfb30a10c2ba853db8d3094db2e4.jpg", 
                          height: 200,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator(color: Color(0xFFF8C8DC))),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.auto_stories_rounded, 
                            size: 100, 
                            color: Color(0xFFF8C8DC)
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Oops, catatannya belum ada nih!",
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 80),
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];

                    final catColor = _getCategoryColor(log.category);

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
                        int realIndex = _controller.logsNotifier.value.indexOf(log);
                        if(realIndex != -1) {
                          _controller.removeLog(realIndex); 
                        }
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catatan dihapus"), behavior: SnackBarBehavior.floating)); 
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: catColor.withValues(alpha: 0.5), width: 1.5), 
                        ),
                        elevation: 2,
                        shadowColor: catColor.withValues(alpha: 0.2),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: catColor.withValues(alpha: 0.3), shape: BoxShape.circle),
                            child: Icon(Icons.note_alt_outlined, color: catColor.withValues(alpha: 0.8)),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: catColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  log.category, 
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(log.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                            onPressed: () {
                              int realIndex = _controller.logsNotifier.value.indexOf(log);
                              if(realIndex != -1) {
                                _showEditLogDialog(realIndex, log); 
                              }
                            }
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
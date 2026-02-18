import 'package:flutter/material.dart';
import 'counter_controller.dart';
import 'history_widget.dart';
import 'package:logbook_app_068/features/auth/login_view.dart'; 

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  static const _bgColor = Color(0xFFFFF6E5);
  static const _primaryTextColor = Color(0xFF4A4A4A);
  static const _pinkColor = Color(0xFFF8C8DC);
  static const _greenColor = Color(0xFFB8E0D2);

  // --- [BARU] FUNGSI LOAD DATA SAAT APLIKASI DIBUKA ---
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadData();
    setState(() {});
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Data"),
        content: const Text("Yakin ingin menghapus semua data?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak, Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _pinkColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _controller.reset());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("DATA BERHASIL DIRESET"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Ya, Hapus", style: TextStyle(color: _primaryTextColor)),
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
              backgroundColor: const Color(0xFFB8E0D2), 
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
            child: const Text("Ya, Keluar", style: TextStyle(color: Color(0xFF4A4A4A))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTotalDisplay(),
          _buildStepSlider(),
          _buildHistorySection(),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "HALO, ${widget.username.toUpperCase()}", 
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: _bgColor,
      foregroundColor: _primaryTextColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _confirmReset,
          color: const Color(0xFF757575),
          tooltip: "Reset Data",
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: _handleLogout, 
          color: const Color(0xFFFA8072), 
          tooltip: "Logout",
        ),
        const SizedBox(width: 10), 
      ],
    );
  }

  Widget _buildTotalDisplay() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL HITUNG",
            style: TextStyle(
              letterSpacing: 2,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_controller.value}',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PILIH STEP",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _greenColor,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: _pinkColor,
                    overlayColor: _pinkColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    min: 1,
                    max: 10, 
                    divisions: 9,
                    value: _controller.step.toDouble(),
                    label: _controller.step.toString(),
                    onChanged: (value) {
                      setState(() {
                        _controller.setStep(value.toInt());
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  _controller.step.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "HISTORY",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return HistoryTile(
                    log: _controller.history[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _pinkColor,
                foregroundColor: _primaryTextColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () =>
                  setState(() => _controller.decrement()),
              icon: const Icon(Icons.remove),
              label: const Text("KURANG"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _greenColor,
                foregroundColor: _primaryTextColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () =>
                  setState(() => _controller.increment()),
              icon: const Icon(Icons.add),
              label: const Text("TAMBAH"),
            ),
          ),
        ],
      ),
    );
  }
}
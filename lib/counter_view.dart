import 'package:flutter/material.dart';
import 'counter_controller.dart';
import 'history_widget.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("dzikir akan di reset"),
        content: const Text("yakin menghapus dzikir?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("tidak"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8C8DC),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _controller.reset());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("DZIKIR BERHASIL DI-RESET!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("ya"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),
      appBar: AppBar(
        title: const Text(
          "DZIKIR COUNTER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFFF6E5),
        foregroundColor: const Color(0xFF4A4A4A),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFF757575)),
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: Column(
        children: [

          // DISPLAY UTAMA
          Container(
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
                  "TOTAL DZIKIR",
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${_controller.value}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "PILIH STEP",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A4A4A),
        ),
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFB8E0D2),
                inactiveTrackColor: const Color(0xFFE0E0E0),
                thumbColor: const Color(0xFFF8C8DC),
                overlayColor: const Color(0xFFF8C8DC).withValues(alpha: 0.2),
              ),
              child: Slider(
                min: 1,
                max: 100,
                divisions: 99,
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
          Container(
            width: 45,
            alignment: Alignment.center,
            child: Text(
              _controller.step.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          )
        ],
      ),
    ],
  ),
),


          const SizedBox(height: 10),

          // HISTORY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("HISTORY",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _controller.history.length,
                      itemBuilder: (context, index) {
                        return HistoryTile(
                            log: _controller.history[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BUTTON BAWAH
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [

                // KURANG
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8C8DC),
                      foregroundColor: const Color(0xFF4A4A4A),
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
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

                // TAMBAH
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8E0D2),
                      foregroundColor: const Color(0xFF4A4A4A),
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
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
          ),
        ],
      ),
    );
  }
}
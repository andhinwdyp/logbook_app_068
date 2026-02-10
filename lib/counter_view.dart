import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: Task 2 (History)"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Tambahan tombol Reset kecil di pojok kanan atas
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _controller.reset()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Biar gak mepet pinggir
        child: Column(
          children: [
            // --- BAGIAN ATAS (Counter & Slider) ---
            const Text('Total Hitungan:', style: TextStyle(fontSize: 18)),
            Text(
              '${_controller.value}',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            const Text("Atur Langkah (Step):"),
            Slider(
              min: 1, max: 10, divisions: 9,
              label: _controller.step.toString(),
              value: _controller.step.toDouble(),
              onChanged: (v) => setState(() => _controller.setStep(v.toInt())),
            ),
            
            const Divider(thickness: 2, height: 40), // Garis pembatas

            // --- BAGIAN BAWAH (TASK 2: HISTORY LIST) ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Riwayat Aktivitas (Maks 5):", 
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            
            // PENTING: Gunakan Expanded agar ListView muncul
            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2, // Efek bayangan dikit
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.blue),
                      title: Text(_controller.history[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tombol Kurang
          FloatingActionButton(
            heroTag: "btnDec", // Wajib beda tag kalau ada 2 FAB
            onPressed: () => setState(() => _controller.decrement()),
            backgroundColor: Colors.red[100],
            child: const Icon(Icons.remove, color: Colors.red),
          ),
          const SizedBox(height: 10),
          // Tombol Tambah
          FloatingActionButton(
            heroTag: "btnInc",
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'counter_controller.dart'; // Wajib import controller

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  // Instansiasi Controller (Menghubungkan Otak ke Wajah)
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: SRP Version"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Tampilan Nilai Counter ---
            const Text('Total Hitungan:'),
            Text(
              '${_controller.value}', // Ambil nilai dari controller
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: 30), // Jarak pemanis

            // --- Fitur Task 1: Slider Pengatur Step ---
            const Text("Atur Langkah (Step):"),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              label: _controller.step.toString(),
              value: _controller.step.toDouble(),
              onChanged: (double newValue) {
                setState(() {
                  _controller.setStep(newValue.toInt());
                });
              },
            ),
            Text("Step saat ini: ${_controller.step}"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil fungsi increment di controller saat tombol ditekan
          setState(() {
            _controller.increment();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
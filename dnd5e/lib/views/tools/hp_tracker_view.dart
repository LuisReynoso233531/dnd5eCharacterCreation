import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/tools/hp_tracker_view_model.dart';

class HpTrackerView extends StatefulWidget {
  const HpTrackerView({super.key});

  @override
  State<HpTrackerView> createState() => _HpTrackerViewState();
}

class _HpTrackerViewState extends State<HpTrackerView> {
  final TextEditingController _maxHpController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _maxHpController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HpTrackerViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text("HP Tracker"),
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Reset All",
                onPressed: () {
                  vm.reset();
                  _maxHpController.clear();
                  _amountController.clear();
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // ─── 1. MAX HP CONFIGURATION ───
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: vm.maxHp == 0
                        ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _maxHpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Set Max HP",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.shield),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                ),
                                onPressed: () {
                                  final val = int.tryParse(_maxHpController.text) ?? 0;
                                  if (val > 0) vm.setMaxHp(val);
                                },
                                child: const Text("Save"),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Max Hit Points:",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text(
                                "${vm.maxHp} HP",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black87),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // ─── 2. NUMERIC REPORT LOG ───
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    "Log",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: vm.reportHistory.isEmpty
                        ? const Center(
                            child: Text(
                              "0",
                              style: TextStyle(color: Colors.black26, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: vm.reportHistory.length,
                            itemBuilder: (context, index) {
                              final logLine = vm.reportHistory[index];
                              
                              // Color según el signo matemático de la línea
                              Color logColor = Colors.blueGrey;
                              if (logLine.startsWith('-')) {
                                logColor = Colors.red.shade700;
                              } else if (logLine.startsWith('+')) {
                                logColor = Colors.green.shade700;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  logLine,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: logColor,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── 3. CURRENT HP DISPLAY ───
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: vm.currentHp == 0 ? Colors.red.shade50 : Color.fromARGB(255, 253, 253, 253),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: vm.currentHp == 0 ? Colors.red.shade300 : Color.fromARGB(255, 255, 0, 0),
                      width: 1.5
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "REMAINING HP",
                        style: TextStyle(letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${vm.currentHp} / ${vm.maxHp}",
                        style: TextStyle(
                          fontSize: 38, 
                          fontWeight: FontWeight.w500, 
                          color: vm.currentHp == 0 ? Colors.red.shade800 : Color.fromARGB(255, 0, 0, 0)
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── 4. CONTROLS (- / VALUE / +) ───
                Row(
                  children: [
                    // Damage Button (-)
                    Expanded(
                      child: InkWell(
                        onTap: vm.maxHp == 0 ? null : () {
                          final amount = int.tryParse(_amountController.text) ?? 0;
                          if (amount > 0) {
                            vm.applyDamage(amount);
                            _amountController.clear();
                          }
                        },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: vm.maxHp == 0 ? Colors.grey : Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Value Input
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _amountController,
                        enabled: vm.maxHp > 0,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: "0",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Healing Button (+)
                    Expanded(
                      child: InkWell(
                        onTap: vm.maxHp == 0 ? null : () {
                          final amount = int.tryParse(_amountController.text) ?? 0;
                          if (amount > 0) {
                            vm.applyHealing(amount);
                            _amountController.clear();
                          }
                        },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: vm.maxHp == 0 ? Colors.grey : Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
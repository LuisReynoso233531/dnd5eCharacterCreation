import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../view_models/tools/dice_roller_view_model.dart'; // Ajusta la ruta a tu proyecto

class DiceRollerView extends StatefulWidget {
  const DiceRollerView({super.key});

  @override
  State<DiceRollerView> createState() => _DiceRollerViewState();
}

class _DiceRollerViewState extends State<DiceRollerView> {
  final TextEditingController _qtyController = TextEditingController(text: "1");

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // Modifica la cantidad actual de forma segura y refresca la UI local inmediatamente
  void _updateQuantity(int change) {
    setState(() {
      final current = int.tryParse(_qtyController.text) ?? 1;
      final newValue = (current + change).clamp(1, 99);
      _qtyController.text = newValue.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiceRollerViewModel(),
      child: Consumer<DiceRollerViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: AppBar(
              title: const Text("Dice Roller"),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "Reset All",
                  onPressed: () {
                    vm.reset();
                    setState(() {
                      _qtyController.text = "1";
                    });
                  },
                )
              ],
            ),
            // ─── SAFE AREA: Evita que choque con muescas o barras de gestos ───
            body: SafeArea(
              child: Padding(
                // Aumentamos el padding general a 20 para dar más "aire" con los bordes
                padding: const EdgeInsets.all(20.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // ─── 1. QUANTITY SELECTOR (CONTROLS) ───
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Dice Quantity:",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _updateQuantity(-1),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _qtyController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(1),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── 2. RPG DICE GRID SELECTION ───
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [4, 6, 8, 10, 12, 20, 100].map((faces) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            // SOLUCIÓN: Extraemos el valor del input en tiempo real (justo al presionar)
                            final int currentQuantity = int.tryParse(_qtyController.text) ?? 1;
                            vm.rollDice(currentQuantity, faces);
                          },
                          child: Text(
                            "d$faces",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ─── 3. RESULTS & INDIVIDUAL DICE BOARD ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "TOTAL RESULT",
                            style: TextStyle(letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45),
                          ),
                          Text(
                            "${vm.total}",
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                          const Divider(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: vm.currentRolls.isEmpty
                                ? const Center(child: Text("0", style: TextStyle(color: Colors.black26, fontSize: 20, fontWeight: FontWeight.bold)))
                                : SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: vm.currentRolls.map((val) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Text(
                                            "$val",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── 4. HISTORY LOG AREA ───
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
                        child: vm.rollHistory.isEmpty
                            ? const Center(
                                child: Text(
                                  "0",
                                  style: TextStyle(color: Colors.black26, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: vm.rollHistory.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      vm.rollHistory[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: Colors.blueGrey.shade700,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
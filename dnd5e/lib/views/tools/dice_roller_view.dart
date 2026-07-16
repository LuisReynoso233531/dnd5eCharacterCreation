import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../../view_models/tools/dice_roller_view_model.dart';

class DiceRollerView extends StatefulWidget {
  const DiceRollerView({super.key});

  @override
  State<DiceRollerView> createState() => _DiceRollerViewState();
}

class _DiceRollerViewState extends State<DiceRollerView> {
  final TextEditingController _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _updateQuantity(int change) {
    setState(() {
      final current = int.tryParse(_qtyController.text) ?? 1;
      _qtyController.text = (current + change).clamp(1, 99).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiceRollerViewModel(),
      child: Consumer<DiceRollerViewModel>(
        builder: (context, vm, child) {
          final accent = context.dndColors.info;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dice Roller'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset all',
                  onPressed: () {
                    vm.reset();
                    setState(() => _qtyController.text = '1');
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dice Quantity:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.dndColors.mutedText,
                              ),
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [4, 6, 8, 10, 12, 20, 100].map((faces) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: context.dndColors.onInfo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            final quantity =
                                int.tryParse(_qtyController.text) ?? 1;
                            vm.rollDice(quantity, faces);
                          },
                          child: Text(
                            'd$faces',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.dndColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.dndColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL RESULT',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.dndColors.mutedText,
                            ),
                          ),
                          Text(
                            '${vm.total}',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const Divider(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: vm.currentRolls.isEmpty
                                ? Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: context.dndColors.subtleText,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: vm.currentRolls.map((value) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.dndColors.infoContainer,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: 0.45,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '$value',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: context
                                                  .dndColors.onInfoContainer,
                                              fontSize: 14,
                                            ),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        'Log',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.dndColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.dndColors.border),
                        ),
                        child: vm.rollHistory.isEmpty
                            ? Center(
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: context.dndColors.subtleText,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: vm.rollHistory.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      vm.rollHistory[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: context.dndColors.mutedText,
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

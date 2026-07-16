import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
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
        final isDown = vm.currentHp == 0 && vm.maxHp > 0;
        return Scaffold(
          appBar: AppBar(
            title: const Text('HP Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset all',
                onPressed: () {
                  vm.reset();
                  _maxHpController.clear();
                  _amountController.clear();
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: vm.maxHp == 0
                        ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _maxHpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Set Max HP',
                                    prefixIcon: Icon(Icons.shield),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  final value =
                                      int.tryParse(_maxHpController.text) ?? 0;
                                  if (value > 0) vm.setMaxHp(value);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Max Hit Points:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.dndColors.mutedText,
                                ),
                              ),
                              Text(
                                '${vm.maxHp} HP',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
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
                    child: vm.reportHistory.isEmpty
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
                            itemCount: vm.reportHistory.length,
                            itemBuilder: (context, index) {
                              final logLine = vm.reportHistory[index];
                              var logColor = context.dndColors.mutedText;
                              if (logLine.startsWith('-')) {
                                logColor = context.dndColors.danger;
                              } else if (logLine.startsWith('+')) {
                                logColor = context.dndColors.success;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isDown
                        ? context.dndColors.dangerContainer
                        : context.dndColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDown
                          ? context.dndColors.danger
                          : context.dndColors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'REMAINING HP',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDown
                              ? context.dndColors.onDangerContainer
                              : context.dndColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vm.currentHp} / ${vm.maxHp}',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          color: isDown
                              ? context.dndColors.onDangerContainer
                              : context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: vm.maxHp == 0
                            ? null
                            : () {
                                final amount =
                                    int.tryParse(_amountController.text) ?? 0;
                                if (amount > 0) {
                                  vm.applyDamage(amount);
                                  _amountController.clear();
                                }
                              },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: vm.maxHp == 0
                                ? context.dndColors.surfaceStrong
                                : context.dndColors.danger,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: vm.maxHp == 0
                                ? context.dndColors.subtleText
                                : context.dndColors.onDanger,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _amountController,
                        enabled: vm.maxHp > 0,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: vm.maxHp == 0
                            ? null
                            : () {
                                final amount =
                                    int.tryParse(_amountController.text) ?? 0;
                                if (amount > 0) {
                                  vm.applyHealing(amount);
                                  _amountController.clear();
                                }
                              },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: vm.maxHp == 0
                                ? context.dndColors.surfaceStrong
                                : context.dndColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add,
                            color: vm.maxHp == 0
                                ? context.dndColors.subtleText
                                : context.dndColors.onSuccess,
                            size: 28,
                          ),
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

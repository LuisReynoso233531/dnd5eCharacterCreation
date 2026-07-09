import 'package:flutter/material.dart';
import '../../../../view_models/character/character_inventory_view_model.dart';

class MoneySection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  const MoneySection({super.key, required this.inv});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MoneyField(
          label: 'gp',
          value: inv.gp,
          onChanged: (v) => inv.updateMoney(newGp: v),
        ),
        _MoneyField(
          label: 'pp',
          value: inv.pp,
          onChanged: (v) => inv.updateMoney(newPp: v),
        ),
        _MoneyField(
          label: 'ep',
          value: inv.ep,
          onChanged: (v) => inv.updateMoney(newEp: v),
        ),
        _MoneyField(
          label: 'sp',
          value: inv.sp,
          onChanged: (v) => inv.updateMoney(newSp: v),
        ),
        _MoneyField(
          label: 'cp',
          value: inv.cp,
          onChanged: (v) => inv.updateMoney(newCp: v),
        ),
      ],
    );
  }
}


class _MoneyField extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(_MoneyField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != '${widget.value}') {
      _ctrl.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
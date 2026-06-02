import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../views/create_character/charecter_sheet_view.dart';

const _kRed = Color(0xFFE50914);

class CharacterInventoryView extends StatefulWidget {
  const CharacterInventoryView({super.key});
  @override
  State<CharacterInventoryView> createState() => _CharacterInventoryViewState();
}

class _CharacterInventoryViewState extends State<CharacterInventoryView> {
  final _toolController = TextEditingController();
  final _treasuresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterInventoryViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _toolController.dispose();
    _treasuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final inv = context.watch<CharacterInventoryViewModel>();

    final dexMod = vm.getModifier('Dexterity');
    final conMod = vm.getModifier('Constitution');
    final wisMod = vm.getModifier('Wisdom');
    final totalAC = inv.calculateTotalAC(
      dexMod: dexMod,
      conMod: conMod,
      wisMod: wisMod,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment'), backgroundColor: _kRed),
      body: inv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── CA Card ──────────────────────────────────────────────
                  _ACCard(totalAC: totalAC, inv: inv, vm: vm),
                  const SizedBox(height: 24),

                  // ── Background Equipment ──────────────────────────────────
                  if (inv.backgroundEquipmentText.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Background Equipment',
                      subtitle: 'Choose the equipment.',
                      icon: Icons.history_edu,
                    ),
                    const SizedBox(height: 8),
                    _BackgroundEquipmentCard(text: inv.backgroundEquipmentText),
                    const SizedBox(height: 24),
                  ],

                  // ── Armors ───────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Armors',
                    subtitle: 'Choose the equipment.',
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 12),
                  _ArmorSection(inv: inv, dexMod: dexMod),
                  const SizedBox(height: 24),

                  // ── Weapons ──────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Weapons',
                    subtitle: 'Choose the equipment.',
                    icon: Icons.gavel,
                  ),
                  const SizedBox(height: 12),
                  _WeaponSection(inv: inv),
                  const SizedBox(height: 24),

                  // ── Tools ────────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Tools',
                    subtitle: 'Add your tools.',
                    icon: Icons.handyman,
                  ),
                  const SizedBox(height: 12),
                  _ToolSection(inv: inv, controller: _toolController),
                  const SizedBox(height: 24),

                  // ── Money ────────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Money',
                    subtitle: 'Your current wealth.',
                    icon: Icons.monetization_on,
                  ),
                  const SizedBox(height: 12),
                  _MoneySection(inv: inv),
                  const SizedBox(height: 24),

                  // ── Treasures & Magic Items ───────────────────────────────
                  _SectionHeader(
                    title: 'Treasures & Magic Items',
                    subtitle: '',
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _treasuresController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter treasures and magic items...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: inv.updateTreasures,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CharacterSheetView(),
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 22),
                      label: const Text(
                        'Generate Character Sheet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── CA Card ──────────────────────────────────────────────────────────────────
class _ACCard extends StatelessWidget {
  final int totalAC;
  final CharacterInventoryViewModel inv;
  final CreateCharacterViewModel vm;

  const _ACCard({required this.totalAC, required this.inv, required this.vm});

  @override
  Widget build(BuildContext context) {
    final armor = inv.equippedArmor;
    final shield = inv.equippedShield;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kRed.withOpacity(0.85), _kRed.withOpacity(0.45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Armor Class',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '$totalAC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _acChip(armor?.name ?? 'Unarmored'),
              if (shield != null) ...[
                const SizedBox(height: 4),
                _acChip('+ ${shield.name}'),
              ],
              if (armor?.stealthDisadvantage == true) ...[
                const SizedBox(height: 4),
                _acChip('⚠ Stealth disadv.'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _acChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Background Equipment Card ────────────────────────────────────────────────
class _BackgroundEquipmentCard extends StatelessWidget {
  final String text;
  const _BackgroundEquipmentCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history_edu, color: Colors.blueGrey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Armor Section ────────────────────────────────────────────────────────────
class _ArmorSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  final int dexMod;

  const _ArmorSection({required this.inv, required this.dexMod});

  String _armorLabel(ArmorModel a) {
    final ac = a.calculateAC(dexMod: dexMod);
    return '${a.name}, CA $ac (${a.cost})';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Armadura principal
        _StyledDropdown<ArmorModel>(
          value: inv.equippedArmor,
          items: [null, ...inv.regularArmors],
          labelBuilder: (a) => a == null ? '-- No armor' : _armorLabel(a),
          onChanged: inv.equipArmor,
          icon: Icons.security,
        ),
        const SizedBox(height: 10),

        // Escudo
        _StyledDropdown<ArmorModel>(
          value: inv.equippedShield,
          items: [null, ...inv.shields],
          labelBuilder: (s) => s == null
              ? '-- No shield'
              : '${s.name}, CA ${s.acString} (${s.cost})',
          onChanged: inv.equipShield,
          icon: Icons.shield,
        ),

        // Aviso de requisito de fuerza
        if (inv.equippedArmor?.strengthReq != null &&
            inv.equippedArmor!.strengthReq! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Requires STR ${inv.equippedArmor!.strengthReq}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Weapon Section ───────────────────────────────────────────────────────────
class _WeaponSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;

  const _WeaponSection({required this.inv});

  String _weaponLabel(WeaponModel w) {
    final dmg = w.damageDice.isNotEmpty ? w.damageDice : '-';
    return '${w.name} $dmg (${w.cost})';
  }

  @override
  Widget build(BuildContext context) {
    final allWeapons = inv.allWeapons;

    return Column(
      children: [
        // Lista de armas seleccionadas
        ...inv.weaponEntries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gavel, size: 16, color: _kRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.weapon.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${entry.weapon.damageDice} ${entry.weapon.damageType}'
                                '${entry.weapon.properties.isNotEmpty ? ' · ${entry.weapon.properties.take(2).join(', ')}' : ''}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Cantidad
                _QuantityPicker(
                  value: entry.quantity,
                  onDecrement: () => inv.updateWeaponQuantity(
                    entry.weapon.slug,
                    entry.quantity - 1,
                  ),
                  onIncrement: () => inv.updateWeaponQuantity(
                    entry.weapon.slug,
                    entry.quantity + 1,
                  ),
                ),
                const SizedBox(width: 4),

                // Quitar
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: _kRed),
                  onPressed: () => inv.removeWeapon(entry.weapon.slug),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown para agregar arma
        _WeaponAddDropdown(allWeapons: allWeapons, inv: inv),
      ],
    );
  }
}

class _WeaponAddDropdown extends StatefulWidget {
  final List<WeaponModel> allWeapons;
  final CharacterInventoryViewModel inv;

  const _WeaponAddDropdown({required this.allWeapons, required this.inv});

  @override
  State<_WeaponAddDropdown> createState() => _WeaponAddDropdownState();
}

class _WeaponAddDropdownState extends State<_WeaponAddDropdown> {
  WeaponModel? _pending;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StyledDropdown<WeaponModel>(
          value: _pending,
          items: [null, ...widget.allWeapons],
          labelBuilder: (w) => w == null
              ? '-- Select weapon to add'
              : '${w.name} ${w.damageDice} (${w.cost})',
          onChanged: (w) => setState(() => _pending = w),
          icon: Icons.add_circle_outline,
        ),
        if (_pending != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                widget.inv.addWeapon(_pending!);
                setState(() => _pending = null);
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text('Add Weapon'),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Tool Section ─────────────────────────────────────────────────────────────
class _ToolSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  final TextEditingController controller;

  const _ToolSection({required this.inv, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Herramientas existentes
        ...inv.tools.map(
          (tool) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _StyledDropdown<String>(
              value: tool,
              items: inv.tools,
              labelBuilder: (t) => t ?? '',
              onChanged: (_) {},
              icon: Icons.handyman,
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: _kRed),
                onPressed: () => inv.removeTool(tool),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),

        // Agregar herramienta
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '-- Tools',
                  prefixIcon: const Icon(Icons.handyman, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  inv.addTool(controller.text);
                  controller.clear();
                }
              },
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Money Section ────────────────────────────────────────────────────────────
class _MoneySection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  const _MoneySection({required this.inv});

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

// ─── Quantity Picker ──────────────────────────────────────────────────────────
class _QuantityPicker extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityPicker({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove, size: 14),
              onPressed: onDecrement,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(
            width: 28,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 14),
              onPressed: onIncrement,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Styled Dropdown genérico ─────────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T?> items;
  final String Function(T?) labelBuilder;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final Widget? trailing;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          labelBuilder(item),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

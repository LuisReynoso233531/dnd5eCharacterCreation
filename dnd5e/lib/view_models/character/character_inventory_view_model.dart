import 'package:flutter/material.dart';
import '../../data/repositories/character_repository.dart';

// ─── Modelos ──────────────────────────────────────────────────────────────────

class ArmorModel {
  final String slug;
  final String name;
  final String category;
  final int baseAc;
  final bool plusDexMod;
  final bool plusConMod;
  final bool plusWisMod;
  final int plusFlatMod;
  final int plusMax; // 0 = sin límite
  final String acString;
  final int? strengthReq;
  final String cost;
  final bool stealthDisadvantage;

  const ArmorModel({
    required this.slug,
    required this.name,
    required this.category,
    required this.baseAc,
    required this.plusDexMod,
    required this.plusConMod,
    required this.plusWisMod,
    required this.plusFlatMod,
    required this.plusMax,
    required this.acString,
    required this.strengthReq,
    required this.cost,
    required this.stealthDisadvantage,
  });

  factory ArmorModel.fromJson(Map<String, dynamic> j) => ArmorModel(
        slug: j['slug'] ?? '',
        name: j['name'] ?? '',
        category: j['category'] ?? '',
        baseAc: j['base_ac'] ?? 0,
        plusDexMod: j['plus_dex_mod'] ?? false,
        plusConMod: j['plus_con_mod'] ?? false,
        plusWisMod: j['plus_wis_mod'] ?? false,
        plusFlatMod: j['plus_flat_mod'] ?? 0,
        plusMax: j['plus_max'] ?? 0,
        acString: j['ac_string'] ?? '',
        strengthReq: j['strength_requirement'],
        cost: j['cost'] ?? '',
        stealthDisadvantage: j['stealth_disadvantage'] ?? false,
      );

  /// Calcula CA real dado Dex/Con/Wis modifier
  int calculateAC({int dexMod = 0, int conMod = 0, int wisMod = 0}) {
    int ac = baseAc + plusFlatMod;
    if (plusDexMod) {
      ac += plusMax > 0 ? dexMod.clamp(-99, plusMax) : dexMod;
    }
    if (plusConMod) ac += conMod;
    if (plusWisMod) ac += wisMod;
    return ac;
  }
}

class WeaponModel {
  final String slug;
  final String name;
  final String category;
  final String cost;
  final String damageDice;
  final String damageType;
  final String weight;
  final List<String> properties;

  const WeaponModel({
    required this.slug,
    required this.name,
    required this.category,
    required this.cost,
    required this.damageDice,
    required this.damageType,
    required this.weight,
    required this.properties,
  });

  factory WeaponModel.fromJson(Map<String, dynamic> j) => WeaponModel(
        slug: j['slug'] ?? '',
        name: j['name'] ?? '',
        category: j['category'] ?? '',
        cost: j['cost'] ?? '',
        damageDice: j['damage_dice'] ?? '',
        damageType: j['damage_type'] ?? '',
        weight: j['weight'] ?? '',
        properties: List<String>.from(
            (j['properties'] as List? ?? []).map((e) => e.toString())),
      );

  bool get isMelee => category.toLowerCase().contains('melee');
  bool get isRanged => category.toLowerCase().contains('ranged');
  bool get isSimple => category.toLowerCase().contains('simple');
  bool get isMartial => category.toLowerCase().contains('martial');
}

// Entrada de arma en el inventario (puede tener cantidad)
class WeaponEntry {
  final WeaponModel weapon;
  int quantity;
  WeaponEntry({required this.weapon, this.quantity = 1});
}

// ─── ViewModel ───────────────────────────────────────────────────────────────

class CharacterInventoryViewModel extends ChangeNotifier {
  final CharacterRepository _repository;
  CharacterInventoryViewModel(this._repository);

  // ── Estado de carga ───────────────────────────────────────────────────────
  bool _isLoadingArmors = false;
  bool _isLoadingWeapons = false;
  String? _error;

  bool get isLoadingArmors => _isLoadingArmors;
  bool get isLoadingWeapons => _isLoadingWeapons;
  bool get isLoading => _isLoadingArmors || _isLoadingWeapons;
  String? get error => _error;
  String _backgroundEquipmentText = '';
  String get backgroundEquipmentText => _backgroundEquipmentText;

  // ── Datos de la API ───────────────────────────────────────────────────────
  List<ArmorModel> _allArmors = [];
  List<WeaponModel> _allWeapons = [];

  List<ArmorModel> get allArmors => _allArmors;
  List<WeaponModel> get allWeapons => _allWeapons;

  // ── Selecciones del usuario ───────────────────────────────────────────────

  // Armadura equipada (solo una + escudo opcional)
  ArmorModel? _equippedArmor;
  ArmorModel? _equippedShield;
  ArmorModel? get equippedArmor => _equippedArmor;
  ArmorModel? get equippedShield => _equippedShield;

  // Armas (múltiples con cantidad)
  final List<WeaponEntry> _weaponEntries = [];
  List<WeaponEntry> get weaponEntries => _weaponEntries;

  // Herramientas (texto libre)
  final List<String> _tools = [];
  List<String> get tools => _tools;

  // Dinero
  int gp = 0, pp = 0, ep = 0, sp = 0, cp = 0;

  // Tesoros y objetos mágicos (texto libre)
  String _treasuresText = '';
  String get treasuresText => _treasuresText;

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    await Future.wait([loadArmors(), loadWeapons()]);
  }

  Future<void> loadArmors() async {
    if (_allArmors.isNotEmpty) return;
    _isLoadingArmors = true;
    notifyListeners();
    try {
      final data = await _repository.getArmors();
      _allArmors = data.map((j) => ArmorModel.fromJson(j)).toList();
      // Ordenar: sin armadura primero, luego por categoría y nombre
      _allArmors.sort((a, b) {
        final catOrder = _categoryOrder(a.category) -
            _categoryOrder(b.category);
        return catOrder != 0 ? catOrder : a.name.compareTo(b.name);
      });
    } catch (e) {
      _error = 'Error loading armors: $e';
    } finally {
      _isLoadingArmors = false;
      notifyListeners();
    }
  }

  Future<void> loadWeapons() async {
    if (_allWeapons.isNotEmpty) return;
    _isLoadingWeapons = true;
    notifyListeners();
    try {
      // Cargar todas las páginas (son 2)
      final page1 = await _repository.getWeapons();
      final page2 = await _repository.getWeapons();
      _allWeapons = [...page1, ...page2]
          .map((j) => WeaponModel.fromJson(j))
          .toList();
      _allWeapons.sort((a, b) {
        final catOrder = _weaponCategoryOrder(a.category) -
            _weaponCategoryOrder(b.category);
        return catOrder != 0 ? catOrder : a.name.compareTo(b.name);
      });
    } catch (e) {
      _error = 'Error loading weapons: $e';
    } finally {
      _isLoadingWeapons = false;
      notifyListeners();
    }
  }

  // ── Armadura ──────────────────────────────────────────────────────────────

  void equipArmor(ArmorModel? armor) {
    _equippedArmor = armor;
    notifyListeners();
  }

  void equipShield(ArmorModel? shield) {
    _equippedShield = shield;
    notifyListeners();
  }

  /// CA total calculada con los mods del personaje
  int calculateTotalAC({int dexMod = 0, int conMod = 0, int wisMod = 0}) {
    int ac = _equippedArmor?.calculateAC(
          dexMod: dexMod, conMod: conMod, wisMod: wisMod) ??
        (10 + dexMod); // sin armadura = 10 + Dex

    // Escudo suma su flat_mod
    if (_equippedShield != null) {
      ac += _equippedShield!.plusFlatMod;
    }
    return ac;
  }

  // ── Armas ─────────────────────────────────────────────────────────────────

  void addWeapon(WeaponModel weapon) {
    final existing = _weaponEntries
        .where((e) => e.weapon.slug == weapon.slug)
        .firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _weaponEntries.add(WeaponEntry(weapon: weapon));
    }
    notifyListeners();
  }

  void removeWeapon(String slug) {
    _weaponEntries.removeWhere((e) => e.weapon.slug == slug);
    notifyListeners();
  }

  void updateWeaponQuantity(String slug, int qty) {
    if (qty <= 0) {
      removeWeapon(slug);
      return;
    }
    final entry =
        _weaponEntries.where((e) => e.weapon.slug == slug).firstOrNull;
    if (entry != null) {
      entry.quantity = qty;
      notifyListeners();
    }
  }

  void updateFromBackground(Map<String, dynamic>? background) {
  _backgroundEquipmentText =
      background?['equipment']?.toString() ?? '';
  notifyListeners();
}


  bool hasWeapon(String slug) =>
      _weaponEntries.any((e) => e.weapon.slug == slug);

  // ── Herramientas ──────────────────────────────────────────────────────────

  void addTool(String tool) {
    if (tool.trim().isEmpty || _tools.contains(tool.trim())) return;
    _tools.add(tool.trim());
    notifyListeners();
  }

  void removeTool(String tool) {
    _tools.remove(tool);
    notifyListeners();
  }

  // ── Dinero ────────────────────────────────────────────────────────────────

  void updateMoney({int? newGp, int? newPp, int? newEp, int? newSp, int? newCp}) {
    if (newGp != null) gp = newGp.clamp(0, 999999);
    if (newPp != null) pp = newPp.clamp(0, 999999);
    if (newEp != null) ep = newEp.clamp(0, 999999);
    if (newSp != null) sp = newSp.clamp(0, 999999);
    if (newCp != null) cp = newCp.clamp(0, 999999);
    notifyListeners();
  }

  // ── Tesoros ───────────────────────────────────────────────────────────────

  void updateTreasures(String text) {
    _treasuresText = text;
    notifyListeners();
  }

  // ── Filtros para dropdowns ────────────────────────────────────────────────

  List<ArmorModel> get regularArmors => _allArmors
      .where((a) =>
          !a.category.toLowerCase().contains('shield') &&
          !a.category.toLowerCase().contains('class feature') &&
          !a.category.toLowerCase().contains('spell'))
      .toList();

  List<ArmorModel> get shields => _allArmors
      .where((a) => a.category.toLowerCase().contains('shield'))
      .toList();

  List<WeaponModel> get simpleWeapons =>
      _allWeapons.where((w) => w.isSimple).toList();

  List<WeaponModel> get martialWeapons =>
      _allWeapons.where((w) => w.isMartial).toList();

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _equippedArmor = null;
    _equippedShield = null;
    _weaponEntries.clear();
    _tools.clear();
    gp = pp = ep = sp = cp = 0;
    _treasuresText = '';
    _backgroundEquipmentText = ''; // ← NUEVO
    notifyListeners();
  }

  // ── Helpers de ordenamiento ───────────────────────────────────────────────

  int _categoryOrder(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('no armor')) return 0;
    if (c.contains('light')) return 1;
    if (c.contains('medium')) return 2;
    if (c.contains('heavy')) return 3;
    if (c.contains('shield')) return 4;
    return 5;
  }

  int _weaponCategoryOrder(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('simple melee')) return 0;
    if (c.contains('simple ranged')) return 1;
    if (c.contains('martial melee')) return 2;
    if (c.contains('martial ranged')) return 3;
    return 4;
  }
}
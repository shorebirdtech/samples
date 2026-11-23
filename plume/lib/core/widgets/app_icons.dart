import 'package:material_ui/material_ui.dart';

/// Maps icon keys from the catalog data to Material icons.
abstract final class AppIcons {
  static const _icons = <String, IconData>{
    'earbuds': Icons.earbuds_rounded,
    'headphones': Icons.headphones_rounded,
    'speaker': Icons.speaker_rounded,
    'watch': Icons.watch_rounded,
    'fitness': Icons.monitor_heart_rounded,
    'glasses': Icons.visibility_rounded,
    'backpack': Icons.backpack_rounded,
    'sling': Icons.shopping_bag_rounded,
    'luggage': Icons.luggage_rounded,
    'lamp': Icons.light_rounded,
    'kettle': Icons.coffee_maker_rounded,
    'diffuser': Icons.water_drop_rounded,
    'throw': Icons.bed_rounded,
    'keyboard': Icons.keyboard_rounded,
    'mouse': Icons.mouse_rounded,
    'hub': Icons.cable_rounded,
    'stand': Icons.laptop_mac_rounded,
    'battery': Icons.battery_charging_full_rounded,
  };

  static IconData of(String key) => _icons[key] ?? Icons.category_rounded;
}

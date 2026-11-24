enum LightTag {
  directSun('direct_sun', 'прямое солнце'),
  brightIndirect('bright_indirect', 'яркий рассеянный свет'),
  partialShade('partial_shade', 'полутень'),
  shade('shade', 'тень'),
  artificialLight('artificial_light', 'искусственное освещение');

  final String tag;
  final String label;
  const LightTag(this.tag, this.label);

  static LightTag fromTag(String t) => values.firstWhere((e) => e.tag == t);
}

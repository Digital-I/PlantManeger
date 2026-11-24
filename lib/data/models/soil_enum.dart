enum SoilTag {
  universal('universal', 'универсальный'),
  drainage('drainage', 'дренаж'),
  cactusSucculent('cactus_succulent', 'для кактусов и суккулентов'),
  peat('peat', 'торфяной'),
  sandy('sandy', 'песчаный'),
  loamy('loamy', 'суглинок'),
  perliteMix('perlite_mix', 'с перлитом'),
  orchidBark('orchid_bark', 'кора (для орхидей)'),
  acidic('acidic', 'кислый'),
  humus('humus', 'перегнойный'),
  leafSoil('leaf_soil', 'листовая земля');

  final String tag;
  final String label;
  const SoilTag(this.tag, this.label);

  static SoilTag fromTag(String t) => values.firstWhere((e) => e.tag == t);
}

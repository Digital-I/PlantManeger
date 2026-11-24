enum Symptom {
  yellowLeaves('yellow_leaves', 'жёлтые листья'),
  brownTips('brown_tips', 'бурые кончики'),
  brownSpots('brown_spots', 'бурые пятна'),
  whiteCoating('white_coating', 'белый налёт'),
  wilting('wilting', 'вялость'),
  leafDrop('leaf_drop', 'опадание листьев'),
  softStem('soft_stem', 'мягкий стебель'),
  rootDiscoloration('root_discoloration', 'потемнение корней'),
  badSmell('bad_smell', 'неприятный запах'),
  webbing('webbing', 'паутинка'),
  stickyLeaves('sticky_leaves', 'липкие листья'),
  stuntedGrowth('stunted_growth', 'замедленный рост'),
  curlingLeaves('curling_leaves', 'скручивание листьев');

  final String tag;
  final String label;
  const Symptom(this.tag, this.label);
  static Symptom fromTag(String t) => values.firstWhere((e) => e.tag == t);
}

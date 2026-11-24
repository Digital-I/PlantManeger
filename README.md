# plantmanager

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Запуск приложения 
`flutter pub get`
`flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`

Расчет количесва кода
`find lib -path 'lib/screens' -prune -o -name '*.dart'   ! -name '*.g.dart'   ! -name '*.freezed.dart'   ! -name '*.gr.dart'   ! -name '*.gen.dart'   -print0 | xargs -0 wc -l`

8. Чек-лист ручного тестирования
Добавить растение с фото, перезагрузить страницу: растение и фото на месте.
Добавить растение из каталога: вид и интервал полива подставились.
Добавить 3 замера высоты: график и список обновились.
Нажать «Полито»: дата следующего полива сдвинулась, в календаре отметка.
Растение с просроченным поливом попадает на экран «Сегодня» как просроченное.
Диагностика: выбрать симптомы, болезни отсортированы по совпадению.
Удалить растение: исчезли его замеры, поливы и записи болезней.
Поиск в каталогах по русскому и латинскому названию.
Пустые состояния (нет растений, нет замеров) показывают подсказки, а не пустой экран.
Режим телефона в DevTools: ничего не вылезает за экран.
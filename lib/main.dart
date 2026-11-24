import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plantmanager/app.dart';
import 'package:plantmanager/data/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  await Storage.init();
  runApp(const ProviderScope(child: MyApp()));
}

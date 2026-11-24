import 'package:go_router/go_router.dart';
import 'package:plantmanager/features/common/app_shell.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/screens/calendar/watering_calendar_screen.dart';
import 'package:plantmanager/screens/catalog/catalog_screen.dart';
import 'package:plantmanager/screens/catalog/catalog_plant_detail_screen.dart';
import 'package:plantmanager/screens/catalog/catalog_disease_detail_screen.dart';
import 'package:plantmanager/screens/plants/plants_list_screen.dart';
import 'package:plantmanager/screens/plants/plant_detail_screen.dart';
import 'package:plantmanager/screens/plants/plant_form_screen.dart';
import 'package:plantmanager/screens/plants/plant_diagnose_screen.dart';
import 'package:plantmanager/screens/plants/note_form_screen.dart';
import 'package:plantmanager/screens/today/today_screen.dart';

final router = GoRouter(
  initialLocation: '/today',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/plants',
          builder: (context, state) => const PlantsListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => PlantFormScreen(
                initialCatalogPlant:
                    state.extra is PlantInfo ? state.extra! as PlantInfo : null,
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => PlantDetailScreen(
                plantId: state.pathParameters['id']!,
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => PlantFormScreen(
                    plantId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'diagnose',
                  builder: (context, state) => PlantDiagnoseScreen(
                    plantId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'notes/new',
                  builder: (context, state) => NoteFormScreen(
                    plantId: state.pathParameters['id']!,
                    diseaseId: state.extra is String
                        ? state.extra! as String
                        : (state.extra is Map
                            ? (state.extra! as Map)['diseaseId'] as String?
                            : null),
                  ),
                ),
                GoRoute(
                  path: 'notes/:noteId/edit',
                  builder: (context, state) => NoteFormScreen(
                    plantId: state.pathParameters['id']!,
                    noteId: state.pathParameters['noteId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const WateringCalendarScreen(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
          routes: [
            GoRoute(
              path: 'plant/:id',
              builder: (context, state) => CatalogPlantDetailScreen(
                plantId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'disease/:id',
              builder: (context, state) => CatalogDiseaseDetailScreen(
                diseaseId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

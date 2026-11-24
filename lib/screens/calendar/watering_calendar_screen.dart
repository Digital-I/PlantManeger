import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/features/calendar/calendar_event.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/providers/providers.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;

class WateringCalendarScreen extends ConsumerStatefulWidget {
  const WateringCalendarScreen({super.key});

  @override
  ConsumerState<WateringCalendarScreen> createState() =>
      _WateringCalendarScreenState();
}

class _WateringCalendarScreenState
    extends ConsumerState<WateringCalendarScreen> {
  final DateTime _today = dateOnly(DateTime.now());
  late DateTime _selectedDay = _today;
  late DateTime _focusedDay = _today;

  DateTime get _firstDay => DateTime(_today.year, _today.month - 1, 1);
  DateTime get _lastDay => DateTime(_today.year, _today.month + 2, 0);

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    final logs = ref.watch(wateringLogsProvider);
    final events = ref.watch(calendarEventsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь полива')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _loadError(
              error,
              () => ref.invalidate(plantsProvider),
            ),
            data: (plantItems) => logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _loadError(
                error,
                () => ref.invalidate(wateringLogsProvider),
              ),
              data: (_) => plantItems.isEmpty
                  ? const EmptyState(
                      title: 'Календарь пока пуст',
                      message: 'Добавьте растение, чтобы планировать полив.',
                      icon: Icons.calendar_month_outlined,
                    )
                  : _calendar(events),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadError(Object error, VoidCallback retry) => EmptyState(
        icon: Icons.error_outline,
        title: 'Не удалось загрузить календарь',
        message: error.toString(),
        actionLabel: 'Повторить',
        onAction: retry,
      );

  Widget _calendar(Map<DateTime, List<CalendarEvent>> events) {
    final selectedEvents = events[dateOnly(_selectedDay)] ?? const [];
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: TableCalendar<CalendarEvent>(
            locale: 'ru_RU',
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: (day) => events[dateOnly(day)] ?? const [],
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = dateOnly(selectedDay);
              _focusedDay = dateOnly(focusedDay);
            }),
            onPageChanged: (focusedDay) =>
                setState(() => _focusedDay = dateOnly(focusedDay)),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: colors.onPrimaryContainer),
              todayDecoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: colors.onSecondaryContainer),
              outsideDaysVisible: false,
              markersMaxCount: 0,
            ),
            calendarBuilders: CalendarBuilders<CalendarEvent>(
              markerBuilder: (context, day, dayEvents) =>
                  _eventMarkers(context, dayEvents),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 8,
          children: [
            const _LegendItem(color: Colors.blue, label: 'Нужно полить'),
            _LegendItem(color: colors.primary, label: 'Полито'),
            _LegendItem(color: colors.error, label: 'Просрочено'),
          ],
        ),
        SectionHeader(
          title:
              'Полив · ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}',
        ),
        if (selectedEvents.isEmpty)
          const EmptyState(
            title: 'В этот день поливов нет',
            message: 'Выберите другой день в календаре.',
            icon: Icons.water_drop_outlined,
          )
        else
          for (final event in selectedEvents)
            Card(
              child: CheckboxListTile(
                value: event.status == CalendarEventStatus.done,
                onChanged: (_) => ref
                    .read(wateringLogsProvider.notifier)
                    .toggle(event.plant.id, _selectedDay),
                secondary: PlantAvatar(
                  photo: event.plant.photo,
                  name: event.plant.name,
                ),
                title: Text(event.plant.name),
                subtitle: Text(_statusLabel(event.status)),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
      ],
    );
  }

  Widget? _eventMarkers(BuildContext context, List<CalendarEvent> events) {
    if (events.isEmpty) return null;
    final colors = Theme.of(context).colorScheme;
    final ordered = [...events]
      ..sort((a, b) => _priority(a.status).compareTo(_priority(b.status)));
    final visibleEvents = ordered.take(3);

    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final event in visibleEvents)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: _statusColor(event.status, colors),
                shape: BoxShape.circle,
              ),
            ),
          if (events.length > 3)
            Text('+', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  int _priority(CalendarEventStatus status) => switch (status) {
        CalendarEventStatus.overdue => 0,
        CalendarEventStatus.planned => 1,
        CalendarEventStatus.done => 2,
      };

  Color _statusColor(CalendarEventStatus status, ColorScheme colors) =>
      switch (status) {
        CalendarEventStatus.planned => Colors.blue,
        CalendarEventStatus.done => colors.primary,
        CalendarEventStatus.overdue => colors.error,
      };

  String _statusLabel(CalendarEventStatus status) => switch (status) {
        CalendarEventStatus.planned => 'Нужно полить',
        CalendarEventStatus.done => 'Полито',
        CalendarEventStatus.overdue => 'Просрочено',
      };
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

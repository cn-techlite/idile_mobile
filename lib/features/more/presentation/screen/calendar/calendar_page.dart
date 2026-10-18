import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/calendar_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/calendar_state.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum _CalendarView { month, agenda }

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDate = _dateOnly(DateTime.now());
  _CalendarView _view = _CalendarView.month;

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(calendarControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const AppLogo(markSize: 32, nameSize: 25)),
      body: calendar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(calendarControllerProvider),
        ),
        data: (state) {
          final selectedDate = _isSameMonth(_selectedDate, state.month)
              ? _selectedDate
              : DateTime(state.month.year, state.month.month);
          final selectedEntries = state.entries
              .where((entry) => _entryIsOn(entry, selectedDate))
              .toList();

          return RefreshIndicator(
            onRefresh: ref
                .read(calendarControllerProvider.notifier)
                .refreshCalendar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 124),
              children: [
                const AppText.raw(
                  'CALENDAR',
                  style: TextStyle(
                    fontFamily: 'Open Serif',
                    fontSize: 42,
                    height: 1,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                addVerticalSpacing(1),
                AppText.raw(
                  'Everything with a date, in one place.',
                  style: TextStyle(fontSize: 17, color: _mutedColor(context)),
                ),
                addVerticalSpacing(2.75),
                _CalendarToolbar(
                  month: state.month,
                  view: _view,
                  onPrevious: ref
                      .read(calendarControllerProvider.notifier)
                      .previousMonth,
                  onNext: ref
                      .read(calendarControllerProvider.notifier)
                      .nextMonth,
                  onToday: () async {
                    final today = _dateOnly(DateTime.now());
                    setState(() => _selectedDate = today);
                    await ref
                        .read(calendarControllerProvider.notifier)
                        .goToToday();
                  },
                  onViewChanged: (view) => setState(() => _view = view),
                ),
                addVerticalSpacing(2),
                const _CalendarLegend(),
                addVerticalSpacing(2),
                if (_view == _CalendarView.month) ...[
                  _MonthCalendar(
                    month: state.month,
                    entries: state.entries,
                    selectedDate: selectedDate,
                    onSelected: (date) async {
                      setState(() => _selectedDate = date);
                      if (!_isSameMonth(date, state.month)) {
                        await ref
                            .read(calendarControllerProvider.notifier)
                            .goToMonth(date);
                      }
                    },
                  ),
                  addVerticalSpacing(2),
                  _SelectedDayPanel(
                    date: selectedDate,
                    entries: selectedEntries,
                  ),
                ] else
                  _AgendaView(month: state.month, entries: state.entries),
                addVerticalSpacing(2),
                _PhoneCalendarCard(state: state, ref: ref),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CalendarToolbar extends StatelessWidget {
  const _CalendarToolbar({
    required this.month,
    required this.view,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onViewChanged,
  });

  final DateTime month;
  final _CalendarView view;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<_CalendarView> onViewChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          _ArrowButton(
            tooltip: 'Previous month',
            icon: Icons.chevron_left,
            onPressed: onPrevious,
          ),
          addHorizontalSpacing(2),
          _ArrowButton(
            tooltip: 'Next month',
            icon: Icons.chevron_right,
            onPressed: onNext,
          ),
          addHorizontalSpacing(3),
          Expanded(
            child: AppText.raw(
              DateFormat('MMMM yyyy').format(month),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Open Serif',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppButton(
            text: 'Today',
            onPressed: onToday,
            variant: AppButtonVariant.text,
            compact: true,
            textColor: _foregroundColor(context),
          ),
        ],
      ),
      addVerticalSpacing(1.5),
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _softSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _ViewButton(
                  text: 'Month',
                  selected: view == _CalendarView.month,
                  onPressed: () => onViewChanged(_CalendarView.month),
                ),
              ),
              Expanded(
                child: _ViewButton(
                  text: 'Agenda',
                  selected: view == _CalendarView.agenda,
                  onPressed: () => onViewChanged(_CalendarView.agenda),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: AppButton(
      text: '',
      onPressed: onPressed,
      compact: true,
      variant: AppButtonVariant.outlined,
      borderColor: _borderColor(context),
      borderRadius: 10,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: _foregroundColor(context)),
      ),
    ),
  );
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  final String text;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
    text: text,
    onPressed: onPressed,
    compact: true,
    variant: selected ? AppButtonVariant.filled : AppButtonVariant.text,
    btnColor: selected ? _selectedTabColor(context) : Colors.transparent,
    textColor: selected ? _selectedTabTextColor(context) : _mutedColor(context),
    borderRadius: 9,
  );
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 10,
    children: const [
      _LegendItem(type: 'bill', label: 'Bill due'),
      _LegendItem(type: 'subscription', label: 'Renewal'),
      _LegendItem(type: 'maintenance', label: 'Upkeep'),
      _LegendItem(type: 'asset', label: 'Asset renewal'),
      _LegendItem(type: 'document', label: 'Expires'),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.type, required this.label});

  final String type;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: _eventColor(context, type),
          shape: BoxShape.circle,
          border: type == 'bill'
              ? Border.all(color: _borderColor(context))
              : null,
        ),
      ),
      addHorizontalSpacing(1.5),
      Icon(_eventIcon(type), size: 18, color: _mutedColor(context)),
      addHorizontalSpacing(1.25),
      AppText.raw(label, style: TextStyle(color: _mutedColor(context))),
    ],
  );
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.entries,
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime month;
  final List<CalendarEntry> entries;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final start = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _panelColor(context),
          border: Border.all(color: _borderColor(context)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const _WeekdayHeader(),
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final date = start.add(Duration(days: index));
                final dayEntries = entries
                    .where((entry) => _entryIsOn(entry, date))
                    .toList();
                return _CalendarDay(
                  date: date,
                  inMonth: _isSameMonth(date, month),
                  selected: _isSameDay(date, selectedDate),
                  entries: dayEntries,
                  isRightEdge: index % 7 == 6,
                  isBottomEdge: index >= 35,
                  onTap: () => onSelected(date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: Row(
      children: [
        for (final day in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
          Expanded(
            child: Center(
              child: AppText.raw(
                day,
                style: TextStyle(
                  color: _mutedColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.entries,
    required this.isRightEdge,
    required this.isBottomEdge,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool selected;
  final List<CalendarEntry> entries;
  final bool isRightEdge;
  final bool isBottomEdge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: DateFormat('EEEE d MMMM yyyy').format(date),
    child: InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? _selectedCellColor(context) : null,
          border: Border(
            top: BorderSide(color: _borderColor(context)),
            right: isRightEdge
                ? BorderSide.none
                : BorderSide(color: _borderColor(context)),
            bottom: isBottomEdge
                ? BorderSide.none
                : BorderSide(color: _borderColor(context)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _selectedDayColor(context) : null,
                shape: BoxShape.circle,
              ),
              child: AppText.raw(
                '${date.day}',
                style: TextStyle(
                  color: selected
                      ? _selectedDayTextColor(context)
                      : inMonth
                      ? _foregroundColor(context)
                      : _mutedColor(context).withValues(alpha: 0.55),
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final type
                      in entries
                          .map((entry) => entry.entityType)
                          .toSet()
                          .take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _eventColor(context, type),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({required this.date, required this.entries});

  final DateTime date;
  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context) => _CalendarPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(
          _isSameDay(date, DateTime.now()) ? 'TODAY' : 'SELECTED DAY',
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        addVerticalSpacing(1),
        AppText.raw(
          DateFormat('EEEE d MMMM').format(date),
          style: const TextStyle(
            fontFamily: 'Open Serif',
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        addVerticalSpacing(2),
        if (entries.isEmpty)
          AppText.raw(
            'Nothing scheduled. Enjoy the breathing room.',
            style: TextStyle(color: _mutedColor(context)),
          )
        else
          for (var index = 0; index < entries.length; index++) ...[
            _EntryRow(entry: entries[index]),
            if (index != entries.length - 1) addVerticalSpacing(1.25),
          ],
      ],
    ),
  );
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({required this.month, required this.entries});

  final DateTime month;
  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    return _CalendarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.raw(
            '${DateFormat('MMMM').format(month)} agenda',
            style: const TextStyle(
              fontFamily: 'Open Serif',
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          addVerticalSpacing(0.75),
          AppText.raw(
            '${entries.length} ${entries.length == 1 ? 'event' : 'events'} scheduled',
            style: TextStyle(color: _mutedColor(context)),
          ),
          addVerticalSpacing(2),
          if (sorted.isEmpty)
            AppText.raw(
              'Nothing scheduled this month.',
              style: TextStyle(color: _mutedColor(context)),
            )
          else
            for (var index = 0; index < sorted.length; index++) ...[
              _AgendaRow(entry: sorted[index]),
              if (index != sorted.length - 1) addVerticalSpacing(1.5),
            ],
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(entry.date)?.toLocal();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.raw(
                date == null ? '--' : DateFormat('d').format(date),
                style: const TextStyle(
                  fontFamily: 'Open Serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              AppText.raw(
                date == null ? '' : DateFormat('EEE').format(date),
                style: TextStyle(color: _mutedColor(context)),
              ),
            ],
          ),
        ),
        Expanded(child: _EntryRow(entry: entry)),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _softSurface(context),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _eventColor(
              context,
              entry.entityType,
            ).withValues(alpha: .16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _eventIcon(entry.entityType),
            color: _eventColor(context, entry.entityType),
          ),
        ),
        addHorizontalSpacing(3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.raw(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              addVerticalSpacing(0.25),
              AppText.raw(
                _eventLabel(entry.entityType),
                style: TextStyle(fontSize: 12, color: _mutedColor(context)),
              ),
            ],
          ),
        ),
        addHorizontalSpacing(2),
        StatusPill(entry.status),
      ],
    ),
  );
}

class _PhoneCalendarCard extends StatelessWidget {
  const _PhoneCalendarCard({required this.state, required this.ref});

  final CalendarState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final connected = state.feedUrl != null;
    return _CalendarPanel(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Icon(
          connected ? Icons.event_available_outlined : Icons.add_link,
        ),
        title: AppText.raw(
          connected ? 'Phone calendar connected' : 'Connect phone calendar',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: AppText.raw(
          connected
              ? 'Your private calendar feed is active.'
              : 'Keep Idile dates in your phone calendar.',
          style: TextStyle(fontSize: 12, color: _mutedColor(context)),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppText.raw(
              connected
                  ? 'Open the feed in your calendar app, rotate the private link, or disconnect it.'
                  : 'Create a private feed for bills, renewals, upkeep and expiry dates.',
              style: TextStyle(color: _mutedColor(context)),
            ),
          ),
          if (state.feedError != null) ...[
            addVerticalSpacing(1),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText.raw(
                state.feedError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          addVerticalSpacing(1.5),
          Align(
            alignment: Alignment.centerLeft,
            child: connected
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        text: 'Open calendar app',
                        onPressed: state.isChangingFeed
                            ? null
                            : () => _openPhoneCalendar(context, state.feedUrl!),
                        icon: const Icon(Icons.open_in_new),
                        compact: true,
                      ),
                      AppButton(
                        text: 'Rotate link',
                        onPressed: state.isChangingFeed
                            ? null
                            : () => _rotate(context),
                        icon: const Icon(Icons.refresh),
                        isLoading: state.isRotatingFeed,
                        variant: AppButtonVariant.outlined,
                        compact: true,
                      ),
                      AppButton(
                        text: 'Disconnect',
                        onPressed: state.isChangingFeed
                            ? null
                            : () => _revoke(context),
                        isLoading: state.isRevokingFeed,
                        variant: AppButtonVariant.text,
                        compact: true,
                        textColor: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  )
                : AppButton(
                    text: 'Connect calendar',
                    onPressed: state.isChangingFeed
                        ? null
                        : () => _createAndOpen(context),
                    icon: const Icon(Icons.add_link),
                    isLoading: state.isRotatingFeed,
                    compact: true,
                  ),
          ),
          addVerticalSpacing(1),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText.raw(
              'Keep this link private. Rotate it if it is ever shared.',
              style: TextStyle(fontSize: 12, color: _mutedColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAndOpen(BuildContext context) async {
    try {
      final url = await ref
          .read(calendarControllerProvider.notifier)
          .rotateFeedToken();
      if (url != null && context.mounted) {
        await _openPhoneCalendar(context, url);
      }
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }

  Future<void> _rotate(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: 'Rotate calendar link?',
      message: 'The current subscription link will stop working. Add the new link to your calendar app.',
      action: 'Rotate',
    );
    if (!confirmed || !context.mounted) return;
    await _createAndOpen(context);
  }

  Future<void> _revoke(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: 'Disconnect calendar?',
      message: 'The private feed will stop updating. You can create a new link later.',
      action: 'Disconnect',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(calendarControllerProvider.notifier).revokeFeedToken();
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _panelColor(context),
      border: Border.all(color: _borderColor(context)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(padding: padding, child: child),
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText.raw(title),
        content: AppText.raw(message),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: action,
            onPressed: () => Navigator.pop(context, true),
            compact: true,
          ),
        ],
      ),
    ) ??
    false;

Future<void> _openPhoneCalendar(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    showFailure(
      context,
      'The calendar link is invalid. Rotate it and try again.',
    );
    return;
  }
  var opened = false;
  try {
    opened = await launchUrl(
      uri.replace(scheme: 'webcal'),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    // Some Android calendar apps only accept the original HTTPS feed URL.
  }
  if (!opened) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
      return;
    }
  }
  if (!opened && context.mounted) {
    showFailure(context, 'No calendar app could open this subscription.');
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

bool _entryIsOn(CalendarEntry entry, DateTime date) {
  final parsed = DateTime.tryParse(entry.date);
  return parsed != null && _isSameDay(parsed.toLocal(), date);
}

IconData _eventIcon(String type) => switch (type.toLowerCase()) {
  'bill' => Icons.receipt_long_outlined,
  'subscription' => Icons.paid_outlined,
  'asset' => Icons.grid_view_outlined,
  'document' => Icons.description_outlined,
  _ => Icons.handyman_outlined,
};

String _eventLabel(String type) {
  if (type.isEmpty) return 'Calendar item';
  return '${type[0].toUpperCase()}${type.substring(1)}';
}

Color _eventColor(BuildContext context, String type) =>
    switch (type.toLowerCase()) {
      'bill' =>
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.paper
            : AppColors.ink,
      'subscription' => AppColors.signal,
      'maintenance' => const Color(0xFF4FB783),
      'asset' => const Color(0xFFB59A85),
      'document' => const Color(0xFFB7B6B1),
      _ => _mutedColor(context),
    };

Color _foregroundColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

Color _mutedColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white60
    : AppColors.muted;

Color _borderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white24
    : AppColors.line;

Color _panelColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.surfaceDark
    : AppColors.white;

Color _softSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white.withValues(alpha: .06)
    : AppColors.paper;

Color _selectedCellColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white.withValues(alpha: .05)
    : AppColors.ink.withValues(alpha: .04);

Color _selectedDayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.paper
    : AppColors.ink;

Color _selectedDayTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.ink
    : AppColors.paper;

Color _selectedTabColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.paper
    : AppColors.ink;

Color _selectedTabTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.ink
    : AppColors.paper;

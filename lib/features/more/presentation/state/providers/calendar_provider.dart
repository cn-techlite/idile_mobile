import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/more/presentation/controller/calendar/calendar_controller.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/calendar_state.dart';

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
      CalendarController.new,
    );

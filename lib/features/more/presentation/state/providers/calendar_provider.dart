import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/more/data/repository/calendar/calendar_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/calendar/calendar_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/controller/calendar/calendar_controller.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/calendar/calendar_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/calendar_state.dart';

final calendarRemoteServiceProvider = Provider<CalendarRemoteService>(
  (ref) => CalendarRemoteService(ref.read(apiClientProvider)),
);

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepositoryImpl(ref.read(calendarRemoteServiceProvider)),
);

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
      CalendarController.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/subs/data/repository/subscriptions/subscription_repository_impl.dart';
import 'package:idile_mobile_app/features/subs/data/service/subscriptions/subscription_remote_service.dart';
import 'package:idile_mobile_app/features/subs/domain/controller/subscriptions/subscription_controller.dart';
import 'package:idile_mobile_app/features/subs/domain/usecases/subscriptions/subscription_repository.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/state_model/subscription_state.dart';

final subscriptionRemoteServiceProvider = Provider<SubscriptionRemoteService>(
  (ref) => SubscriptionRemoteService(ref.read(apiClientProvider)),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) =>
      SubscriptionRepositoryImpl(ref.read(subscriptionRemoteServiceProvider)),
);

final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, SubscriptionState>(
      SubscriptionController.new,
    );

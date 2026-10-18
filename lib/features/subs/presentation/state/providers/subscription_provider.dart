import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/subs/presentation/controller/subscriptions/subscription_controller.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/state_model/subscription_state.dart';

final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, SubscriptionState>(
      SubscriptionController.new,
    );

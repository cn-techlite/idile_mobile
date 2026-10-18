import 'package:idile_mobile_app/features/subs/domain/entities/subscriptions/subscription.dart';
import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/domain/repositories/subscriptions/subscription_repository.dart';

final class SubscriptionUseCases {
  const SubscriptionUseCases(this._repository);

  final SubscriptionRepository _repository;

  Future<SubscriptionPage> subscriptions(GetSubscriptionsRequest request) =>
      _repository.subscriptions(request);

  Future<SubscriptionItem> subscription(String subscriptionId) =>
      _repository.subscription(subscriptionId);

  Future<SubscriptionItem> createSubscription(
    CreateSubscriptionRequest request,
  ) => _repository.createSubscription(request);

  Future<SubscriptionItem> updateSubscription(
    String subscriptionId,
    UpdateSubscriptionRequest request,
  ) => _repository.updateSubscription(subscriptionId, request);

  Future<bool> deleteSubscription(String subscriptionId) =>
      _repository.deleteSubscription(subscriptionId);
}

import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';
import 'package:idile_mobile_app/features/subs/data/service/subscriptions/subscription_remote_service.dart';
import 'package:idile_mobile_app/features/subs/domain/usecases/subscriptions/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._remoteService);

  final SubscriptionRemoteService _remoteService;

  @override
  Future<SubscriptionPage> subscriptions(GetSubscriptionsRequest request) =>
      _remoteService.subscriptions(request);

  @override
  Future<SubscriptionItem> subscription(String subscriptionId) =>
      _remoteService.subscription(subscriptionId);

  @override
  Future<SubscriptionItem> createSubscription(
    CreateSubscriptionRequest request,
  ) => _remoteService.createSubscription(request);

  @override
  Future<SubscriptionItem> updateSubscription(
    String subscriptionId,
    UpdateSubscriptionRequest request,
  ) => _remoteService.updateSubscription(subscriptionId, request);

  @override
  Future<bool> deleteSubscription(String subscriptionId) =>
      _remoteService.deleteSubscription(subscriptionId);
}

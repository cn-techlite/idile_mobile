import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/domain/parameters/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/domain/entities/subscriptions/subscription.dart';

abstract interface class SubscriptionRepository {
  Future<SubscriptionPage> subscriptions(GetSubscriptionsRequest request);
  Future<SubscriptionItem> subscription(String subscriptionId);
  Future<SubscriptionItem> createSubscription(
    CreateSubscriptionRequest request,
  );
  Future<SubscriptionItem> updateSubscription(
    String subscriptionId,
    UpdateSubscriptionRequest request,
  );
  Future<bool> deleteSubscription(String subscriptionId);
}

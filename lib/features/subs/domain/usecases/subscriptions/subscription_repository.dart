import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';

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

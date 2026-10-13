import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';

class SubscriptionRemoteService {
  const SubscriptionRemoteService(this._api);

  final ApiClient _api;

  Future<SubscriptionPage> subscriptions(GetSubscriptionsRequest request) {
    final uri = Uri(
      path: Endpoints.subscriptionsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) => SubscriptionPage.fromEnvelope(
        Map<String, dynamic>.from(value as Map),
      ),
    );
  }

  Future<SubscriptionItem> subscription(String subscriptionId) => _api.get(
    Endpoints.subscriptionUrl(_validId(subscriptionId)),
    (value) =>
        SubscriptionItem.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<SubscriptionItem> createSubscription(
    CreateSubscriptionRequest request,
  ) => _api.post(
    Endpoints.subscriptionsUrl,
    (value) =>
        SubscriptionItem.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<SubscriptionItem> updateSubscription(
    String subscriptionId,
    UpdateSubscriptionRequest request,
  ) => _api.patch(
    Endpoints.subscriptionUrl(_validId(subscriptionId)),
    (value) =>
        SubscriptionItem.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteSubscription(String subscriptionId) => _api.delete(
    Endpoints.subscriptionUrl(_validId(subscriptionId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'subscriptionId',
        'Subscription id cannot be empty.',
      );
    }
    return id;
  }
}

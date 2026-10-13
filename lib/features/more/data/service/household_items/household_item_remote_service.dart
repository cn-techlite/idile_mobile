import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/model/household_items/household_item.dart';

class HouseholdItemRemoteService {
  const HouseholdItemRemoteService(this._api);

  final ApiClient _api;

  Future<HouseholdItemPage> householdItems(GetHouseholdItemsRequest request) {
    final uri = Uri(
      path: Endpoints.householdItemsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) => HouseholdItemPage.fromEnvelope(
        Map<String, dynamic>.from(value as Map),
      ),
    );
  }

  Future<HouseholdItem> householdItem(String householdItemId) => _api.get(
    Endpoints.householdItemUrl(_validId(householdItemId)),
    (value) => HouseholdItem.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<HouseholdItem> createHouseholdItem(
    CreateHouseholdItemRequest request,
  ) => _api.post(
    Endpoints.householdItemsUrl,
    (value) => HouseholdItem.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<HouseholdItem> updateHouseholdItem(
    String householdItemId,
    UpdateHouseholdItemRequest request,
  ) => _api.patch(
    Endpoints.householdItemUrl(_validId(householdItemId)),
    (value) => HouseholdItem.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteHouseholdItem(String householdItemId) => _api.delete(
    Endpoints.householdItemUrl(_validId(householdItemId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'householdItemId',
        'Household item id cannot be empty.',
      );
    }
    return id;
  }
}

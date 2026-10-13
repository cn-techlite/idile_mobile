import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/model/household_items/household_item.dart';

abstract interface class HouseholdItemRepository {
  Future<HouseholdItemPage> householdItems(GetHouseholdItemsRequest request);
  Future<HouseholdItem> householdItem(String householdItemId);
  Future<HouseholdItem> createHouseholdItem(CreateHouseholdItemRequest request);
  Future<HouseholdItem> updateHouseholdItem(
    String householdItemId,
    UpdateHouseholdItemRequest request,
  );
  Future<bool> deleteHouseholdItem(String householdItemId);
}

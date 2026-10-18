import 'package:idile_mobile_app/features/more/domain/entities/household_items/household_item.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/household_items/household_item_repository.dart';

final class HouseholdItemUseCases {
  const HouseholdItemUseCases(this._repository);

  final HouseholdItemRepository _repository;

  Future<HouseholdItemPage> householdItems(GetHouseholdItemsRequest request) =>
      _repository.householdItems(request);

  Future<HouseholdItem> householdItem(String householdItemId) =>
      _repository.householdItem(householdItemId);

  Future<HouseholdItem> createHouseholdItem(
    CreateHouseholdItemRequest request,
  ) => _repository.createHouseholdItem(request);

  Future<HouseholdItem> updateHouseholdItem(
    String householdItemId,
    UpdateHouseholdItemRequest request,
  ) => _repository.updateHouseholdItem(householdItemId, request);

  Future<bool> deleteHouseholdItem(String householdItemId) =>
      _repository.deleteHouseholdItem(householdItemId);
}

import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/model/household_items/household_item.dart';
import 'package:idile_mobile_app/features/more/data/service/household_items/household_item_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/household_items/household_item_repository.dart';

class HouseholdItemRepositoryImpl implements HouseholdItemRepository {
  const HouseholdItemRepositoryImpl(this._remoteService);

  final HouseholdItemRemoteService _remoteService;

  @override
  Future<HouseholdItemPage> householdItems(GetHouseholdItemsRequest request) =>
      _remoteService.householdItems(request);

  @override
  Future<HouseholdItem> householdItem(String householdItemId) =>
      _remoteService.householdItem(householdItemId);

  @override
  Future<HouseholdItem> createHouseholdItem(
    CreateHouseholdItemRequest request,
  ) => _remoteService.createHouseholdItem(request);

  @override
  Future<HouseholdItem> updateHouseholdItem(
    String householdItemId,
    UpdateHouseholdItemRequest request,
  ) => _remoteService.updateHouseholdItem(householdItemId, request);

  @override
  Future<bool> deleteHouseholdItem(String householdItemId) =>
      _remoteService.deleteHouseholdItem(householdItemId);
}

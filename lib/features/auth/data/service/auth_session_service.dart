import 'package:idile_mobile_app/core/services/globals.dart';

class AuthSessionService {
  Future<void> initialize() async {
    await globals.init();
  }

  Future<void> clear() async {
    final currentDeviceToken = globals.deviceToken;
    globals.token = '';
    globals.refreshToken = '';
    globals.userId = '';
    globals.userEmail = '';
    globals.userName = '';
    globals.profilePicture = '';
    globals.infoCompleted = '';
    globals.hasPassword = false;
    globals.userRole = '';
    globals.defaultSpaceId = '';
    globals.householdSpaceId = '';
    globals.workspaceSpaceId = '';
    globals.defaultCurrencyId = '';
    globals.roles = [];
    globals.permissions = [];
    globals.deviceToken = currentDeviceToken;
  }
}

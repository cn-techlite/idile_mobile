import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/account/data/dto/profile/update_account_request.dart';

void main() {
  test('serializes only fields supplied for the partial update', () {
    const request = UpdateAccountRequest(
      defaultSpaceId: 'default-space',
      householdSpaceId: 'household-space',
    );

    expect(request.toJson(), {
      'defaultSpaceId': 'default-space',
      'householdSpaceId': 'household-space',
    });
  });

  test('rejects an empty profile update', () {
    expect(() => const UpdateAccountRequest().toJson(), throwsArgumentError);
  });

  test('rejects a blank account name', () {
    expect(
      () => const UpdateAccountRequest(name: '   ').toJson(),
      throwsArgumentError,
    );
  });
}

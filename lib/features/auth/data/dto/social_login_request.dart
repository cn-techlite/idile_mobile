import 'package:idile_mobile_app/core/constants/constants.dart';

enum ExternalLoginProvider { google, apple, facebook }

class SocialLoginRequest {
  const SocialLoginRequest({
    required this.email,
    required this.idToken,
    required this.externalId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.phoneNo,
    required this.provider,
  });

  final String? email;
  final String? idToken;
  final String? externalId;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final String phoneNo;
  final ExternalLoginProvider provider;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'idToken': idToken,
      'externalId': externalId,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'phoneNo': phoneNo,
      'provider': provider.name.firstCap,
    };
  }
}

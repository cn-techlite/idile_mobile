class AppleSignInPayload {
  const AppleSignInPayload({
    required this.credential,
    required this.nonce,
    required this.authorizationCode,
    this.name,
  });

  final String credential;
  final String nonce;
  final String authorizationCode;
  final String? name;

  Map<String, dynamic> toJson() => {
    'credential': credential,
    'nonce': nonce,
    if (name != null && name!.isNotEmpty) 'name': name,
    'authorizationCode': authorizationCode,
  };
}

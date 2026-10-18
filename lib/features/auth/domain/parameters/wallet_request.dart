class WalletRequest {
  final String pinCode;
  final String walletName;
  final String bvn;
  final String bvnDateOfBirth;

  const WalletRequest({
    required this.pinCode,
    required this.walletName,
    required this.bvn,
    required this.bvnDateOfBirth,
  });

  Map<String, dynamic> toJson() => {
    'pinCode': pinCode,
    'walletName': walletName,
    'bvn': bvn,
    'bvnDateOfBirth': bvnDateOfBirth,
  };
}

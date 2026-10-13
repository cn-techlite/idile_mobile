class UpdateProfileRequest {
  final String phoneNo;
  final String sex;
  final String address;
  final String dateOfBirth;
  final String nationality;
  final String state;
  final String nextOfKin;

  const UpdateProfileRequest({
    required this.phoneNo,
    required this.sex,
    required this.address,
    required this.dateOfBirth,
    required this.nationality,
    required this.state,
    required this.nextOfKin,
  });

  Map<String, dynamic> toJson() => {
    'phoneNo': phoneNo,
    'sex': sex,
    'address': address,
    'dateOfBirth': dateOfBirth,
    'nationality': nationality,
    'state': state,
    'nextOfKin': nextOfKin,
  };
}

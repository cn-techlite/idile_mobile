class AuthState {
  const AuthState({
    this.rememberMe = false,
    this.agreedToTerms = false,
    this.isEmailSelected = true,
    this.isPhoneSelected = false,
    this.email = '',
    this.password = '',
    this.phone = '',
    this.countryCode = '+234',
    this.firstName = '',
    this.lastName = '',
    this.confirmPassword = '',
    this.otp = '',
    this.sex = '',
    this.address = '',
    this.dateOfBirth = '',
    this.nationality = '',
    this.stateLocation = '',
    this.nextOfKin = '',
    this.pinCode = '',
    this.walletName = '',
    this.bvn = '',
    this.bvnDateOfBirth = '',
  });

  final bool rememberMe;
  final bool agreedToTerms;
  final bool isEmailSelected;
  final bool isPhoneSelected;

  final String email;
  final String password;
  final String phone;
  final String countryCode;

  final String firstName;
  final String lastName;
  final String confirmPassword;
  final String otp;
  final String sex;
  final String address;
  final String dateOfBirth;
  final String nationality;
  final String stateLocation;
  final String nextOfKin;
  final String pinCode;
  final String walletName;
  final String bvn;
  final String bvnDateOfBirth;

  bool get canLogin {
    final identifier = isPhoneSelected ? phone.trim() : email.trim();
    return identifier.isNotEmpty && password.trim().isNotEmpty;
  }

  bool get canRegister {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        agreedToTerms;
  }

  bool get canResetPassword {
    return otp.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        confirmPassword.trim().isNotEmpty &&
        password.trim() == confirmPassword.trim();
  }

  AuthState copyWith({
    bool? rememberMe,
    bool? agreedToTerms,
    bool? isEmailSelected,
    bool? isPhoneSelected,
    String? email,
    String? password,
    String? phone,
    String? countryCode,
    String? firstName,
    String? lastName,
    String? confirmPassword,
    String? otp,
    String? sex,
    String? address,
    String? dateOfBirth,
    String? nationality,
    String? stateLocation,
    String? nextOfKin,
    String? pinCode,
    String? walletName,
    String? bvn,
    String? bvnDateOfBirth,
  }) {
    return AuthState(
      rememberMe: rememberMe ?? this.rememberMe,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      isEmailSelected: isEmailSelected ?? this.isEmailSelected,
      isPhoneSelected: isPhoneSelected ?? this.isPhoneSelected,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      otp: otp ?? this.otp,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      stateLocation: stateLocation ?? this.stateLocation,
      nextOfKin: nextOfKin ?? this.nextOfKin,
      pinCode: pinCode ?? this.pinCode,
      walletName: walletName ?? this.walletName,
      bvn: bvn ?? this.bvn,
      bvnDateOfBirth: bvnDateOfBirth ?? this.bvnDateOfBirth,
    );
  }
}

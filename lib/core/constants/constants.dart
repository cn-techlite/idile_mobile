// ignore_for_file: unnecessary_null_comparison, null_check_always_fails, deprecated_member_use
import 'dart:developer';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';

//
void printData(String identifier, dynamic data) {
  if (!kDebugMode) return;
  log('===> $identifier <=== $data');
}

extension CapExtension on String {
  String get firstCap => "${this[0].toUpperCase()}${substring(1)}";
}

// setToLocalStorage() method will set data to the local storage
Future setToLocalStorage({required String name, dynamic data}) async {
  await AuthLocalStorageService().writeString(name, data.toString());
}

Future setBoolToLocalStorage({required String name, dynamic data}) async {
  await AuthLocalStorageService().writeBool(name, data as bool);
}

// getFromLocalStorage() method will get data from the local storage
Future<String?> getFromLocalStorage({required String name}) async {
  return AuthLocalStorageService().readString(name);
}

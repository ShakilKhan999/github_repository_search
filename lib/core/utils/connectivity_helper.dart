import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;

    try {
      final lookup = await InternetAddress.lookup('github.com');
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
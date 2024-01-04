import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  String _data = 'Initial Data';

  String get data => _data;

  Future<void> updateData() async {
    // Check connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Offline: Update data locally
      await _updateLocalData();
    } else {
      // Online: Update data on the server
      await _updateServerData();

      // Sync data with local storage
      await _updateLocalData();
    }

    notifyListeners();
  }

  Future<void> _updateLocalData() async {
    // Update local data using SQFlite or other local storage mechanisms
    await Future.delayed(Duration(seconds: 2));
    _data = 'Updated Local Data';
    notifyListeners();
  }

  Future<void> _updateServerData() async {
    // Update data on the server
    // Implement your server communication logic here
    await Future.delayed(Duration(seconds: 2));
  }
}
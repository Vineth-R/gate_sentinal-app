import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  static Future<bool> checkInternetConnection() async {
    try {
      if (kDebugMode) {
        print('Checking internet connection...');
      }
      
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('Internet connection available');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('No internet connection: $e');
      }
      return false;
    }
  }

  static Future<bool> checkFirebaseConnection() async {
    try {
      if (kDebugMode) {
        print('Checking Firebase connection...');
      }
      
      final result = await InternetAddress.lookup('firebase.googleapis.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('Firebase connection available');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('No Firebase connection: $e');
      }
      return false;
    }
  }
}

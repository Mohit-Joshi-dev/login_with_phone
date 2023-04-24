import 'package:assessment/widgets/connectivity_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Shows when device is offline
extension ConnectivityPopup on BuildContext {
  void showConnectivityDialog() {
    showDialog(
        context: this,
        barrierDismissible: false,
        builder: (context) {
          return ConnectivityDialog(
            onPressed: () async {
              final result = await Connectivity().checkConnectivity();
              if (result == ConnectivityResult.mobile ||
                  result == ConnectivityResult.wifi) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
          );
        });
  }
}

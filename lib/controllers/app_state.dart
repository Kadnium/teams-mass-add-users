import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool isTeamsInstalled = false;
  void _setLoading(bool state) {
    isLoading = state;
    notifyListeners();
  }

  void _setError(String? err) {
    error = err;
    notifyListeners();
  }

  void _setTeamsInstalled(bool state) {
    isTeamsInstalled = state;
    notifyListeners();
  }

  static void setLoading(BuildContext context, bool state) {
    context.read<AppState>()._setLoading(state);
  }

  static void setError(BuildContext context, String? error) {
    context.read<AppState>()._setError(error);
  }

  static void setTeamsInstalled(BuildContext context, bool state) {
    context.read<AppState>()._setTeamsInstalled(state);
  }
}

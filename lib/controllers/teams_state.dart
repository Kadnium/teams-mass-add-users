import 'package:flutter/cupertino.dart';
import 'package:teams_helper/models/teams_group_model.dart';

class TeamsState extends ChangeNotifier {
  TeamsGroup? selectedTeamsGroup;

  void setSelectedGroup(TeamsGroup group) {
    selectedTeamsGroup = group;
    notifyListeners();
  }
}

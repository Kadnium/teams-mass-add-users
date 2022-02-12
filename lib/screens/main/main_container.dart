import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:teams_helper/helpers/teams_api.dart';
import 'package:teams_helper/helpers/components/app_spinner.dart';
import 'package:teams_helper/helpers/components/bottom_button.dart';
import 'package:teams_helper/models/teams_group_model.dart';
import 'package:teams_helper/screens/main/main_body.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  void onFormSubmit(String email) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: MainBody());
  }
}

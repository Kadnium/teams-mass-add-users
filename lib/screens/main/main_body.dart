import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:teams_helper/controllers/app_state.dart';
import 'package:teams_helper/controllers/teams_state.dart';
import 'package:teams_helper/helpers/teams_api.dart';
import 'package:teams_helper/helpers/components/app_spinner.dart';
import 'package:teams_helper/helpers/components/bottom_button.dart';
import 'package:teams_helper/models/teams_group_model.dart';
import 'package:teams_helper/screens/main/components/teams_group_list.dart';

class MainBody extends HookWidget {
  MainBody({
    Key? key,
  }) : super(key: key);

  final TeamsApi teamsApi = TeamsApi();
  @override
  Widget build(BuildContext context) {
    //TextEditingController userController = useTextEditingController();
    TextEditingController channelIdController = useTextEditingController();
    //var userState = useState<String>("");
    var csvPathState = useState<String?>(null);
    var csvDataListState = useState<List<String>>([]);
    // var teamsGroupData = useState<List<TeamsGroup>>([]);
    var parsedTeamsGroupState = useState<String?>(null);

    useEffect(() {
      Future.microtask(() {
        AppState.setError(context, null);
      });
    }, [parsedTeamsGroupState.value, csvDataListState.value]);
/*     TeamsGroup? selectedTeamsGroup =
        context.watch<TeamsState>().selectedTeamsGroup;
    
    useEffect(() {
      if (selectedTeamsGroup != null) {
        channelIdController.value =
            TextEditingValue(text: selectedTeamsGroup.groupId);
      }
    }, [selectedTeamsGroup]); */
    //https://teams.microsoft.com/l/team/19%3a51f788074710463f84af057b52d3c9bd%40thread.skype/conversations?groupId=6b0e3693-0849-4f82-b1a9-d03037aacffd&tenantId=fa6944af-cc7c-4cd8-9154-c01132798910
    useEffect(() {
      Future.microtask(() {
        AppState.setLoading(context, true);
        teamsApi.isTeamsPackageInstalled().then((value) {
          AppState.setLoading(context, false);
          AppState.setTeamsInstalled(context, value);
        });
      });
    }, []);
    String? error = context.watch<AppState>().error;
    bool isTeamsInstalled = context.watch<AppState>().isTeamsInstalled;
    return Center(
      child: context.watch<AppState>().isLoading
          ? const AppSpinner()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            error != null
                                ? Text(error,
                                    style: TextStyle(color: Colors.red))
                                : const SizedBox(),
                            parsedTeamsGroupState.value != null
                                ? Text("Parsed teams group id: " +
                                    parsedTeamsGroupState.value!)
                                : const SizedBox(),
                            csvPathState.value != null
                                ? Text("CSV file email rows: " +
                                    csvDataListState.value.length.toString())
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            /*   TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                  hintText:
                                      "User account email for group query"),
                            ), */
                            TextFormField(
                              controller: channelIdController,
                              decoration: InputDecoration(
                                  hintText: "Teams group invite link"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              //userState.value = userController.text;
                              // context.read<TeamsState>().setSelectedGroup(
                              //     TeamsGroup(channelIdController.text, ""));
                              try {
                                var uri = Uri.parse(channelIdController.text);
                                String? param = uri.queryParameters["groupId"];
                                if (param != null && param.isNotEmpty) {
                                  parsedTeamsGroupState.value = param;
                                } else {
                                  AppState.setError(context,
                                      "Invite link is missing groupId parameter!");
                                }
                              } catch (e) {
                                AppState.setError(
                                    context, "Invite link was not valid url!");
                              }
                            },
                            child: const Text("Save")),
                      )
                    ],
                  ),
/*                   Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child:
                            TeamsGroupList(teamsGroups: teamsGroupData.value),
                      )), */
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BottomButton(
                            text: "Install Teams packages (will take a while)",
                            onClick: () {
                              AppState.setLoading(context, true);
                              teamsApi.installPackages(() {
                                AppState.setTeamsInstalled(context, true);
                                AppState.setLoading(context, false);
                              });
                            },
                            disabled: isTeamsInstalled),
                        BottomButton(
                            text: "Upload csv file",
                            onClick: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                withData: true,
                                type: FileType.custom,
                                allowedExtensions: ['csv'],
                              );

                              if (result != null) {
                                PlatformFile file = result.files.first;
                                if (file.bytes != null) {
                                  String decoded = utf8.decode(file.bytes!);
                                  List<String> decodedList =
                                      decoded.split("\n");
                                  if (decodedList[0].trim() != "Email") {
                                    AppState.setError(context,
                                        "Input csv missing column Email!");
                                    return;
                                  }
                                  decodedList = decodedList.sublist(1);

                                  for (var email in decodedList) {
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(email)) {
                                      AppState.setError(context,
                                          "CSV has invalid email! " + email);
                                      return;
                                    }
                                  }

                                  csvDataListState.value = decodedList;
                                }
                                csvPathState.value = file.path;
                              }
                              // "CSV UPLOAD"
                            },
                            disabled: !isTeamsInstalled),
/*                         BottomButton(
                            text: "Find Teams channels",
                            onClick: () {
                              AppState.setLoading(context, true);
                              teamsGroupData.value = [];
                              teamsApi.getTeamsForUser(
                                  userEmail: userController.text,
                                  onSuccess: (List<TeamsGroup> data) async {
                                    teamsGroupData.value = data;
                                    AppState.setLoading(context, false);
                                  },
                                  onError: (String err) {
                                    AppState.setLoading(context, false);
                                    AppState.setError(context, err);
                                  });
                              return;
                            },
                            disabled:
                                userState.value.isEmpty || !isTeamsInstalled), */
                        BottomButton(
                          text: "Add users to Teams channel",
                          onClick: () {
                            AppState.setLoading(context, true);
                            teamsApi.addUsersToTeam(
                                filePath: csvPathState.value!,
                                groupId: parsedTeamsGroupState.value!,
                                onSuccess: (String str) {
                                  AppState.setLoading(context, false);
                                },
                                onError: (String err) {
                                  AppState.setLoading(context, false);
                                  AppState.setError(context, err);
                                });
                          },
                          disabled: parsedTeamsGroupState.value == null ||
                              csvPathState.value == null ||
                              !isTeamsInstalled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

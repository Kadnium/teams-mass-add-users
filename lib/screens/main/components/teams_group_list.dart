import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:teams_helper/controllers/teams_state.dart';
import 'package:teams_helper/models/teams_group_model.dart';

class TeamsGroupList extends HookWidget {
  const TeamsGroupList({Key? key, required this.teamsGroups}) : super(key: key);
  final List<TeamsGroup> teamsGroups;
  @override
  Widget build(BuildContext context) {
    String? selectedId =
        context.watch<TeamsState>().selectedTeamsGroup?.groupId;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      teamsGroups.isNotEmpty
          ? Text(
              "DisplayName        Visibility  Archived  MailNickName       Description",
              style: TextStyle(fontWeight: FontWeight.bold))
          : SizedBox(),
      SizedBox(height: 10),
      Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount:
                teamsGroups.length, // TODO maybe make this infinite loader
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 0, top: 0),
                child: TeamGroupListEntry(
                  selectedId: selectedId,
                  teamsGroup: teamsGroups[index],
                ),
              );
            }),
      )
    ]);
  }
}

class TeamGroupListEntry extends StatelessWidget {
  const TeamGroupListEntry(
      {Key? key, required this.teamsGroup, this.selectedId})
      : super(key: key);

  final TeamsGroup teamsGroup;
  final String? selectedId;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      //tileColor: Theme.of(context).canvasColor,
      //selectedTileColor: Theme.of(context).selectedRowColor,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      selected: teamsGroup.groupId == selectedId,
      //hoverColor: Theme.of(context).hoverColor,
      onTap: () {
        context.read<TeamsState>().setSelectedGroup(teamsGroup);
      },
      leading: Text(teamsGroup.infoText),
    );
  }
}

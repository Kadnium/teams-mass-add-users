import 'dart:convert';
import 'dart:io';

import 'package:teams_helper/models/teams_group_model.dart';

class TeamsApi {
  var installTeams = ["Install-Module", "-Name MicrosoftTeams"];
  var installNuGet = [
    "Install-PackageProvider",
    "-Name NuGet -MinimumVersion 2.8.5.201 -Force"
  ];
  var execPolicyUnRestricted = [
    "Set-ExecutionPolicy",
    "-ExecutionPolicy Unrestricted"
  ];
  var execPolicyRestricted = [
    "Set-ExecutionPolicy",
    "-ExecutionPolicy Restricted"
  ];
  var loginToTeams = ["Connect-MicrosoftTeams"];
  var checkTeams = ["Get-Module -ListAvailable -Name MicrosoftTeams"];
  var falseCheckTeams = ["Get-Module -ListAvailable -Name Microsofteams"];

  Future<bool> isTeamsPackageInstalled() async {
    var process = await Process.run("powershell", checkTeams);
    var stringified = process.stdout.toString();
    return stringified.isNotEmpty;
  }

  void setInstallPolicy(List<String> policy, Function() cb) async {
    var process = await Process.start("powershell", policy);
    process.stdin.writeln("y"); //
    process.stdout.transform(utf8.decoder).forEach((val) {
      print(val);
    }).then((value) {
      process.kill();
      cb();
    });
  }

  void testOnListen(var onListen) {
    print(onListen);
  }

  void installTeamsPackage(Function() cb) async {
    var process = await Process.start("powershell", installTeams);
    process.stdin.writeln("y");
    process.stdout.transform(utf8.decoder).forEach((val) {
      print(val);
    }).then((value) {
      process.kill();
      cb();
    });
  }

  void installNuGetProvider(Function() cb) async {
    var process = await Process.start("powershell", installNuGet);
    process.stdin.writeln("A");
    process.stdout.transform(utf8.decoder).forEach((val) {
      print(val);
    }).then((value) {
      process.kill();
      cb();
    });
  }

  Future<void> installPackages(Function() cb) async {
    if (await isTeamsPackageInstalled()) {
      print("Teams was installed already!");
      cb();
      return;
    } else {
      setInstallPolicy(execPolicyUnRestricted, () {
        print("Install policy set to unrestricted");
        // On first run will install NuGet
        installNuGetProvider(() async {
          installTeamsPackage(() async {
            print("Teams package was installed!");
            cb();
          });
        });
      });
    }
  }

  // NOT USED CURRENTLY
  void getTeamsForUser(
      {required Function(List<TeamsGroup>) onSuccess,
      required Function(String) onError,
      required String userEmail}) async {
    var process = await Process.start("powershell",
        ["Connect-MicrosoftTeams | Out-Null ; Get-Team -User " + userEmail]);

    process.stdout.transform(utf8.decoder).toList().then((value) {
      List<TeamsGroup> returnList = [];
      if (value.isNotEmpty) {
        print(value);
        List<String> newList =
            value.where((element) => element.isNotEmpty).toList();
        //First element is headers
        newList = newList.sublist(1);

        for (String row in newList) {
          row = row.trim();

          if (row.isNotEmpty) {
            var splittedArr = row.split(" ");
            // Hard to split other values because results can vary a lot

            TeamsGroup tGroup =
                TeamsGroup(splittedArr[0], splittedArr.sublist(1).join(" "));
            returnList.add(tGroup);
          }
        }
      }
    });

    process.stderr.transform(utf8.decoder).listen((val) {
      print(val);
      onError(val);
    });
  }

  void addUsersToTeam(
      {required Function(String) onSuccess,
      required Function(String) onError,
      required String groupId,
      required String filePath}) async {
    var process = await Process.start("powershell", [
      "Connect-MicrosoftTeams | Out-Null ; Import-Csv -Path " +
          filePath +
          " | foreach{Add-TeamUser -GroupId " +
          groupId +
          r" -user $_.email}"
    ]);

    process.stdout.transform(utf8.decoder).listen((value) {
      onSuccess(value);
    });

    process.stderr.transform(utf8.decoder).listen((val) {
      onError(val);
    });
  }
}

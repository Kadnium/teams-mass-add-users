import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: SpinKitWave(
          color: Theme.of(context).primaryColor,
          duration: Duration(milliseconds: 1000),
        ),
        width: 75,
        height: 75,
      ),
    );
  }
}

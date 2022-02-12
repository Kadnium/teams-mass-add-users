import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton(
      {Key? key,
      required this.text,
      required this.disabled,
      required this.onClick})
      : super(key: key);
  final String text;
  final bool disabled;
  final Function() onClick;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: MaterialButton(
          color: Theme.of(context).primaryColor,
          onPressed: disabled ? null : onClick,
          child: Text(text)),
    );
  }
}

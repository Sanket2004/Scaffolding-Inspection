import 'package:flutter/material.dart';
import 'package:scaffolding/colors.dart';

class PrimaryButton extends StatelessWidget {
  final Function onpress;
  final String title;
  const PrimaryButton({
    super.key,
    required this.onpress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(500),
      child: MaterialButton(
        onPressed: onpress(),
        color: primaryColor,
        minWidth: double.infinity,
        height: 50,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

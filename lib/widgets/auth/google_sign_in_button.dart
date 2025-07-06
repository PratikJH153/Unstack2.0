import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

Widget buildGoogleSigninButton(
  String text, {
  required VoidCallback onPressed,
}) {
  return InkWell(
    borderRadius: BorderRadius.all(Radius.circular(28)),
    onTap: () {
      HapticFeedback.mediumImpact();
      onPressed();
    },
    child: Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: const BorderRadius.all(
          Radius.circular(48),
        ),
        border: Border.all(
          color: Colors.white.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/icons/google.png'),
            height: 25,
            width: 25,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

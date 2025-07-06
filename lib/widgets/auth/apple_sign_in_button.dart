import 'package:flutter/material.dart';

Widget buildAppleSigninButton(
  String text, {
  required VoidCallback onPressed,
}) {
  return InkWell(
    borderRadius: BorderRadius.all(Radius.circular(28)),
    onTap: () {
      onPressed();
    },
    child: Container(
      width: double.infinity,
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(48),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/icons/apple.png'),
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
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

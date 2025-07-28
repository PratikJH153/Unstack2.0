import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/auth/email_signin_bottom_sheet.dart';

Widget buildPhoneSignInButton(
  String text, {
  required VoidCallback onPressed,
}) {
  return Builder(
    builder: (context) => InkWell(
      borderRadius: BorderRadius.all(Radius.circular(28)),
      onTap: () {
        _showPhoneSignInBottomSheet(context, onPressed);
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
            const Icon(
              CupertinoIcons.phone_fill,
              size: 24,
              color: AppColors.blackColor,
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
    ),
  );
}

void _showPhoneSignInBottomSheet(BuildContext context, VoidCallback onSuccess) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => EmailSignInBottomSheet(onSuccess: onSuccess),
  );
}

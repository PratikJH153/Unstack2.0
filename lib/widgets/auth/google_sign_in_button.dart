// import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
// import 'package:unstack/theme/theme.dart';

// Widget buildGoogleSigninButton(
//   String text, {
//   required VoidCallback onPressed,
// }) {
//   return InkWell(
//     borderRadius: BorderRadius.all(Radius.circular(28)),
//     onTap: () {
//       HapticFeedback.mediumImpact();
//       onPressed();
//     },
//     child: Container(
//       width: double.infinity,
//       height: 65,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(
//           Radius.circular(48),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Image(
//             image: AssetImage('assets/icons/google.png'),
//             height: 28,
//             width: 28,
//             fit: BoxFit.cover,
//           ),
//           const SizedBox(
//             width: 16,
//           ),
//           Text(
//             text,
//             style: AppTextStyles.bodyMedium.copyWith(
//               fontWeight: FontWeight.w600,
//               color: AppColors.blackColor,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

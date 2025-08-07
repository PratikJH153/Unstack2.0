// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pinput/pinput.dart';
// import 'package:unstack/theme/theme.dart';
// import 'package:unstack/widgets/loading_widget.dart';

// enum EmailSignInState { emailInput, pinVerification }

// class EmailSignInBottomSheet extends StatefulWidget {
//   final VoidCallback onSuccess;

//   const EmailSignInBottomSheet({
//     super.key,
//     required this.onSuccess,
//   });

//   @override
//   State<EmailSignInBottomSheet> createState() => _EmailSignInBottomSheetState();
// }

// class _EmailSignInBottomSheetState extends State<EmailSignInBottomSheet>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _pinController = TextEditingController();

//   EmailSignInState _currentState = EmailSignInState.emailInput;
//   bool _isLoading = false;

//   late AnimationController _slideController;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _emailController.dispose();
//     _pinController.dispose();
//     super.dispose();
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your email address';
//     }

//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (!emailRegex.hasMatch(value.trim())) {
//       return 'Please enter a valid email address';
//     }

//     return null;
//   }

//   Future<void> _handleEmailSubmit() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call
//       await Future.delayed(const Duration(milliseconds: 1500));

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _currentState = EmailSignInState.pinVerification;
//         });
//         _slideController.forward();
//         HapticFeedback.mediumImpact();
//       }
//     }
//   }

//   Future<void> _handlePinSubmit() async {
//     if (_pinController.text.length == 6) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate PIN verification
//       await Future.delayed(const Duration(milliseconds: 1000));

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });

//         // Simulate successful verification
//         if (_pinController.text == '123456') {
//           HapticFeedback.heavyImpact();
//           Navigator.of(context).pop();
//           widget.onSuccess();
//         } else {
//           // Show error for wrong PIN
//           HapticFeedback.heavyImpact();
//           _pinController.clear();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Invalid PIN. Please try again.',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.whiteColor,
//                 ),
//               ),
//               backgroundColor: AppColors.statusError,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppBorderRadius.lg),
//               ),
//             ),
//           );
//         }
//       }
//     }
//   }

//   void _goBackToEmail() {
//     setState(() {
//       _currentState = EmailSignInState.emailInput;
//     });
//     _slideController.reverse();
//     HapticFeedback.lightImpact();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // margin: const EdgeInsets.all(AppSpacing.lg),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(AppBorderRadius.xxxl),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.backgroundTertiary,
//             AppColors.backgroundTertiary.withValues(alpha: 0.05),
//           ],
//         ),
//         border: Border.all(
//           color: AppColors.glassBorder,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 30,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(AppBorderRadius.xxxl),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: Container(
//             padding: const EdgeInsets.all(AppSpacing.xl).copyWith(bottom: 60),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Handle bar
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: AppColors.textMuted,
//                     borderRadius: BorderRadius.circular(AppBorderRadius.full),
//                   ),
//                 ),

//                 const SizedBox(height: AppSpacing.xl),

//                 // Content based on current state
//                 if (_currentState == EmailSignInState.emailInput)
//                   _buildEmailInputContent()
//                 else
//                   _buildPinVerificationContent(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmailInputContent() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Sign in with Email',
//             style: AppTextStyles.h2.copyWith(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Text(
//             'Enter your email address to receive a verification PIN',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.xl),
//           TextFormField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             validator: _validateEmail,
//             enabled: !_isLoading,
//             style: AppTextStyles.bodyLarge.copyWith(
//               color: AppColors.textPrimary,
//             ),
//             cursorColor: Colors.white,
//             decoration: InputDecoration(
//               labelText: 'Email Address',
//               labelStyle: AppTextStyles.bodyLarge.copyWith(
//                 color: AppColors.textPrimary,
//               ),
//               fillColor: Colors.transparent,
//               border: UnderlineInputBorder(
//                 borderSide: BorderSide(
//                   color: AppColors.glassBorder,
//                 ),
//               ),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(
//                   color: AppColors.glassBorder,
//                 ),
//               ),
//               focusedBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(
//                   color: AppColors.whiteColor,
//                   width: 3,
//                 ),
//               ),
//               errorBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(
//                   color: AppColors.statusError,
//                 ),
//               ),
//               prefixIcon: Icon(
//                 Icons.email_outlined,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           const SizedBox(height: AppSpacing.xxl),
//           _isLoading
//               ? Center(child: LoadingWidget())
//               : SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _handleEmailSubmit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.whiteColor,
//                       foregroundColor: AppColors.blackColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(AppBorderRadius.xxxl),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(
//                       'Verify',
//                       style: AppTextStyles.bodyLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPinVerificationContent() {
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: AppTextStyles.h3.copyWith(
//         color: AppColors.textPrimary,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(AppBorderRadius.lg),
//         border: Border.all(
//           color: AppColors.glassBorder,
//         ),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         border: Border.all(
//           color: AppColors.accentPurple,
//           width: 2,
//         ),
//       ),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: defaultPinTheme.decoration!.copyWith(
//         color: AppColors.accentPurple.withValues(alpha: 0.1),
//         border: Border.all(
//           color: AppColors.accentPurple,
//         ),
//       ),
//     );

//     return SlideTransition(
//       position: _slideAnimation,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           IconButton(
//             onPressed: _isLoading ? null : _goBackToEmail,
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: AppColors.textSecondary,
//               size: 30,
//             ),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           Text(
//             'Enter Verification PIN',
//             style: AppTextStyles.h2.copyWith(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           Text(
//             'We sent a 6-digit PIN to ${_emailController.text}',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.xl),
//           Center(
//             child: Pinput(
//               controller: _pinController,
//               length: 6,
//               defaultPinTheme: defaultPinTheme,
//               focusedPinTheme: focusedPinTheme,
//               submittedPinTheme: submittedPinTheme,
//               enabled: !_isLoading,
//               onCompleted: (pin) => _handlePinSubmit(),
//               hapticFeedbackType: HapticFeedbackType.lightImpact,
//               keyboardType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//               ],
//             ),
//           ),
//           const SizedBox(height: AppSpacing.xl),
//           if (_isLoading)
//             Center(child: LoadingWidget())
//           else
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   // Simulate resending PIN
//                   HapticFeedback.lightImpact();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'PIN sent to ${_emailController.text}',
//                         style: AppTextStyles.bodyMedium.copyWith(
//                           color: AppColors.whiteColor,
//                         ),
//                       ),
//                       backgroundColor: AppColors.statusSuccess,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppBorderRadius.lg),
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Resend PIN',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.accentPurple,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

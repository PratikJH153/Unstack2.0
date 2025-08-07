import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstack/routes/route.dart';

class DismissibleWrapper extends StatelessWidget {
  final Widget child;

  const DismissibleWrapper({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Dismiss keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        // Unfocus any active focus node
        FocusScope.of(context).unfocus();

        // Check if a bottom sheet is showing
        if (ModalRoute.of(context)?.settings.name == null &&
            Navigator.canPop(context)) {
          RouteUtils.pop(context);
        }
      },
      child: child,
    );
  }
}

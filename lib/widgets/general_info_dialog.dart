import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/loading_widget.dart';

class GeneralInfoDialog extends StatefulWidget {
  final String infoMD;
  const GeneralInfoDialog({required this.infoMD, super.key});

  static Future<void> show(BuildContext context, String infoMD) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(178),
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: GeneralInfoDialog(
          infoMD: infoMD,
        ),
      ),
    );
  }

  @override
  State<GeneralInfoDialog> createState() => _GeneralInfoDialogState();
}

class _GeneralInfoDialogState extends State<GeneralInfoDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 15,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withAlpha(26),
                      blurRadius: 3,
                      spreadRadius: -1,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          left: 24,
                          right: 24,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Unstack', style: AppTextStyles.h1),
                            IconButton(
                              onPressed: () {
                                RouteUtils.pop(context);
                              },
                              icon: const Icon(
                                CupertinoIcons.clear,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RawScrollbar(
                        thumbColor: Colors.white.withAlpha(76),
                        radius: const Radius.circular(20),
                        thickness: 5,
                        child: buildScrollableWithFade(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                                bottom: 20,
                                left: 24,
                                right: 24,
                              ),
                              child: FutureBuilder<String>(
                                future: DefaultAssetBundle.of(context)
                                    .loadString(widget.infoMD),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return MarkdownBody(
                                      data: snapshot.data!,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          color: Colors.white.withAlpha(204),
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                        h1: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        h2: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const LoadingWidget();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

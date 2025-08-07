import 'package:chiclet/chiclet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/utils/app_logger.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/buildScrollableWithFade.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';

class AddTaskPage extends StatefulWidget {
  final RouteSettings routeSettings;
  const AddTaskPage({required this.routeSettings, super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateTime _selectedDateTime = DateTime.now();
  bool fromHomePage = false;
  bool isValid = false;
  bool isEdit = false;

  @override
  void initState() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    final routeData = widget.routeSettings.arguments as Map<String, dynamic>?;
    fromHomePage =
        routeData != null ? routeData['fromHomePage'] ?? false : false;
    if (routeData != null ? routeData["edit"] ?? false : false) {
      _titleController.text = routeData["task"].title;
      _descriptionController.text = routeData["task"].description;
      _selectedPriority = routeData["task"].priority;
      isEdit = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _addTask() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      AppLogger.debug(_titleController.text);
      AppLogger.debug(_descriptionController.text);
      AppLogger.debug(_selectedPriority.toString());
      AppLogger.debug(_selectedDateTime.toString());
      if (fromHomePage) {
        RouteUtils.pushReplacementNamed(context, RoutePaths.tasksListPage);
      } else {
        RouteUtils.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 76,
        margin: EdgeInsets.all(AppSpacing.lg),
        width: double.infinity,
        child: ChicletOutlinedAnimatedButton(
          // style: ElevatedButton.styleFrom(
          //   backgroundColor: isValid
          //       ? AppColors.whiteColor
          //       : AppColors.whiteColor.withAlpha(50),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(100),
          //     ),
          //   ),
          // ),
          borderColor: AppColors.textMuted,
          borderWidth: 2,
          backgroundColor: isValid
              ? AppColors.whiteColor
              : AppColors.whiteColor.withAlpha(50),
          buttonType: ChicletButtonTypes.roundedRectangle,
          height: 76,
          width: double.infinity,

          borderRadius: AppBorderRadius.xxl,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (isValid) {
              _addTask();
            }
          },
          child: Text(
            isEdit ? "Save Changes" : "Let's Complete this!",
            style: TextStyle(
              fontSize: 18 * ResponsiveUtils.fontScale,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.w600,
              color: isValid
                  ? AppColors.blackColor
                  : const Color.fromARGB(255, 88, 88, 88),
            ),
          ),
        ).slideUpStandard(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 0),
              child: HomeAppBarButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: CupertinoIcons.back,
              ),
            ),
            Expanded(
              child: buildScrollableWithFade(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    bottom: 120,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _titleController,
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  if (value.trim().length >= 2) {
                                    setState(() {
                                      isValid = true;
                                    });
                                  } else {
                                    setState(() {
                                      isValid = false;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value!.trim().length < 2) {
                                    return 'Please enter a valid task title';
                                  }
                                  return value.trim().isEmpty
                                      ? 'Please enter a valid task title'
                                      : null;
                                },
                                cursorColor: AppColors.whiteColor,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  hintText: "What's your task?",
                                  hintStyle: AppTextStyles.h1.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  fillColor: Colors.transparent,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentPink,
                                      width: 0,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.textPrimary,
                                      width: 0.1,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.textPrimary,
                                      width: 5,
                                    ),
                                  ),
                                ),
                              ).slideUpStandard(),
                              const SizedBox(
                                height: AppSpacing.md,
                              ),
                              TextFormField(
                                controller: _descriptionController,
                                keyboardType: TextInputType.text,
                                onChanged: (_) {
                                  setState(() {});
                                },
                                cursorColor: AppColors.whiteColor,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                    bottom: 20,
                                  ),
                                  hintText:
                                      'Now break it down, describe steps, or write a note…',
                                  hintStyle: AppTextStyles.h3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ).slideUpStandard(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        Text(
                          'Priority',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ).slideUpStandard(),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Wrap(
                          children: TaskPriority.values.map((e) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPriority = e;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                  bottom: AppSpacing.sm,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedPriority == e
                                      ? e.color.withValues(alpha: 0.2)
                                      : AppColors.backgroundTertiary,
                                  borderRadius: BorderRadius.circular(
                                      AppBorderRadius.full),
                                  border: Border.all(
                                    color: _selectedPriority == e
                                        ? e.color.withValues(alpha: 0.5)
                                        : AppColors.backgroundTertiary,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 18,
                                      color: e.color,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      e.label,
                                      style:
                                          AppTextStyles.buttonMedium.copyWith(
                                        color: _selectedPriority == e
                                            ? e.color
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ).slideUpStandard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

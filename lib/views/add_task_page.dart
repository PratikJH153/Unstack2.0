import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/task.dart';
import 'package:unstack/routes/route.dart';
import 'package:unstack/theme/app_theme.dart';
import 'package:unstack/widgets/home_app_bar_button.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String _selectedDate = 'Today';
  final List<String> _dateOptions = ['Today', 'Tomorrow'];

  @override
  void initState() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    super.initState();
  }

  void _addTask() {
    RouteUtils.pushReplacementNamed(context, RoutePaths.tasksListPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 80,
        margin: EdgeInsets.all(AppSpacing.lg),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _titleController.text.trim().isNotEmpty
                ? AppColors.whiteColor
                : AppColors.whiteColor.withAlpha(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  32,
                ),
              ),
            ),
          ),
          onPressed: _addTask,
          child: Text(
            "Let's Complete this!",
            style: TextStyle(
              fontWeight: _titleController.text.trim().isNotEmpty
                  ? FontWeight.w600
                  : FontWeight.w800,
              color: _titleController.text.trim().isNotEmpty
                  ? AppColors.blackColor
                  : AppColors.whiteColor,
            ),
          ),
        )
            .animate()
            .slideY(
              begin: 0.3,
              duration: 400.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xxl,
                bottom: AppSpacing.md,
              ),
              child: HomeAppBarButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: CupertinoIcons.back,
              ),
            ),
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.name,
              onChanged: (_) {
                setState(() {});
              },
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  bottom: 8,
                ),
                hintText: 'What to Tackle?',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
                fillColor: Colors.transparent,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.accentPink,
                    width: 0,
                  ),
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textPrimary,
                    width: 5,
                  ),
                ),
              ),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            TextFormField(
              controller: _descriptionController,
              keyboardType: TextInputType.name,
              onChanged: (_) {
                setState(() {});
              },
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  bottom: 20,
                ),
                hintText: 'How do you want to tackle your task?',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
                fillColor: Colors.transparent,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.accentPink,
                    width: 0,
                  ),
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.textPrimary,
                    width: 5,
                  ),
                ),
              ),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'Priority',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
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
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPriority == e
                          ? e.color.withValues(alpha: 0.2)
                          : AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
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
                          e.icon,
                          size: 16,
                          color: e.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          e.label,
                          style: AppTextStyles.caption.copyWith(
                            color: _selectedPriority == e
                                ? e.color
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'When?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              children: _dateOptions.map((e) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: e == 'Today' ? 8 : 0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = e;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDate == e
                            ? AppColors.whiteColor
                            : AppColors.backgroundTertiary,
                        side: BorderSide(
                          color: _selectedDate == e
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.full),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _selectedDate == e
                              ? Icon(
                                  CupertinoIcons.checkmark,
                                  size: 16,
                                  color: _selectedDate == e
                                      ? AppColors.blackColor
                                      : AppColors.textMuted,
                                )
                              : const SizedBox(),
                          const SizedBox(width: 8),
                          Text(
                            e,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedDate == e
                                  ? AppColors.blackColor
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
                .animate()
                .slideX(
                  begin: 0.3,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}

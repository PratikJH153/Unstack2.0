import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/tasks/streak_data.dart';
import 'package:unstack/theme/theme.dart';

class StreakCalendar extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;
  final List<DayCompletionData> completionData;

  const StreakCalendar({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.completionData,
  });

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  List<String> get _weekDays =>
      ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    List<DateTime> days = [];
    DateTime currentDate = startDate;

    // Generate 6 weeks (42 days) to ensure consistent calendar size
    for (int i = 0; i < 42; i++) {
      days.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }

  DayCompletionData? _getCompletionDataForDate(DateTime date) {
    try {
      return widget.completionData.firstWhere(
        (data) => _isSameDay(data.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month && date.year == _currentMonth.year;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Column(
      children: [
        // Month Navigation Header
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.chevron_left,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                ),
              ),
              Text(
                '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Week Days Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: _weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Calendar Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final completionData = _getCompletionDataForDate(date);
            final isCurrentMonth = _isCurrentMonth(date);
            final isToday = _isToday(date);

            return _CalendarDayWidget(
              date: date,
              completionData: completionData,
              isCurrentMonth: isCurrentMonth,
              isToday: isToday,
            )
                .animate(delay: Duration(milliseconds: 30 * index))
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.9, 0.9), duration: 200.ms);
          },
        ),
      ],
    );
  }
}

class _CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final DayCompletionData? completionData;
  final bool isCurrentMonth;
  final bool isToday;

  const _CalendarDayWidget({
    required this.date,
    required this.completionData,
    required this.isCurrentMonth,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = completionData != null;
    final allTasksCompleted = hasData && completionData!.allTasksCompleted;
    final hasPartialCompletion = hasData &&
        completionData!.completedTasks > 0 &&
        !completionData!.allTasksCompleted;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday
            ? AppColors.accentPurple.withValues(alpha: 0.15)
            : allTasksCompleted
                ? AppColors.accentOrange.withValues(alpha: 0.1)
                : hasPartialCompletion
                    ? AppColors.accentYellow.withValues(alpha: 0.1)
                    : Colors.transparent,
        border: isToday
            ? Border.all(color: AppColors.accentPurple, width: 2)
            : allTasksCompleted
                ? Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                    width: 1)
                : hasPartialCompletion
                    ? Border.all(
                        color: AppColors.accentYellow.withValues(alpha: 0.3),
                        width: 1)
                    : null,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasData &&
                completionData!.totalTasks > 0 &&
                !allTasksCompleted &&
                !isToday)
              Center(
                child: Transform.rotate(
                  angle: 90,
                  child: _CalendarProgressIndicator(
                    progress: completionData!.completionPercentage / 100 + 0.5,
                    size: 36,
                  ),
                ),
              ),
            // Day number
            if (!allTasksCompleted)
              Text(
                '${date.day}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isCurrentMonth
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),

            // Completion indicator
            if (allTasksCompleted)
              Positioned(
                child: Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.accentOrange,
                  size: 16,
                ),
              )
            else if (hasPartialCompletion)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentYellow,
                  ),
                ),
              )
            // else if (hasData && completionData!.totalTasks > 0)
            //   Positioned(
            //     bottom: 4,
            //     child: Container(
            //       width: 5,
            //       height: 5,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         border: Border.all(
            //           color: AppColors.textMuted,
            //           width: 1,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

class _CalendarProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final Color primaryColor = AppColors.accentOrange;
  final Color backgroundColor = AppColors.backgroundSecondary;

  const _CalendarProgressIndicator({
    required this.progress,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom painted progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _CalendarProgressPainter(
              progress: progress,
              primaryColor: primaryColor,
              backgroundColor: backgroundColor,
              strokeWidth: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;

  const _CalendarProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle with subtle 3D effect
    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Inner shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 0.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius + 0.25, shadowPaint);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient and 3D effect
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
            primaryColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Highlight for 3D effect
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth / 2.5
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.141592653589793 * progress;

      // Draw main progress arc (starting from top)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );

      // Draw highlight for 3D effect
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 4),
        -3.141592653589793 / 2,
        sweepAngle,
        false,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        primaryColor != oldDelegate.primaryColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/streak_data.dart';
import 'package:unstack/theme/app_theme.dart';

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

        const SizedBox(height: AppSpacing.xl),

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
            // Day number
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
                bottom: 4,
                child: Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.accentOrange,
                  size: 10,
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
            else if (hasData && completionData!.totalTasks > 0)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textMuted,
                      width: 1,
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

// COMMENTED OUT - Timer-related imports (Pomodoro functionality)
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:unstack/models/task.model.dart';
import 'package:unstack/theme/app_theme.dart';

class TaskDetailsPage extends StatefulWidget {
  final String heroTag;
  final Task? task;

  const TaskDetailsPage({
    required this.heroTag,
    this.task,
    super.key,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage>
    with TickerProviderStateMixin {
  late Task _currentTask;

  // Pomodoro timer state - COMMENTED OUT
  // Timer? _timer;
  // bool _isTimerRunning = false;
  // bool _isTimerPaused = false;
  // bool _isBreakTime = false;

  // Timer configuration - COMMENTED OUT
  // int _selectedDuration = 25; // Default 25 minutes
  // final List<int> _durationOptions = [15, 25, 30, 45];
  // int _remainingSeconds = 25 * 60;
  // int _totalSeconds = 25 * 60;

  // Break configuration - COMMENTED OUT
  // final int _shortBreakDuration = 5; // 5 minutes
  // final int _longBreakDuration = 15; // 15 minutes
  // int _completedSessions = 0;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task ??
        Task(
          id: 'temp',
          title: 'New Task',
          description: '',
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        );
  }

  @override
  void dispose() {
    // _timer?.cancel(); // COMMENTED OUT - Pomodoro timer cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Main Content - Pomodoro timer functionality commented out
            Expanded(
              child: Center(
                child: Text(
                  'Pomodoro Timer Functionality\nTemporarily Disabled',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMMENTED OUT - Pomodoro timer view
  /*
  Widget _buildPomodoroTimerView() {
    return SafeArea(
      child: Column(
        children: [
          // Header Section
          _buildHeader(),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Timer Configuration Section (only show when not running)
                  if (!_isTimerRunning && !_isTimerPaused)
                    _buildTimerConfiguration()
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, duration: 300.ms),

                  const Spacer(),

                  // Timer Display
                  _buildTimerDisplay(),

                  const Spacer(),

                  // Session Controls
                  _buildSessionControls(),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with back button and close button
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    CupertinoIcons.back,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Task title
          Center(
            child: Column(
              children: [
                Text(
                  _currentTask.title,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.sm),

                // COMMENTED OUT - Session counter (Pomodoro functionality)
                /*
                if (_completedSessions > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      border: Border.all(
                        color: AppColors.accentPurple.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$_completedSessions sessions completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }

  // COMMENTED OUT - Timer configuration method
  /*
  Widget _buildTimerConfiguration() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Duration selection pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _durationOptions.map((duration) {
              final isSelected = _selectedDuration == duration;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                      _remainingSeconds = duration * 60;
                      _totalSeconds = duration * 60;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentPurple
                          : AppColors.surfaceCard.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentPurple
                            : AppColors.glassBorder.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${duration}m',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.textInverse
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  */

  // COMMENTED OUT - Timer display method
  /*
  Widget _buildTimerDisplay() {
    final progress = _totalSeconds > 0
        ? (_totalSeconds - _remainingSeconds) / _totalSeconds
        : 0.0;
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Column(
      children: [
        // Session type indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isBreakTime
                ? AppColors.accentOrange.withValues(alpha: 0.1)
                : AppColors.accentPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            border: Border.all(
              color: _isBreakTime
                  ? AppColors.accentOrange.withValues(alpha: 0.3)
                  : AppColors.accentPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            _isBreakTime ? 'Take a break' : 'Focus on a process',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _isBreakTime
                  ? AppColors.accentOrange
                  : AppColors.accentPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Modern timer display with subtle background
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _isBreakTime
                    ? AppColors.accentOrange.withValues(alpha: 0.05)
                    : AppColors.accentPurple.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle background circle
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceCard.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),

              // Progress indicator
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isBreakTime
                          ? AppColors.accentOrange
                          : AppColors.accentPurple,
                    ),
                  ),
                ),
              ),

              // Timer text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                        fontSize: 48,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isBreakTime ? 'Olivia!' : 'Olivia!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  */

  // COMMENTED OUT - Session controls method
  /*
  Widget _buildSessionControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // Primary control button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isTimerRunning
                  ? _pauseTimer
                  : (_isTimerPaused ? _resumeTimer : _startTimer),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTimerRunning
                    ? AppColors.accentOrange
                    : (_isBreakTime
                        ? AppColors.accentOrange
                        : AppColors.accentPurple),
                foregroundColor: AppColors.textInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                _isTimerRunning
                    ? 'Pause'
                    : (_isTimerPaused ? 'Resume' : 'Start Session'),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Secondary controls - minimal and subtle
          if (_isTimerRunning || _isTimerPaused) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _stopTimer,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Stop Session',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                TextButton(
                  onPressed: _resetTimer,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  */

  // COMMENTED OUT - Timer control methods
  /*
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isTimerPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });

    HapticFeedback.mediumImpact();
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = true;
    });
    _timer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _totalSeconds = _selectedDuration * 60;
      _isBreakTime = false;
    });
    _timer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _totalSeconds = _selectedDuration * 60;
      _isBreakTime = false;
    });
    _timer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _completeSession() {
    _timer?.cancel();

    if (_isBreakTime) {
      // Break completed, return to work session
      setState(() {
        _isBreakTime = false;
        _isTimerRunning = false;
        _isTimerPaused = false;
        _remainingSeconds = _selectedDuration * 60;
        _totalSeconds = _selectedDuration * 60;
      });
      _showBreakCompleteDialog();
    } else {
      // Work session completed
      setState(() {
        _completedSessions++;
        _currentTask = _currentTask.copyWith(
          pomodoroCount: _currentTask.pomodoroCount + 1,
        );
      });
      _startBreakSession();
    }

    HapticFeedback.heavyImpact();
  }

  void _startBreakSession() {
    final isLongBreak = _completedSessions % 4 == 0;
    final breakDuration =
        isLongBreak ? _longBreakDuration : _shortBreakDuration;

    setState(() {
      _isBreakTime = true;
      _isTimerRunning = false;
      _isTimerPaused = false;
      _remainingSeconds = breakDuration * 60;
      _totalSeconds = breakDuration * 60;
    });

    _showSessionCompleteDialog(isLongBreak);
  }

  void _showSessionCompleteDialog(bool isLongBreak) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        title: Text(
          'Session Complete! 🎉',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Great work! Time for a ${isLongBreak ? 'long' : 'short'} break.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer(); // Start break timer automatically
            },
            child: Text(
              'Start Break',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopTimer(); // Skip break
            },
            child: Text(
              'Skip Break',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        title: Text(
          'Break Complete! ⚡',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Ready to get back to work?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Start Next Session',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  */
}

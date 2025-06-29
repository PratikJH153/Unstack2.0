import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unstack/models/task.dart';
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
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  bool _isPomodoroMode = false;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;

  // Pomodoro timer state
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes in seconds
  final int _totalSeconds = 25 * 60;

  // Task editing state
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Sample task for demonstration
  late Task _currentTask;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize task data
    _currentTask = widget.task ?? TaskData.getSampleTasks().first;
    _titleController = TextEditingController(text: _currentTask.title);
    _descriptionController =
        TextEditingController(text: _currentTask.description);
    _selectedPriority = _currentTask.priority;

    // Start entrance animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startPomodoro() {
    setState(() {
      _isPomodoroMode = true;
      _isTimerRunning = true;
      _isTimerPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _showPomodoroComplete();
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
    setState(() {
      _isTimerRunning = true;
      _isTimerPaused = false;
    });
    _startPomodoro();
  }

  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
      _remainingSeconds = _totalSeconds;
    });
    _timer?.cancel();
    HapticFeedback.mediumImpact();
  }

  void _exitPomodoroMode() {
    _stopTimer();
    setState(() {
      _isPomodoroMode = false;
    });
  }

  void _showPomodoroComplete() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        title: Text(
          '🍅 Pomodoro Complete!',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Great job! You\'ve completed a 25-minute focus session.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitPomodoroMode();
            },
            child: Text(
              'Done',
              style: TextStyle(color: AppColors.accentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      // Save changes
      _currentTask = _currentTask.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
      );
    }

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPomodoroMode) {
      return _buildPomodoroView();
    }

    return Hero(
      tag: widget.heroTag,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: _buildTaskDetailsView(),
      ),
    );
  }

  Widget _buildTaskDetailsView() {
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              CupertinoIcons.back,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleEdit,
              icon: Icon(
                _isEditing ? CupertinoIcons.check_mark : CupertinoIcons.pencil,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundPrimary,
                    AppColors.backgroundPrimary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                _buildTaskTitle()
                    .animate()
                    .fadeIn(duration: 3000.ms, delay: 200.ms)
                    .slideY(
                        begin: 0.3,
                        duration: 3000.ms,
                        curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.lg),

                // Task Description
                _buildTaskDescription()
                    .animate()
                    .fadeIn(duration: 3000.ms, delay: 400.ms)
                    .slideY(
                        begin: 0.3,
                        duration: 3000.ms,
                        curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.xl),

                // Task Priority
                _buildTaskPriority()
                    .animate()
                    .fadeIn(duration: 3000.ms, delay: 600.ms)
                    .slideY(
                        begin: 0.3,
                        duration: 3000.ms,
                        curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.xl),

                // Pomodoro Progress
                _buildPomodoroProgress()
                    .animate()
                    .fadeIn(duration: 3000.ms, delay: 800.ms)
                    .slideY(
                        begin: 0.3,
                        duration: 3000.ms,
                        curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.xl),

                // Start Pomodoro Button
                _buildStartPomodoroButton()
                    .animate()
                    .fadeIn(duration: 3000.ms, delay: 1000.ms)
                    .slideY(
                        begin: 0.3,
                        duration: 3000.ms,
                        curve: Curves.easeOutCubic)
                    .shimmer(duration: 2000.ms, delay: 2000.ms),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTitle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Title',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _isEditing
              ? TextField(
                  controller: _titleController,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter task title...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  maxLines: 2,
                )
              : Text(
                  _currentTask.title,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTaskDescription() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _isEditing
              ? TextField(
                  controller: _descriptionController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter task description...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  maxLines: 4,
                )
              : Text(
                  _currentTask.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTaskPriority() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _isEditing
              ? DropdownButton<TaskPriority>(
                  value: _selectedPriority,
                  onChanged: (TaskPriority? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    }
                  },
                  dropdownColor: AppColors.surfaceCard,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  items: TaskPriority.values.map((TaskPriority priority) {
                    return DropdownMenuItem<TaskPriority>(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            priority.icon,
                            color: priority.color,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(priority.label),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : Row(
                  children: [
                    Icon(
                      _currentTask.priority.icon,
                      color: _currentTask.priority.color,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _currentTask.priority.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPomodoroProgress() {
    final progress =
        _currentTask.pomodoroCount / _currentTask.estimatedPomodoros;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pomodoro Progress',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentTask.pomodoroCount} / ${_currentTask.estimatedPomodoros}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accentPurple,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: Icon(
                  CupertinoIcons.timer,
                  color: AppColors.accentPurple,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartPomodoroButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple,
            AppColors.accentPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startPomodoro,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.play_fill,
                  color: AppColors.textInverse,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Start Pomodoro',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPomodoroView() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = 1.0 - (_remainingSeconds / _totalSeconds);

    int minute1 = 2;
    int minute2 = 5;

    return Scaffold(
      backgroundColor: AppColors.redShade,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button

              Text(
                'set your timer',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(48),
                        ),
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 0.5,
                          enableInfiniteScroll: true,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.4,
                          scrollDirection: Axis.vertical,
                          autoPlay: false,
                          pageSnapping: true,
                          viewportFraction: 0.45, // Shows 3 items at once
                          onPageChanged: (index, reason) {
                            print('Page changed: $index');
                            setState(() {
                              minute1 = index + 1;
                            });
                          },

                          initialPage: minute1 - 1,
                        ),
                        items: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                            .map((e) => Center(
                                  child: Text(
                                    e.toString(),
                                    style: AppTextStyles.h1.copyWith(
                                      fontFamily: 'Poppins',
                                      color: e == minute1
                                          ? AppColors.redShade
                                          : const Color.fromARGB(
                                              255, 255, 218, 220),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 180,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.xs,
                  ),
                  Expanded(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(48),
                        ),
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 0.5,
                          enableInfiniteScroll: true,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.4,
                          scrollDirection: Axis.vertical,
                          autoPlay: false,
                          pageSnapping: true,
                          viewportFraction: 0.45, // Shows 3 items at once
                          onPageChanged: (index, reason) {
                            setState(() {
                              minute2 = index + 1;
                            });
                          },

                          initialPage: minute2 - 1,
                        ),
                        items: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                            .map((e) => Builder(
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: Text(
                                        e.toString(),
                                        style: AppTextStyles.h1.copyWith(
                                          fontFamily: 'Poppins',
                                          color: e == minute2
                                              ? AppColors.redShade
                                              : const Color.fromARGB(
                                                  255, 255, 218, 220),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 180,
                                        ),
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),

              // Task title
              // Text(
              //   _currentTask.title,
              //   style: AppTextStyles.h1.copyWith(
              //     color: AppColors.textPrimary,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.center,
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ).animate().fadeIn(duration: 3000.ms).slideY(
              //     begin: -0.3, duration: 3000.ms, curve: Curves.easeOutCubic),

              const Spacer(),

              // Circular timer
              // _buildCircularTimer(progress, minutes, seconds)
              //     .animate()
              //     .fadeIn(duration: 3000.ms, delay: 500.ms)
              //     .scale(
              //         begin: const Offset(0.8, 0.8),
              //         duration: 3000.ms,
              //         curve: Curves.easeOutBack),

              // const Spacer(),

              // // Timer controls
              // _buildTimerControls()
              //     .animate()
              //     .fadeIn(duration: 3000.ms, delay: 1000.ms)
              //     .slideY(
              //         begin: 0.5,
              //         duration: 3000.ms,
              //         curve: Curves.easeOutCubic),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularTimer(double progress, int minutes, int seconds) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassBackground,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
          ),

          // Progress circle
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentPurple,
              ),
            ),
          ),

          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isTimerRunning
                    ? 'Focus Time'
                    : _isTimerPaused
                        ? 'Paused'
                        : 'Ready',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Stop button
        _buildControlButton(
          icon: CupertinoIcons.stop_fill,
          onTap: _stopTimer,
          color: AppColors.statusError,
        ),

        // Play/Pause button
        _buildControlButton(
          icon: _isTimerRunning
              ? CupertinoIcons.pause_fill
              : CupertinoIcons.play_fill,
          onTap: _isTimerRunning ? _pauseTimer : _resumeTimer,
          color: AppColors.accentPurple,
          isLarge: true,
        ),

        // Reset button (placeholder for future functionality)
        _buildControlButton(
          icon: CupertinoIcons.refresh,
          onTap: () {
            setState(() {
              _remainingSeconds = _totalSeconds;
            });
          },
          color: AppColors.accentBlue,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    final iconSize = isLarge ? 32.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}

import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/providers/streak_provider.dart';
import 'package:unstack/providers/task_provider.dart';
import 'package:unstack/theme/theme.dart';
import 'package:unstack/widgets/delete_task_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Function to show profile modal sheet
void showProfileModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundPrimary,
    builder: (context) => const ProfileModalSheet(),
  );
}

class ProfileModalSheet extends StatefulWidget {
  const ProfileModalSheet({super.key});

  @override
  State<ProfileModalSheet> createState() => _ProfileModalSheetState();
}

class _ProfileModalSheetState extends State<ProfileModalSheet> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'User';
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundPrimary,
            AppColors.backgroundSecondary.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.xxl),
          topRight: Radius.circular(AppBorderRadius.xxl),
        ),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Balance the close button
                Text(
                  'Settings',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditUsernameSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTipsAndTricksSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFeedbackAndCreditsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMadeBySection(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    ).slideUpStandard();
  }

  Widget _buildEditUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PROFILE'),
        _buildSettingsContainer([
          _buildSettingsRow(
            title: 'Edit Username',
            onTap: () {
              HapticFeedback.lightImpact();
              _showEditUsernameDialog();
            },
            showArrow: true,
          ),
          _buildDivider(),
          _buildSettingsRow(
            title: 'Reset Data',
            onTap: () async {
              final result = await showDeleteDialog(
                    context: context,
                    onDelete: () async {
                      // Reset all app data
                      final taskProvider =
                          Provider.of<TaskProvider>(context, listen: false);
                      await taskProvider.deleteAllTasks();

                      if (mounted) {
                        final streakProvider =
                            Provider.of<StreakProvider>(context, listen: false);
                        await streakProvider.resetStreak();
                      }

                      HapticFeedback.heavyImpact();
                      if (mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    title: 'Reset Data',
                    description:
                        'This will delete all tasks and reset app settings. Your username will be preserved. This action cannot be undone.',
                    buttonTitle: 'Reset',
                  ) ??
                  false;

              if (result) {
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('App data has been reset successfully'),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                }
              }
            },
            warning: true,
            showArrow: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildTipsAndTricksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TIPS & TRICKS'),
        _buildSettingsContainer([
          _buildSettingsRow(
            title: 'How to use the app',
            onTap: () => _showComingSoonDialog('App Tutorial'),
            showArrow: true,
          ),
          _buildDivider(),
          _buildSettingsRow(
            title: 'How to set up the widget',
            onTap: () => _showComingSoonDialog('Widget Setup'),
            showArrow: true,
          ),
        ]),
      ],
    );
  }

  Future<void> _launchPlayStore() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildFeedbackAndCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('FEEDBACK & CREDITS'),
        _buildSettingsContainer([
          _buildSettingsRow(
            title: 'Rate the app on the Play Store',
            onTap: _launchPlayStore,
            showArrow: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildMadeBySection() {
    return Center(
      child: Text(
        'Made by Pratik JH',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        bottom: AppSpacing.md,
        top: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundSecondary.withValues(alpha: 0.6),
            AppColors.backgroundSecondary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsRow({
    required String title,
    required VoidCallback onTap,
    bool warning = false,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: warning ? AppColors.redShade : AppColors.textPrimary,
                  ),
                ),
              ),
              if (showArrow)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      height: 1,
      color: AppColors.glassBorder.withValues(alpha: 0.2),
    );
  }

  void _showEditUsernameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _userName);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      enableDrag: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xxl)),
        side: BorderSide(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      backgroundColor: AppColors.backgroundPrimary,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Username',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.whiteColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Enter your username',
                  hintStyle: AppTextStyles.h2.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ChicletAnimatedButton(
                width: double.infinity,
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user_name', newName);
                    if (mounted) {
                      setState(() {
                        _userName = newName;
                      });
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      HapticFeedback.lightImpact();
                    }
                  }
                },
                child: Text(
                  'Save',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundPrimary.withValues(alpha: 0.95),
                  AppColors.backgroundSecondary.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentBlue.withValues(alpha: 0.2),
                        AppColors.accentPurple.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.accentBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '$feature will be available in a future update.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whiteColor,
                      foregroundColor: AppColors.blackColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Got it',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).scaleInStandard(
          scale: AnimationConstants.largeScale,
        );
      },
    );
  }
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool _isEditMode = false;
  bool _isPremium = false;
  String _userName = '';
  String _userEmail = '';

  // Controllers for edit mode
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = true;

  late AnimationController _avatarAnimationController;
  late Animation<double> _avatarAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _avatarAnimationController = AnimationController(
      duration: AnimationConstants.breathing,
      vsync: this,
    );
    _avatarAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: AnimationConstants.standardCurve,
    ));

    // Start the breathing animation
    _avatarAnimationController.repeat(reverse: true);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'User';
        _userEmail = prefs.getString('user_email') ?? 'user@example.com';
        _isPremium = prefs.getBool('is_premium') ?? true;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;

        // Initialize controllers
        _nameController.text = _userName;
        _emailController.text = _userEmail;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('vibration_enabled', _vibrationEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);

      setState(() {
        _userName = _nameController.text;
        _userEmail = _emailController.text;
        _isEditMode = false;
      });

      HapticFeedback.lightImpact();
      _showSuccessMessage();
    } catch (e) {
      _showErrorMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.statusSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update profile'),
        backgroundColor: AppColors.statusError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: _isEditMode ? 200 : 230,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(_isEditMode ? Icons.check : Icons.edit, size: 18),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_isEditMode) {
                      _saveUserData();
                    } else {
                      setState(() {
                        _isEditMode = true;
                      });
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  if (_isEditMode) ...[
                    _buildEditForm()
                        .slideUpStandard(delay: AnimationConstants.mediumDelay),
                  ] else ...[
                    _buildSettingsList()
                        .slideUpStandard(delay: AnimationConstants.mediumDelay),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSubscriptionCard()
                        .slideUpStandard(delay: AnimationConstants.mediumDelay),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAchievementsCard()
                        .slideUpStandard(delay: AnimationConstants.longDelay),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 120, // Space for status bar and nav
        bottom: AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        children: [
          // Avatar with breathing animation
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _avatarAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _avatarAnimation.value,
                    child: Stack(
                      children: [
                        Container(
                          width: _isEditMode ? 80 : 120,
                          height: _isEditMode ? 80 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.whiteColor,
                                AppColors.glassBackground,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPurple
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'U',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: _isEditMode ? 32 : 48,
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isEditMode) ...[
                      const SizedBox(height: AppSpacing.lg),
                      // User Info
                      Text(
                        _userName,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        _userEmail,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (_isPremium) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentYellow,
                                AppColors.accentOrange,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.full),
                          ),
                          child: Text(
                            'Premium Member',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassBackground,
            AppColors.glassBackground.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile Information',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Name Field
          _buildEditField(
            label: 'Name',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Email Field
          _buildEditField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Cancel',
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                      // Reset controllers
                      _nameController.text = _userName;
                      _emailController.text = _userEmail;
                    });
                  },
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  label: 'Save',
                  onPressed: _saveUserData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.textMuted,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceCard.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(
                color: AppColors.accentPurple,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isSecondary
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentPurple,
                  AppColors.accentBlue,
                ],
              ),
        color: isSecondary ? AppColors.surfaceCard : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: isSecondary ? AppColors.glassBorder : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSecondary ? Colors.black : AppColors.accentPurple)
                .withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.buttonLarge.copyWith(
                color:
                    isSecondary ? AppColors.textPrimary : AppColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // New modern profile page methods
  Widget _buildSettingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'Settings',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildModernSettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive task reminders',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildModernSettingItem(
          icon: Icons.volume_up_outlined,
          title: 'Sound',
          subtitle: 'Play notification sounds',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildModernSettingItem(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Haptic feedback',
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
        _buildModernSettingItem(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Use dark theme',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModernSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.accentPurple,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.lightImpact();
            onChanged(newValue);
          },
          activeColor: AppColors.accentPurple,
          activeTrackColor: AppColors.accentPurple.withValues(alpha: 0.3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: _isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentYellow.withValues(alpha: 0.2),
                  AppColors.accentOrange.withValues(alpha: 0.1),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundSecondary.withValues(alpha: 0.3),
                  AppColors.backgroundSecondary.withValues(alpha: 0.1),
                ],
              ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: _isPremium
              ? AppColors.accentYellow.withValues(alpha: 0.3)
              : AppColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isPremium ? Icons.star : Icons.upgrade,
                color: _isPremium
                    ? AppColors.accentYellow
                    : AppColors.accentPurple,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _isPremium ? 'Premium Member' : 'Free Plan',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _isPremium
                      ? AppColors.accentYellow
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isPremium
                ? 'Enjoy unlimited tasks and premium features'
                : 'Upgrade to unlock unlimited tasks and premium features',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Handle subscription action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPremium
                    ? AppColors.backgroundSecondary
                    : AppColors.accentPurple,
                foregroundColor:
                    _isPremium ? AppColors.textPrimary : AppColors.textInverse,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
              child: Text(
                _isPremium ? 'Manage Subscription' : 'Upgrade to Premium',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: AppColors.accentBlue,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Achievements',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 18,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Achievement badges and progress tracking will be available in a future update.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

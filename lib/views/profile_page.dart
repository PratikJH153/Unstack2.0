import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unstack/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
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
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _avatarAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.easeInOut,
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
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
                  ] else ...[
                    _buildSettingsList()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSubscriptionCard()
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAchievementsCard()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, duration: 500.ms),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassBackground,
              AppColors.glassBackground.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: AppColors.glassBorder,
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
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      title: Text(
        _isEditMode ? 'Edit Profile' : 'Profile',
        style: AppTextStyles.h2,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(
            right: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassBackground,
                AppColors.glassBackground.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.glassBorder,
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
                        if (_isPremium)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentYellow,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentYellow
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.star,
                                color: AppColors.textPrimary,
                                size: _isEditMode ? 12 : 16,
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

  Widget _buildSettingsSection() {
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
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSettingItem(
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
          _buildSettingItem(
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
          _buildSettingItem(
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
          _buildSettingItem(
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
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: AppColors.accentPurple,
            activeTrackColor: AppColors.accentPurple.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceCard,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isPremium
              ? [
                  AppColors.accentYellow.withValues(alpha: 0.2),
                  AppColors.accentOrange.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.glassBackground,
                  AppColors.glassBackground.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: _isPremium ? AppColors.accentYellow : AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (_isPremium)
            BoxShadow(
              color: AppColors.accentYellow.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isPremium ? Icons.star : Icons.star_outline,
                color: _isPremium
                    ? AppColors.accentYellow
                    : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                _isPremium ? 'Premium Member' : 'Subscription',
                style: AppTextStyles.h3.copyWith(
                  color: _isPremium
                      ? AppColors.accentYellow
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isPremium) ...[
            Text(
              'You have access to all premium features including unlimited tasks, advanced analytics, and priority support.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButton(
              label: 'Manage Subscription',
              onPressed: () {
                // Handle subscription management
                _showComingSoonDialog('Subscription Management');
              },
              isSecondary: true,
            ),
          ] else ...[
            Text(
              'Upgrade to Premium for unlimited tasks, advanced features, and priority support.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButton(
              label: 'Upgrade to Premium',
              onPressed: () {
                // Handle premium upgrade
                _showComingSoonDialog('Premium Upgrade');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
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
          BoxShadow(
            color: AppColors.accentGreen.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: AppColors.accentGreen,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Achievements',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Coming Soon Content
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.construction_outlined,
                    color: AppColors.textMuted,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Achievement badges and progress tracking will be available in a future update.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
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

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
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
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentBlue,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.h3,
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
                _buildActionButton(
                  label: 'Got it',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
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

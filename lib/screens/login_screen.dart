import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.orange.shade600,
              Colors.red.shade700,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Game Logo/Title
                              _buildGameTitle(),
                              const SizedBox(height: 48),

                              // Welcome Message
                              _buildWelcomeMessage(),
                              const SizedBox(height: 48),

                              // Sign In Card
                              _buildSignInCard(),
                              const SizedBox(height: 24),

                              // Footer
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Column(
      children: [
        // Game Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.casino,
            size: 40,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 16),

        // Game Title
        Text(
          'अंदर बाहर',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Andar Bahar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Welcome to the Traditional Indian Card Game',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with Google to save your progress and compete with friends!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sign In Title
              Text(
                'Sign In Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'To play Andar Bahar and access all features, please sign in with your Google account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (authProvider.errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => authProvider.clearError(),
                        child: Icon(Icons.close, color: Colors.red.shade600, size: 16),
                      ),
                    ],
                  ),
                ),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isSigningIn ? null : () async {
                    AudioService.playClick();
                    await authProvider.signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[700],
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  icon: authProvider.isSigningIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.asset(
                          'assets/images/google_logo.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.account_circle, size: 20, color: Colors.grey[600]);
                          },
                        ),
                  label: Text(
                    authProvider.isSigningIn ? 'Signing In...' : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By signing in, you agree to our Terms of Service and Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enjoy the traditional Indian card game experience!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
} 
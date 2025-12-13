import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFB0E0E6), // Powder blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF87CEEB),
                                Color(0xFFB0E0E6),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF87CEEB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'CareRing',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Subtitle
                        Text(
                          'Your personal health companion for monitoring vital signs and staying safe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Feature List
                        _buildFeatureItem(
                          icon: Icons.favorite,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF87CEEB),
                          cardColor: const Color(0xFFF0F8FF),
                          title: 'Health Monitoring',
                          description:
                          'Track heart rate, blood oxygen, steps, and sleep',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.shield,
                          iconColor: Colors.black87,
                          backgroundColor: const Color(0xFFFFE66D),
                          cardColor: const Color(0xFFFFF9E6),
                          title: 'Emergency SOS',
                          description:
                          'Automatic alerts when health values are concerning',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.medication,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFFFF6B9D),
                          cardColor: const Color(0xFFFFE8E8),
                          title: 'Medication Reminders',
                          description:
                          'Never miss your medications with timely alerts',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.notifications,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF98D8C8),
                          cardColor: const Color(0xFFE8F5E9),
                          title: 'Smart Alerts',
                          description:
                          'Get notified about important health changes',
                        ),
                        const SizedBox(height: 40),

                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: onGetStarted,
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF87CEEB),
                                    Color(0xFFB0E0E6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Text
                        Text(
                          'Designed for easy use with large buttons and clear text',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color cardColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to use with navigation:
/*
class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _showWelcome = true;

  void _handleGetStarted() {
    setState(() {
      _showWelcome = false;
    });
    // Or navigate to main app:
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => DashboardScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) {
      return WelcomeScreen(onGetStarted: _handleGetStarted);
    }
    return DashboardScreen();
  }
}
*/

// Alternative: Animated version with scale animation on button hover
class AnimatedWelcomeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedWelcomeButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<AnimatedWelcomeButton> createState() => _AnimatedWelcomeButtonState();
}

class _AnimatedWelcomeButtonState extends State<AnimatedWelcomeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF87CEEB).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


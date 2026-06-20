import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Декоративный светящийся фон (как на главном экране)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _limeAccent.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Логотип и заголовок
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _limeAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _limeAccent.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.auto_awesome, color: _limeAccent, size: 40),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Добро пожаловать в\nYoda",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Ваш путь к идеальному телу начинается здесь. Авторизуйтесь, чтобы продолжить.",
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  
                  // Кнопки авторизации
                  _buildAuthButton(
                    onTap: () => context.go('/onboarding'),
                    icon: Icons.apple,
                    label: "Войти с Apple",
                    isDark: true,
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    onTap: () => context.go('/onboarding'),
                    icon: Icons.g_mobiledata_rounded, // Имитация Google иконки
                    label: "Войти с Google",
                    isDark: false,
                    customIcon: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://www.gstatic.com/images/branding/product/2x/googleg_96dp.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  // Футер
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: _textGrey, fontSize: 12, height: 1.5),
                        children: [
                          TextSpan(text: "Продолжая, вы соглашаетесь с\n"),
                          TextSpan(
                            text: "Условиями использования",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " и "),
                          TextSpan(
                            text: "Политикой конфиденциальности",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? customIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ?? Icon(icon, color: isDark ? Colors.black : Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

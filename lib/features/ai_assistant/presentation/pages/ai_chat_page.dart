import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../features/subscription/presentation/pages/paywall_page.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  int _messagesSentCount = 0;
  final int _freeLimit = 3;
  final bool _isPremium = false; // Mock status

  late final List<Map<String, dynamic>> _messages = [
    {
      'isAi': true,
      'text': 'Привет! Я твой персональный ИИ-ассистент Yoda. У тебя есть $_freeLimit бесплатных запроса. Чем могу помочь?',
      'time': DateFormat('HH:mm').format(DateTime.now()),
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    if (!_isPremium && _messagesSentCount >= _freeLimit) {
      _showLimitReachedSheet();
      return;
    }
    
    setState(() {
      _messages.add({
        'isAi': false,
        'text': _messageController.text,
        'time': DateFormat('HH:mm').format(DateTime.now()),
      });
      _messagesSentCount++;
      _messageController.clear();
    });

    // Mock AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isAi': true,
            'text': 'Хороший вопрос! На основе твоего ИМТ и уровня активности, я рекомендую добавить 20 минут кардио сегодня вечером.',
            'time': DateFormat('HH:mm').format(DateTime.now()),
          });
        });
      }
    });
  }

  void _showLimitReachedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _limeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _limeAccent.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: _limeAccent, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              "Лимит достигнут",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Для продолжения общения с ИИ разблокируйте Yoda PRO. Это даст вам безлимитные запросы и персональные инсайты.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPaywall();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: _limeAccent.withValues(alpha: 0.4),
                ),
                child: const Text("РАЗБЛОКИРОВАТЬ PRO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _limeAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _limeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _limeAccent.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.auto_awesome, color: _limeAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yoda AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Персональный ассистент', style: TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['isAi'], msg['text'], msg['time']);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isAi, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              color: isAi ? _cardColor : _limeAccent,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isAi ? 0 : 24),
                bottomRight: Radius.circular(isAi ? 24 : 0),
              ),
              border: isAi ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
              boxShadow: isAi ? [] : [
                BoxShadow(
                  color: _limeAccent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isAi ? Colors.white : Colors.black,
                fontSize: 15,
                height: 1.4,
                fontWeight: isAi ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(time, style: const TextStyle(color: _textGrey, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = ['Анализ веса', 'План питания', 'Совет дня'];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(actions[index]),
              backgroundColor: _cardColor,
              labelStyle: const TextStyle(color: _limeAccent, fontSize: 12, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), 
                side: BorderSide(color: _limeAccent.withValues(alpha: 0.15))
              ),
              onPressed: () {
                _messageController.text = actions[index];
                _sendMessage();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Спроси что-нибудь...',
                  hintStyle: TextStyle(color: _textGrey, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _limeAccent, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _limeAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

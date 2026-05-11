import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/core/di/injection.dart';
import 'package:smart_scale/core/notifications/notification_service.dart';
import 'package:smart_scale/features/reminders/presentation/bloc/reminders_bloc.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  Future<void> _onSavePressed(BuildContext context) async {
    final bloc = context.read<RemindersBloc>();
    final notificationService = getIt<NotificationService>();
    final reminder = bloc.state.reminder;

    if (!reminder.isEnabled) {
      bloc.add(const ReminderSaveRequested());
      return;
    }

    final hasPermission = await notificationService.canScheduleExactAlarms();

    if (!hasPermission && context.mounted) {
      await _showPermissionDialog(context, notificationService);
    } else {
      bloc.add(const ReminderSaveRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RemindersBloc, RemindersState>(
      listener: (context, state) {
        if (state.status == RemindersStatus.saved) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == RemindersStatus.loading || state.status == RemindersStatus.initial) {
          return const Scaffold(
            backgroundColor: _bgColor,
            body: Center(child: CircularProgressIndicator(color: _limeAccent)),
          );
        }

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: _buildAppBar(context),
          body: _buildContent(context, state),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        "Напоминания",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () => _onSavePressed(context),
          child: const Text(
            "ГОТОВО",
            style: TextStyle(color: _limeAccent, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        )
      ],
    );
  }

  Widget _buildContent(BuildContext context, RemindersState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Регулярные взвешивания помогут вам быстрее достичь своей цели.",
            style: TextStyle(color: _textGrey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildReminderCard(context, state),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, RemindersState state) {
    final reminder = state.reminder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Утреннее взвешивание",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: reminder.isEnabled,
                onChanged: (value) => context.read<RemindersBloc>().add(ReminderIsEnabledChanged(value)),
                activeColor: _limeAccent,
                activeTrackColor: _limeAccent.withOpacity(0.5),
                inactiveThumbColor: _textGrey,
                inactiveTrackColor: const Color(0xFF2C2C2E),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectTime(context, reminder.time),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Время",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    reminder.time.format(context),
                    style: const TextStyle(color: _limeAccent, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _limeAccent,
              onPrimary: Colors.black,
              surface: _cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      context.read<RemindersBloc>().add(ReminderTimeChanged(picked));
    }
  }

  Future<void> _showPermissionDialog(BuildContext context, NotificationService service) {
    return showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Нужно разрешение", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Для точных напоминаний Android требует специальное разрешение. Нажмите 'Открыть', чтобы перейти в настройки и включить его для нашего приложения.",
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: const Text("Отмена", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dContext).pop();
              service.requestExactAlarmsPermission();
            },
            child: const Text("Открыть", style: TextStyle(color: _limeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

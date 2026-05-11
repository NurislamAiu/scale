import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class MyDevicesPage extends StatelessWidget {
  const MyDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Start scanning immediately when entering the page
    context.read<ScaleBloc>().add(const ScaleScanStarted());

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Мои устройства",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ScaleBloc, ScaleState>(
        builder: (context, state) {
          final isScanning = state.status == ScaleStatus.scanning;
          final scanResults = state.scanResults;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  isScanning 
                      ? "Идет поиск устройств поблизости..."
                      : "Нажмите на устройство для подключения.",
                  style: const TextStyle(color: _textGrey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isScanning)
                const LinearProgressIndicator(
                  backgroundColor: _cardColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_limeAccent),
                ),
              Expanded(
                child: scanResults.isEmpty && !isScanning
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: scanResults.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final device = scanResults[index];
                          final deviceName = device.device.platformName.isNotEmpty 
                              ? device.device.platformName 
                              : "Неизвестное устройство";

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: const Icon(Icons.monitor_weight_outlined, color: _limeAccent),
                            title: Text(
                              deviceName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              device.device.remoteId.toString(),
                              style: const TextStyle(color: _textGrey, fontSize: 12),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: _textGrey,
                            ),
                            onTap: () {
                              // Logic to connect to the device
                              context.read<ScaleBloc>().add(ScaleDeviceSelected(device.device));
                              context.pop(); // Go back after selection
                            },
                          );
                        },
                      ),
              ),
              _buildScanButton(context, isScanning),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bluetooth_disabled_rounded, size: 64, color: _textGrey),
          SizedBox(height: 16),
          Text(
            "Устройства не найдены",
            style: TextStyle(color: _textGrey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            "Убедитесь, что весы включены и Bluetooth активен",
            style: TextStyle(color: Color(0xFF505050), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, bool isScanning) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: () {
            final bloc = context.read<ScaleBloc>();
            if (isScanning) {
              bloc.add(const ScaleScanStopped());
            } else {
              bloc.add(const ScaleScanStarted());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isScanning ? Colors.redAccent : _limeAccent,
            foregroundColor: isScanning ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          icon: isScanning ? const Icon(Icons.stop_rounded) : const Icon(Icons.refresh_rounded),
          label: Text(
            isScanning ? "ОСТАНОВИТЬ" : "ИСКАТЬ СНОВА",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

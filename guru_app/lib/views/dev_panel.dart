import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/socket_controller.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/utils/utils.dart';

class DevPanel extends StatefulWidget {
  const DevPanel({Key? key}) : super(key: key);

  @override
  State<DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends State<DevPanel> {
  @override
  void initState() {
    super.initState();
    AppLogger.onLogAdded = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    AppLogger.onLogAdded = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socket = Get.find<SocketController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevPanel Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.error),
            onPressed: () {
              AppLogger.clear();
              setState(() {});
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ENVIRONMENT DIAGNOSTICS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondaryLight),
              ),
              AppSpacing.v8,
              _buildEnvCard(socket),
              AppSpacing.v20,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SYSTEM REAL-TIME LOGS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryLight),
                  ),
                  Text(
                    '${AppLogger.logs.length} cached',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                  )
                ],
              ),
              AppSpacing.v8,
              _buildLogsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvCard(SocketController socket) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.s8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildEnvRow('WS Server Address', 'ws://localhost:8080/ws',
              active: true),
          _buildEnvRow('100ms Token Server', 'http://localhost:8080/token',
              active: true),
          Obx(() => _buildEnvRow(
              'Socket Status',
              socket.isConnected.value
                  ? 'CONNECTED'
                  : (socket.isConnecting.value
                      ? 'CONNECTING...'
                      : 'DISCONNECTED'),
              active: socket.isConnected.value)),
          _buildEnvRow('STITCH_PROJECT_ID', '11625270295727977801 (Masked)',
              active: true),
          _buildEnvRow(
              '100ms API Key', '•••••••••••••••••••••••••••••••• (Masked)',
              active: false),
        ],
      ),
    );
  }

  Widget _buildEnvRow(String key, String value, {required bool active}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color:
                    active ? AppColors.success : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final logs = AppLogger.logs.reversed.toList();

    if (logs.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No logs cached yet. Trigger some actions!',
            style: TextStyle(color: AppColors.textSecondaryLight)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final tagColor = exportColorForTag(log.tag);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(AppSpacing.s8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppSpacing.s4),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor),
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    log.timestamp.toIso8601String().substring(11, 19),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondaryLight),
                  ),
                  const Spacer(),
                  Text(
                    log.level,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: log.level == 'ERROR'
                          ? AppColors.error
                          : (log.level == 'WARN'
                              ? AppColors.warning
                              : AppColors.success),
                    ),
                  ),
                ],
              ),
              AppSpacing.v4,
              Text(
                log.message,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        );
      },
    );
  }
}

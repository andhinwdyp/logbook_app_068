import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final String log;

  const HistoryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    if (log.contains("NAIK")) {
      statusColor = const Color(0xFFB8E0D2);
      statusIcon = Icons.trending_up;
    } else if (log.contains("TURUN")) {
      statusColor = const Color(0xFFF8C8DC);
      statusIcon = Icons.trending_down;
    } else {
      statusColor = const Color(0xFFE0E0E0);
      statusIcon = Icons.restore;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusColor, width: 5),
        ),
      ),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          log,
          style: const TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 
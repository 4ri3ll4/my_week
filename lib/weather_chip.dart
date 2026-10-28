import 'package:flutter/material.dart';

import 'weather.dart';

class WeatherChip extends StatefulWidget {
  const WeatherChip({super.key});

  @override
  State<WeatherChip> createState() => _WeatherChipState();
}

class _WeatherChipState extends State<WeatherChip> {
  Weather? weather;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await fetchWeather();
      if (!mounted) return;
      setState(() {
        weather = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Weather unavailable';
      });
    }
  }

  IconData _iconFor(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 95) return Icons.thunderstorm;
    if (code >= 51) return Icons.water_drop;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: loading
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading weather…', style: TextStyle(fontSize: 13)),
        ],
      )
          : error != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 6),
          Text(
            error!,
            style: TextStyle(fontSize: 13, color: Colors.red.shade900),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: load,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.teal.shade700,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 13)),
          ),
        ],
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(weather!.code),
              size: 18, color: Colors.teal.shade700),
          const SizedBox(width: 6),
          Text(
            'Kigali · ${weather!.temperature.round()}°C · ${describe(weather!.code)}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
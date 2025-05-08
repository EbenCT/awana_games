// lib/widgets/score_counter/game_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';

class GameTimer extends StatefulWidget {
  final int initialDuration; // en segundos
  final Function() onTimeUp;
  final bool isActive;

  const GameTimer({
    Key? key,
    required this.initialDuration,
    required this.onTimeUp,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  late Timer _timer;
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDuration;
    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isComplete = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isRunning = false;
          _isComplete = true;
          _timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    if (_isRunning) {
      _timer.cancel();
    }
    setState(() {
      _remainingSeconds = widget.initialDuration;
      _isRunning = false;
      _isComplete = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: _isComplete 
                      ? Colors.red 
                      : (_isRunning 
                          ? Theme.of(context).colorScheme.primary 
                          : isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temporizador',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _isComplete 
                        ? Colors.red 
                        : (_isRunning 
                            ? Theme.of(context).colorScheme.primary 
                            : isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isComplete
                        ? Colors.red.withOpacity(0.2)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _isComplete
                            ? Colors.red.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 36 * value,
                        fontWeight: FontWeight.bold,
                        color: _isComplete
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isRunning ? Icons.pause : Icons.play_arrow,
                  label: _isRunning ? 'Pausar' : 'Iniciar',
                  color: _isRunning ? Colors.orange : Colors.green,
                  onPressed: _isComplete
                      ? null
                      : (_isRunning ? _pauseTimer : _startTimer),
                ),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reiniciar',
                  color: Colors.blue,
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
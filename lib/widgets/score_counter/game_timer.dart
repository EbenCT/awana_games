// lib/widgets/score_counter/game_timer.dart (versión más compacta)
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
    final timerColor = _isComplete 
        ? Colors.red 
        : (_isRunning 
            ? Theme.of(context).colorScheme.primary 
            : isDarkMode ? Colors.grey[400] : Colors.grey[600]);
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reducido el padding
        child: Row(
          children: [
            // Icono y tiempo
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: timerColor,
                    size: 20, // Tamaño reducido
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 20, // Tamaño reducido
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botones de control
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  icon: _isRunning ? Icons.pause : Icons.play_arrow,
                  color: _isRunning ? Colors.orange : Colors.green,
                  onPressed: _isComplete
                      ? null
                      : (_isRunning ? _pauseTimer : _startTimer),
                  tooltip: _isRunning ? 'Pausar' : 'Iniciar',
                ),
                const SizedBox(width: 4),
                _buildControlButton(
                  icon: Icons.refresh,
                  color: Colors.blue,
                  onPressed: _resetTimer,
                  tooltip: 'Reiniciar',
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
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (onPressed != null) 
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: (onPressed != null) ? color : Colors.grey,
              size: 20, // Tamaño reducido
            ),
          ),
        ),
      ),
    );
  }
}
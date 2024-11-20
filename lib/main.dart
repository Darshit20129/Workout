import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Half Marathon Trainer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TrainingPlanScreen(),
    );
  }
}

// Training Plan Data: Full Couch-to-Half Marathon Plan
final List<Map<String, dynamic>> trainingPlan = [
  // Week 1
  {'day': 'Monday', 'activity': 'Run 1 min, Walk 2 min (Repeat 6x)', 'duration': 18},
  {'day': 'Tuesday', 'activity': 'Walk 30 min', 'duration': 30},
  {'day': 'Wednesday', 'activity': 'Run 1 min, Walk 2 min (Repeat 8x)', 'duration': 24},
  {'day': 'Thursday', 'activity': 'Rest Day', 'duration': 0},
  {'day': 'Friday', 'activity': 'Run 2 min, Walk 2 min (Repeat 5x)', 'duration': 20},
  {'day': 'Saturday', 'activity': 'Walk 40 min', 'duration': 40},
  {'day': 'Sunday', 'activity': 'Run 3 min, Walk 2 min (Repeat 4x)', 'duration': 20},
  // Additional weeks...
  {'day': 'Monday', 'activity': 'Run 5 min, Walk 1 min (Repeat 6x)', 'duration': 36},
  {'day': 'Tuesday', 'activity': 'Walk 45 min', 'duration': 45},
  // Continue with all days leading up to the half marathon.
];

// For progress tracking
List<bool> progress = List<bool>.filled(trainingPlan.length, false);

class TrainingPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Training Plan')),
      body: ListView.builder(
        itemCount: trainingPlan.length,
        itemBuilder: (context, index) {
          final plan = trainingPlan[index];
          return ListTile(
            title: Text(plan['day']),
            subtitle: Text(plan['activity']),
            trailing: progress[index]
                ? Icon(Icons.check_circle, color: Colors.green)
                : Text('${plan['duration']} mins'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(
                    index: index,
                    day: plan['day'],
                    activity: plan['activity'],
                    duration: plan['duration'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  final int index;
  final String day;
  final String activity;
  final int duration;

  WorkoutScreen({required this.index, required this.day, required this.activity, required this.duration});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Timer? _timer;
  int _elapsedTime = 0;
  int _currentCycle = 0;
  String _currentActivity = 'Starting soon...';
  bool isPaused = false;

  void startWorkout() {
    setState(() {
      _elapsedTime = 0;
      _currentCycle = 1;
      _currentActivity = 'Running...';
    });
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (!isPaused) {
        setState(() {
          _elapsedTime += 1;
          if (_elapsedTime % 2 == 0) {
            _currentActivity = 'Walking...';
          } else {
            _currentActivity = 'Running...';
          }
          _currentCycle = (_elapsedTime ~/ 3) + 1;
          if (_elapsedTime >= widget.duration) {
            _timer?.cancel();
            progress[widget.index] = true; // Mark as completed
            _currentActivity = 'Workout Complete!';
          }
        });
      }
    });
  }

  void pauseWorkout() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeWorkout() {
    setState(() {
      isPaused = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.day} Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.activity,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text('Elapsed Time: $_elapsedTime min', style: TextStyle(fontSize: 18)),
            Text('Cycle: $_currentCycle', style: TextStyle(fontSize: 18)),
            Text('Current Activity: $_currentActivity', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startWorkout,
                  child: Text('Start Workout'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isPaused ? resumeWorkout : pauseWorkout,
                  child: Text(isPaused ? 'Resume' : 'Pause'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:family_speed_selector/family_speed_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  timeDilation = 1;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: _Demo(),
      ),
    );
  }
}

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  TransactionSpeed _speed = TransactionSpeed.normal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: FamilySpeedSelector(
          speed: _speed,
          onChanged: (speed) {
            setState(() => _speed = speed);
          },
        ),
      ),
    );
  }
}

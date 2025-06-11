import 'package:flutter/material.dart';

class EmptyWidgets extends StatefulWidget {
  const EmptyWidgets({super.key});

  @override
  State<EmptyWidgets> createState() => _EmptyWidgetsState();
}

class _EmptyWidgetsState extends State<EmptyWidgets> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
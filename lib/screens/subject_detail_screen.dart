import 'package:flutter/material.dart';

class SubjectDetailScreen extends StatelessWidget {
  final dynamic subject;

  const SubjectDetailScreen({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المادة'),
      ),
      body: Center(
        child: Text('شاشة تفاصيل المادة - قيد التطوير'),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'triage_dashboard.dart';
import 'triage_form.dart';


void main() {
  runApp(RapiTriageApp());
}

class RapiTriageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapiTriage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TriageDashboard(),
      routes: {'/form': (context) => TriageForm()},
    );
  }
}

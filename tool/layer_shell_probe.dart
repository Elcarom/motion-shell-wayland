import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Native Motion layer shell',
            style: TextStyle(fontSize: 28),
          ),
        ),
      ),
    ),
  );
}

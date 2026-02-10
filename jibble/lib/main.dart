import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ApiTestApp());
}

class ApiTestApp extends StatelessWidget {
  const ApiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApiTestHome(),
    );
  }
}

class ApiTestHome extends StatefulWidget {
  const ApiTestHome({super.key});

  @override
  State<ApiTestHome> createState() => _ApiTestHomeState();
}

class _ApiTestHomeState extends State<ApiTestHome> {
  String result = "Press button to hit API";

  Future<void> hitApi() async {
    setState(() => result = "Loading...");

    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() => result = data['title']);
    } else {
      setState(() => result = "API Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Hit Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hitApi,
              child: const Text("Hit API"),
            ),
          ],
        ),
      ),
    );
  }
}

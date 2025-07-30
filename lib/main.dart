import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control IoT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String baseUrl =
      "https://esp-project-d56af-default-rtdb.europe-west1.firebasedatabase.app";
  int potenciometro = 0;
  int pin21 = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() => loading = true);
    final url = Uri.parse("$baseUrl/board1.json");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        potenciometro = data["inputs"]["potenciometro"] ?? 0;
        pin21 = data["outputs"]["digital"]["21"] ?? 0;
      });
    }
    setState(() => loading = false);
  }

  Future<void> togglePin21() async {
    final newValue = pin21 == 1 ? 0 : 1;
    final url = Uri.parse("$baseUrl/board1/outputs/digital/21.json");
    await http.put(url, body: newValue.toString());
    setState(() {
      pin21 = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control IoT'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Valor del Potenciómetro:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    potenciometro.toString(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Estado del Pin 21: ${pin21 == 1 ? 'ON' : 'OFF'}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: togglePin21,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pin21 == 1 ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      pin21 == 1 ? "APAGAR" : "ENCENDER",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: getData,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Actualizar"),
                  ),
                ],
              ),
      ),
    );
  }
}

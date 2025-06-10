import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'dart:convert';

class GetName {
  final String nameApi;

  GetName({required this.nameApi});

  factory GetName.fromJson(Map<String, dynamic> json) {
    return GetName(nameApi: json['name']);
  }
}

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  String name = '';

  Future<List<GetName>> getApi() async {
    final url = Uri.parse('https://api.restful-api.dev/objects');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => GetName.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener datos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text('Visualizar API', style: kTextStyleAppBar),
        iconTheme: kIconThemeColor,
      ),
      backgroundColor: kBackgroundColorApp,
      body: FutureBuilder<List<GetName>>(
        future: getApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final listMyAPI = snapshot.data as List<GetName>;
            return ListView.builder(
              itemCount: listMyAPI.length,
              itemBuilder: (context, index) {
                final myModel = listMyAPI[index];
                return ListTile(title: Text(myModel.nameApi));
              },
            );
          }
        },
      ),
    );
  }
}

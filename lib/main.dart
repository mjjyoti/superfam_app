import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superfam_app/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperFam App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> keyValues = [];

  @override
  void initState() {
    super.initState();
    _loadKeyValues();
  }

  Future<void> _loadKeyValues() async {
    final data = await dbHelper.getKeyValues();
    setState(() {
      keyValues = data;
    });
  }

  void _showBottomSheet() {
    final TextEditingController keyController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: InputDecoration(labelText: 'Key'),
              ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Value'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final key = keyController.text;
                      final value = valueController.text;
                      final name = nameController.text;
                      if (key.isNotEmpty &&
                          value.isNotEmpty &&
                          name.isNotEmpty) {
                        await dbHelper.insertKeyValue(key, value, name);
                        _loadKeyValues();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteKeyValue(int id) async {
    await dbHelper.deleteKeyValue(id);
    _loadKeyValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text('SuperFam App'),
      ),
      body: keyValues.isEmpty
          ? Center(child: Text('No key-value pairs added.'))
          : ListView.builder(
              itemCount: keyValues.length,
              itemBuilder: (context, index) {
                print(keyValues);
                final kv = keyValues[index];
                return Card(
                  color: Colors.amberAccent.shade100,
                  child: ListTile(
                    title: Text(
                      kv['key'],
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      kv['value'],
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: Text(
                      kv['name'],
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: IconButton(
                        onPressed: () => _deleteKeyValue(kv['id']),
                        icon: Icon(Icons.delete)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: _showBottomSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}

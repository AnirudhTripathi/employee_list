import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ReadListview extends StatefulWidget {
  const ReadListview({super.key});

  @override
  State<ReadListview> createState() => _ReadListviewState();
}

class _ReadListviewState extends State<ReadListview> {
  final _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Employee List',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Connection error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading... connection');
          }
          var docs = snapshot.data!.docs;
          return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                bool isSeniorAndActive =
                    docs[index]['experience'] >= 5 && docs[index]['active'];
                return Container(
                  color: isSeniorAndActive ? Colors.lightGreen.shade100 : null,
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: Text(docs[index]['name']),
                    subtitle: Text(
                        '${docs[index]['experience']} years of experience - ${docs[index]['active'] ? 'Active' : 'Inactive'}'),
                    trailing: isSeniorAndActive
                        ? const Icon(Icons.flag, color: Colors.green)
                        : null,
                    // Color: isSeniorAndActive ? Colors.green.shade100 : null,
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeForm(
            context), // Call a function to display the form
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddEmployeeForm(BuildContext context) {
  // State to manage the form fields
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isActive = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (context, setState) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, 
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: 'Experience in Years'),
              ),
              CheckboxListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (newValue) =>
                    setState(() => _isActive = newValue ?? true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addEmployeeToFirestore(_nameController.text,
                    int.tryParse(_experienceController.text) ?? 0, _isActive);
                Navigator.of(context).pop(); 
              },
              child: const Text('Add'),
            ),
          ],
        );
      });
    },
  );
}

void _addEmployeeToFirestore(String name, int experience, bool active) {
  FirebaseFirestore.instance
      .collection('users')
      .add({'name': name, 'experience': experience, 'active': active});
}

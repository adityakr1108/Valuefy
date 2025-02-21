import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskHistoryScreen extends StatefulWidget {
  @override
  _TaskHistoryScreenState createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  List<Map<String, dynamic>> _taskHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTaskHistory();
  }

  Future<void> _loadTaskHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('taskHistory') ?? [];
    setState(() {
      _taskHistory = history.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _deleteTask(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('taskHistory') ?? [];

    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await prefs.setStringList('taskHistory', history);
      setState(() {
        _taskHistory.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task History"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _taskHistory.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("No task history available.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _taskHistory.length,
        itemBuilder: (context, index) {
          final task = _taskHistory[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(Icons.event_note, color: Colors.blueAccent),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Meeting Agenda", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  Icon(Icons.calendar_today, color: Colors.blueGrey, size: 20),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("${task["Meeting_Agenda"]}", style: TextStyle(color: Colors.black54)),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.blueGrey, size: 20),
                      SizedBox(width: 5),
                      Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Text("${task["Summary"]}", style: TextStyle(color: Colors.black54)),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blueGrey, size: 20),
                      SizedBox(width: 5),
                      Text("Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Text("${task["Date"]}", style: TextStyle(color: Colors.black54)),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteTask(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

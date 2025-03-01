import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(FlutterTest());
}

class FlutterTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _activityName = "Press 'Next' to get a random activity";
  String _price = "";
  final List<Map<String,String>> _activityHistory=[];

  Future<void> _fetchActivity()async {
    final url = Uri.parse('https://bored.api.lewagon.com/api/activity');
    try {
      final response =await http.get(url);
      if(response.statusCode==200){
        final data = json.decode(response.body);
        final activity = data['activity'] ?? "No activity found.";
        final price = data['price'] != null ? "Price \$${data['price']}" : "Price :Free";
 
        setState(() {
          _activityName = activity;
          _price = "Price:$price";
          _activityHistory.add({"activity":activity});

          if (_activityHistory.length > 50){
            _activityHistory.removeAt(0);
          }
        });
      }else{
        setState(() {
          _activityName="Failed to load activity";
          _price="";
        });
      }
    }catch (e){
        setState(() {
          _activityName="An error occured";
          _price="";
        });
    }
  }

  void _navigateToHistory(){
    Navigator.push(
      context, 
      MaterialPageRoute(builder:(context)=>HistoryScreen(activityHistory: _activityHistory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Random'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _activityName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 10),
            Text(
              _price,
              style: TextStyle(fontSize: 18.0,color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchActivity, child: Text('Next')),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: _navigateToHistory, child: Text('History'))
          ],
        ),
      ),
    );
  }
}
class HistoryScreen extends StatelessWidget {
  final List<Map<String,String>> activityHistory;
  HistoryScreen({required this.activityHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History'),
      ),
      body: ListView.builder(
        itemCount: activityHistory.length,
        itemBuilder: (context, index){
          final activity = activityHistory[index];
          return ListTile(
            title: Text(activity['activity']??''),
            subtitle: Text('Price: ${activity['price']}'),
          );
        },
      ),
    );
  }
}

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
  String? _selectedType;
  final List<String> _activityTypes=[
    'education',
    'recreational',
    'social',
    'diy',
    'charity',
    'relaxation',
    'music',
    'busywork',
  ];

  Future<void> _fetchActivity()async {
    final baseUrl = 'https://bored.api.lewagon.com/api/activity';
    final url = _selectedType !=null
      ? Uri.parse('$baseUrl?types=$_selectedType')
      : Uri.parse(baseUrl);
    try {
      final response =await http.get(url);
      if(response.statusCode==200){
        final data = json.decode(response.body);
        if (data.isNotEmpty){
          final activity = data['activity'] ?? "No activity found.";
          final price = data['price'] != null ? "Price \$${data['price']}" : "Price :Free";
  
          setState(() {
            _activityName = activity;
            _price = "Price:$price";
            _activityHistory.add({
              "activity":activity,
              "price":price,
              "type": _selectedType ?? "random",
            });

            if (_activityHistory.length > 50){//keep only 50
              _activityHistory.removeAt(0);
            }
          });
        }else{
          setState(() {
            _activityName="No activity found for the selected type";
            _price="";
          });
        }
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
      MaterialPageRoute(builder:(context)=>HistoryScreen(
        activityHistory: _activityHistory,
        highlightedType: _selectedType
        ),
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
            DropdownButton<String>(
              value: _selectedType,
              hint: Text('Select a type (optional)'),
              isExpanded: true,
              items: _activityTypes.map((type){
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                  );
              }).toList(),
              onChanged: (value){
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            SizedBox(height: 20),
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
  final String? highlightedType;
  HistoryScreen({required this.activityHistory, this.highlightedType});

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
          final isHighlighted = 
                highlightedType != null && activity['type'] == highlightedType;
          return ListTile(
            title: Text(
              activity['activity']??'',
              style: TextStyle(
                color: isHighlighted?Colors.blue : Colors.black,
                fontWeight: isHighlighted ? FontWeight.bold :FontWeight.normal,
              ),
            ),
            subtitle: Text('Price: ${activity['price']}'),
          );
        },
      ),
    );
  }
}

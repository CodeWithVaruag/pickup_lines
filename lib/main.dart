import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pickup_lines.dart'; // Ensure this is correctly pointing to your pickup_lines.dart

void main() {
  runApp(PickupLineApp());
}

class PickupLineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Line App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CategorySelectionPage(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

class CategorySelectionPage extends StatelessWidget {
  final List<String> categories = [
    'funny',
    'romantic',
    'nerdy',
    'flirty',
    'cheesy',
    'savage',
    'cute',
  ];

  final Map<String, Color> categoryColors = {
    'funny': Colors.orangeAccent,
    'romantic': Colors.pinkAccent,
    'nerdy': Colors.greenAccent,
    'flirty': Colors.blueAccent,
    'cheesy': Colors.yellowAccent,
    'savage': Colors.redAccent,
    'cute': Colors.purpleAccent,
  };

  final Map<String, String> categoryEmojis = {
    'funny': '😂',
    'romantic': '❤️',
    'nerdy': '💻',
    'flirty': '😉',
    'cheesy': '🧀',
    'savage': '💀',
    'cute': '🐾',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // Adjusted for more height
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Card(
              color: categoryColors[categories[index]],
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupLineCategoryPage(
                        category: categories[index],
                        color: categoryColors[categories[index]]!,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      categoryEmojis[categories[index]]!,
                      style: TextStyle(fontSize: 60), // Adjust size as needed
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        categories[index].toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PickupLineCategoryPage extends StatefulWidget {
  final String category;
  final Color color;

  PickupLineCategoryPage({required this.category, required this.color});

  @override
  _PickupLineCategoryPageState createState() => _PickupLineCategoryPageState();
}

class _PickupLineCategoryPageState extends State<PickupLineCategoryPage> {
  List<String> _pickupLines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPickupLines();
  }

  Future<void> _fetchPickupLines() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _pickupLines = pickupLinesByCategory[widget.category] ?? [];
      _isLoading = false;
    });
  }

  void _copyToClipboard(String line) {
    Clipboard.setData(ClipboardData(text: line));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  Future<void> _saveFavoriteLine(String line) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_line', line);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: widget.color, // Set the background color for the lines list
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _pickupLines.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 4.0,
                    child: ListTile(
                      title: Text(
                        _pickupLines[index],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(Icons.more_vert),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.copy),
                                  title: Text('Copy to Clipboard'),
                                  onTap: () {
                                    _copyToClipboard(_pickupLines[index]);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.favorite),
                                  title: Text('Save to Favorites'),
                                  onTap: () {
                                    _saveFavoriteLine(_pickupLines[index]);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

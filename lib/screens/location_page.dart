// screens/location_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/location.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<Location> locations = [];
  List<Location> filteredLocations = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _searchController.addListener(_filterLocations);
  }

  void _showCreatedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 43, 90, 44),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  void _showUpdatedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 164, 192, 53),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  void _showDeletedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.amberAccent[700],
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  void _showFailedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 232, 27, 13),
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  // Fetch all Locations (Read)
  Future<void> fetchLocations() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/location'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        locations =
            jsonResponse.map((data) => Location.fromJson(data)).toList();
        filteredLocations = locations;
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Filter Madrassas based on the search query
  void _filterLocations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredLocations = locations.where((location) {
        return location.name.toLowerCase().contains(query) ||
            location.areaCode
                .toLowerCase()
                .contains(query); 
      }).toList();
    });
  }

  // Create a new Location (Create)
  Future<void> createLocation(String name, String areaCode) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/location'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "area_code": areaCode}),
    );
    if (response.statusCode == 200) {
      fetchLocations();
      _showCreatedSnackbar('Location created successfully');
    } else {
      _showFailedSnackbar('Failed to create location');
    }
  }

  // Update an existing Location (Update)
  Future<void> updateLocation(int id, String name, String areaCode) async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/location/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "area_code": areaCode}),
    );
    if (response.statusCode == 200) {
      fetchLocations();
      _showUpdatedSnackbar("Location Update Successful");
    } else {
      _showFailedSnackbar("Failed to Update Location");
    }
  }

  // Delete a Location (Delete)
  Future<void> deleteLocation(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:8000/api/location/$id'));
    if (response.statusCode == 200) {
      fetchLocations();
      _showDeletedSnackbar("Location Deleted Successfully!");
    } else {
      _showFailedSnackbar("Failed to Delete Location");
    }
  }

  // Show dialog for creating a new Location
  void showCreateDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Area Name'),
            ),
            TextField(
              controller: _areaCodeController,
              decoration: InputDecoration(labelText: 'Area Code'),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              createLocation(_nameController.text, _areaCodeController.text);
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  // Show dialog for updating an existing Location
  void showUpdateDialog(Location location) {
    _nameController.text = location.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Area Name'),
            ),
            TextField(
              controller: _areaCodeController,
              decoration: InputDecoration(labelText: 'Area Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateLocation(
                  location.id, _nameController.text, _areaCodeController.text);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Locations List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(location.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showUpdateDialog(location),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteLocation(location.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

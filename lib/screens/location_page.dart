// screens/madrassa_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../models/madrassa.dart';
import '../models/location.dart';

class MadrassaPage extends StatefulWidget {
  @override
  _MadrassaPageState createState() => _MadrassaPageState();
}

class _MadrassaPageState extends State<MadrassaPage> {
  List<Madrassa> madrassas = [];
  List<Location> locations = [];
  List<Madrassa> filteredMadrassas = []; // Filtered list of Madrassas
  Location? selectedLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    fetchMadrassas();
    fetchLocations();
    _searchController.addListener(_filterMadrassas); // Listen for changes in search input
  }

  // Fetch all Madrassas (Read)
  Future<void> fetchMadrassas() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/madrassa'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        madrassas = jsonResponse.map((data) => Madrassa.fromJson(data)).toList();
        filteredMadrassas = madrassas; // Initialize filtered list
      });
    } else {
      throw Exception('Failed to load madrassas');
    }
  }

  // Fetch all Locations (for the dropdown)
  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/location'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        locations = jsonResponse.map((data) => Location.fromJson(data)).toList();
        if (locations.isNotEmpty) selectedLocation = locations[0];
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Filter Madrassas based on the search query
  void _filterMadrassas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredMadrassas = madrassas.where((madrassa) {
        return madrassa.name.toLowerCase().contains(query) || 
               madrassa.locationName.toLowerCase().contains(query); // Add location name filtering if applicable
      }).toList();
    });
  }

  // Create a new Madrassa (Create)
  Future<void> createMadrassa(String name, int locationId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/madrassa'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "location_id": locationId}),
    );
    if (response.statusCode == 200) {
      fetchMadrassas();
    }
  }

  // Update an existing Madrassa (Update)
  Future<void> updateMadrassa(int id, String name, int locationId) async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/api/madrassa/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "location_id": locationId}),
    );
    if (response.statusCode == 200) {
      fetchMadrassas();
    }
  }

  // Delete a Madrassa (Delete)
  Future<void> deleteMadrassa(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:8000/api/madrassa/$id'));
    if (response.statusCode == 200) {
      fetchMadrassas();
    }
  }

  // Show dialog for creating a new Madrassa
  void showCreateDialog() {
    _nameController.clear();
    selectedLocation = locations.isNotEmpty ? locations[0] : null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Madrassa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            DropdownSearch<Location>(
              items: locations,
              itemAsString: (Location location) => location.name,
              selectedItem: selectedLocation,
              onChanged: (Location? newLocation) {
                setState(() {
                  selectedLocation = newLocation;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Location",
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedLocation != null) {
                createMadrassa(_nameController.text, selectedLocation!.id);
              }
              Navigator.of(context).pop();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  // Show dialog for updating an existing Madrassa
  void showUpdateDialog(Madrassa madrassa) {
    _nameController.text = madrassa.name;
    selectedLocation = locations.firstWhere((location) => location.id == madrassa.locationId, orElse: () => locations[0]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Madrassa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            DropdownSearch<Location>(
              items: locations,
              itemAsString: (Location location) => location.name,
              selectedItem: selectedLocation,
              onChanged: (Location? newLocation) {
                setState(() {
                  selectedLocation = newLocation;
                });
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Location",
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedLocation != null) {
                updateMadrassa(madrassa.id, _nameController.text, selectedLocation!.id);
              }
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
      appBar: AppBar(title: Text('Madrassas List')),
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
              itemCount: filteredMadrassas.length,
              itemBuilder: (context, index) {
                final madrassa = filteredMadrassas[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(madrassa.name),
                    subtitle: Text('Location ID: ${madrassa.locationName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showUpdateDialog(madrassa),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteMadrassa(madrassa.id),
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

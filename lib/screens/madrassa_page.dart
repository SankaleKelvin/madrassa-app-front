
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/madrassa.dart';
import '../models/location.dart';
import '../services/auth_service.dart';

class MadrassaPage extends StatefulWidget {
  @override
  _MadrassaPageState createState() => _MadrassaPageState();
}

class _MadrassaPageState extends State<MadrassaPage> {
  List<Madrassa> madrassas = [];
  List<Location> locations = [];
  List<Madrassa> filteredMadrassas = [];
  Location? selectedLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMadrassas();
    fetchLocations();
    _searchController.addListener(_filterMadrassas);
  }

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.only(top: 40, left: 16, right: 16),
    ));
  }

  void _filterMadrassas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredMadrassas = madrassas.where((madrassa) {
        return madrassa.name.toLowerCase().contains(query) ||
            madrassa.locationName.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Fetch all Madrassas (Read)
  Future<void> fetchMadrassas() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/madrassa'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          madrassas = jsonResponse.map((data) => Madrassa.fromJson(data)).toList();
          filteredMadrassas = madrassas;
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to load madrassas', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fetch all Locations
  Future<void> fetchLocations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/location'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          locations = jsonResponse.map((data) => Location.fromJson(data)).toList();
          if (locations.isNotEmpty) selectedLocation = locations[0];
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to load locations', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Create a new Madrassa (Create)
  Future<void> createMadrassa(String name, int locationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/madrassa'),
        headers: headers,
        body: jsonEncode({"name": name, "location_id": locationId}),
      );

      if (response.statusCode == 200) {
        fetchMadrassas();
        _showSnackbar('Madrassa created successfully', const Color.fromARGB(255, 43, 90, 44));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to create madrassa', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Update an existing Madrassa (Update)
  Future<void> updateMadrassa(int id, String name, int locationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/madrassa/$id'),
        headers: headers,
        body: jsonEncode({"name": name, "location_id": locationId}),
      );

      if (response.statusCode == 200) {
        fetchMadrassas();
        _showSnackbar('Madrassa updated successfully', const Color.fromARGB(255, 164, 192, 53));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to update madrassa', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Delete a Madrassa (Delete)
  Future<void> deleteMadrassa(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/madrassa/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchMadrassas();
        _showSnackbar('Madrassa deleted successfully', Colors.amberAccent[700]!);
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to delete madrassa', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

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
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
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

  void showUpdateDialog(Madrassa madrassa) {
    _nameController.text = madrassa.name;
    selectedLocation = locations.firstWhere(
      (location) => location.id == madrassa.locationId,
      orElse: () => locations[0],
    );
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredMadrassas.length,
                    itemBuilder: (context, index) {
                      final madrassa = filteredMadrassas[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(madrassa.name),
                          subtitle: Text('Location: ${madrassa.locationName}'),
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
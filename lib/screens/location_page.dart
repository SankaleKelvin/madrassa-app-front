import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location.dart';
import '../services/auth_service.dart';

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
  bool _isLoading = false;
  bool _hasEditPermission = false;

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _checkPermissions();
    _searchController.addListener(_filterLocations);
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await AuthService.hasAnyRole(['Admin', 'Teacher']);
    setState(() {
      _hasEditPermission = hasPermission;
    });
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

  // Fetch all Locations (Read)
  Future<void> fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/location'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          locations =
              jsonResponse.map((data) => Location.fromJson(data)).toList();
          filteredLocations = locations;
        });
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
        // Handle unauthorized access - potentially redirect to login
      } else {
        _showSnackbar('Failed to load locations', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterLocations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredLocations = locations.where((location) {
        return location.name.toLowerCase().contains(query) ||
            location.areaCode.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Create a new Location (Create)
  Future<void> createLocation(String name, String areaCode) async {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to create locations', Colors.red);
      return;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/location'),
        headers: headers,
        body: jsonEncode({"name": name, "areaCode": areaCode}),
      );

      if (response.statusCode == 200) {
        fetchLocations();
        _showSnackbar('Location created successfully',
            const Color.fromARGB(255, 43, 90, 44));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to create location', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Update an existing Location (Update)
  Future<void> updateLocation(int id, String name, String areaCode) async {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to update locations', Colors.red);
      return;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('http://localhost:8000/api/location/$id'),
        headers: headers,
        body: jsonEncode({"name": name, "areaCode": areaCode}),
      );

      if (response.statusCode == 200) {
        fetchLocations();
        _showSnackbar('Location updated successfully',
            const Color.fromARGB(255, 164, 192, 53));
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to update location', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  // Delete a Location (Delete)
  Future<void> deleteLocation(int id) async {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to delete locations', Colors.red);
      return;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('http://localhost:8000/api/location/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchLocations();
        _showSnackbar(
            'Location deleted successfully', Colors.amberAccent[700]!);
      } else if (response.statusCode == 401) {
        _showSnackbar('Session expired. Please login again.', Colors.red);
      } else {
        _showSnackbar('Failed to delete location', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Network error occurred', Colors.red);
    }
  }

  void showCreateDialog() {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to create locations', Colors.red);
      return;
    }

    _nameController.clear();
    _areaCodeController.clear();
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
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

  void showUpdateDialog(Location location) {
    if (!_hasEditPermission) {
      _showSnackbar(
          'You do not have permission to update locations', Colors.red);
      return;
    }

    _nameController.text = location.name;
    _areaCodeController.text = location.areaCode;
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
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(location.name),
                          subtitle: Text('Code: ${location.areaCode}'),
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

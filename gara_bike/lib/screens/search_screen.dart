
// Screen for searching parking zones in the Gara Bike app.
// Provides a search bar with debounced API search and displays results as a list.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gara_bike/api/api_service.dart'; // Directly use ApiService for simplicity
import 'package:gara_bike/models/parking_zone_model.dart';
import 'package:gara_bike/widgets/search_result_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controller for the search input field
  final _searchController = TextEditingController();
  // Service for API calls
  final ApiService _apiService = ApiService();
  // Timer for debouncing search input
  Timer? _debounce;

  // List of search results
  List<ParkingZone> _results = [];
  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the search field
    _searchController.addListener(_onSearchChanged);
  }

  // Debounced search handler
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchParkingZones(_searchController.text);
    });
  }

  // Calls the API to search for parking zones
  Future<void> _searchParkingZones(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await _apiService.searchParkingZones(query);
      setState(() => _results = results);
    } catch (e) {
      print("Search failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Search bar in the app bar
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Search for a parking zone...'),
        ),
      ),
      body: _isLoading
          // Show loading indicator while searching
          ? const Center(child: CircularProgressIndicator())
          // Show search results as a list
          : ListView.builder(
        itemCount: _results.length,
        itemBuilder: (ctx, index) {
          return SearchResultTile(zone: _results[index]);
        },
      ),
    );
  }
}

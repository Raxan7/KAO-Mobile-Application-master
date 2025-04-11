import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for storing/retrieving user credentials
import '../../widgets/persistent_drawer.dart'; // Import the Persistent Drawer

class SearchPage extends StatefulWidget {
  final bool isDarkMode; // Add a field for the current theme state
  final Function(bool) onThemeChanged; // Add a field for the theme change callback

  const SearchPage({super.key, required this.isDarkMode, required this.onThemeChanged}); // Constructor to accept parameters

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? userId;
  String? userName; // Change to nullable
  String? userEmail; // Change to nullable
  bool isLoggedIn = false; // Track user login state

  // Variables for search and filter inputs
  String searchQuery = '';
  String? selectedLocation;
  RangeValues priceRange = const RangeValues(0, 1000000);
  String? selectedPropertyType;
  int? bedrooms;
  int? bathrooms;
  bool newlyListed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page initializes
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userName = prefs.getString('name'); // Load user name, may be null
      userEmail = prefs.getString('email'); // Load user email, may be null
      isLoggedIn = userName != null; // Set login state based on user name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PersistentDrawer(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        onThemeChanged: widget.onThemeChanged,
        isLoggedIn: isLoggedIn, // Pass the login state
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Theme.of(context).scaffoldBackgroundColor, // Set the background color for the search page
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              _buildSearchBar(),

              const SizedBox(height: 16.0),

              // Advanced Search Filters
              const Text(
                'Advanced Search Filters',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              // Location Dropdown
              _buildLocationDropdown(),
              const SizedBox(height: 8.0),

              // Price Range Slider
              _buildPriceRangeSlider(),
              const SizedBox(height: 8.0),

              // Property Type Dropdown
              _buildPropertyTypeDropdown(),
              const SizedBox(height: 8.0),

              // Bedrooms and Bathrooms Inputs
              _buildBedroomsAndBathroomsInputs(),
              const SizedBox(height: 8.0),

              // Newly Listed Checkbox
              _buildNewlyListedCheckbox(),
              const SizedBox(height: 16.0),

              // Apply Filters Button
              _buildApplyFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value; // Update search query
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Search Properties',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      hint: const Text('Select Location'),
      value: selectedLocation,
      onChanged: (value) {
        setState(() {
          selectedLocation = value;
        });
      },
      items: <String>['Location 1', 'Location 2', 'Location 3'] // Example locations
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    return RangeSlider(
      values: priceRange,
      min: 0,
      max: 1000000,
      divisions: 100,
      labels: RangeLabels(
        'Tsh ${priceRange.start.round()}',
        'Tsh ${priceRange.end.round()}',
      ),
      onChanged: (RangeValues values) {
        setState(() {
          priceRange = values;
        });
      },
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      hint: const Text('Select Property Type'),
      value: selectedPropertyType,
      onChanged: (value) {
        setState(() {
          selectedPropertyType = value;
        });
      },
      items: <String>['House', 'Apartment', 'Condo', 'Villa'] // Example property types
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildBedroomsAndBathroomsInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Bedrooms',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                bedrooms = int.tryParse(value);
              });
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Bathrooms',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                bathrooms = int.tryParse(value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewlyListedCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: newlyListed,
          onChanged: (value) {
            setState(() {
              newlyListed = value!;
            });
          },
        ),
        const Text('Show Newly Listed'),
      ],
    );
  }

  Widget _buildApplyFiltersButton() {
    return ElevatedButton(
      onPressed: () {
        // Add logic to apply filters and perform search
        // You can use the searchQuery and other filter variables
        // print('Search Query: $searchQuery');
        // print('Location: $selectedLocation');
        // print('Price Range: ${priceRange.start} - ${priceRange.end}');
        // print('Property Type: $selectedPropertyType');
        // print('Bedrooms: $bedrooms');
        // print('Bathrooms: $bathrooms');
        // print('Newly Listed: $newlyListed');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: const Text('Apply Filters'),
    );
  }
}

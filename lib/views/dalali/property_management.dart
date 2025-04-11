import 'package:flutter/material.dart';
import '../../widgets/dalali/dalali_navigation_drawer.dart';

class PropertyManagementPage extends StatefulWidget {
  const PropertyManagementPage({super.key});

  @override
  _PropertyManagementPageState createState() => _PropertyManagementPageState();
}

class _PropertyManagementPageState extends State<PropertyManagementPage> {
  bool isDarkMode = false; // Add a variable to track dark mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Management'),
      ),
      drawer: DalaliNavigationDrawer(
        onThemeChanged: (newIsDarkMode) {
          setState(() {
            isDarkMode = newIsDarkMode;
          });
        },
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Listing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildListingForm(),
            const SizedBox(height: 20),
            const Text(
              'Current Listings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCurrentListings(),
          ],
        ),
      ),
    );
  }

  Widget _buildListingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Property Title'),
        ),
        const SizedBox(height: 10),
        // const TextField(
        //   decoration: InputDecoration(labelText: 'Size (sqft)'),
        // ),
        // const SizedBox(height: 10),
        // const TextField(
        //   decoration: InputDecoration(labelText: 'Number of Rooms'),
        // ),
        // const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(labelText: 'Amenities'),
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(labelText: 'Price'),
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(labelText: 'Location'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField(
          decoration: const InputDecoration(labelText: 'Availability Status'),
          items: const [
            DropdownMenuItem(value: 'For Sale', child: Text('For Sale')),
            DropdownMenuItem(value: 'For Rent', child: Text('For Rent')),
            DropdownMenuItem(value: 'Under Contract', child: Text('Under Contract')),
            DropdownMenuItem(value: 'Sold', child: Text('Sold')),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle property submission
          },
          child: const Text('Submit Listing'),
        ),
      ],
    );
  }

  Widget _buildCurrentListings() {
    final listings = [
      {
        'title': 'Luxury Villa',
        'size': '3000 sqft',
        'rooms': '4',
        'amenities': 'Pool, Gym',
        'price': 'Tsh 1,500,000',
        'location': 'Dar es Salaam',
        'status': 'For Sale',
      },
      {
        'title': 'Cozy Apartment',
        'size': '1200 sqft',
        'rooms': '2',
        'amenities': 'WiFi, Parking',
        'price': 'Tsh 800,000',
        'location': 'Dodoma',
        'status': 'For Rent',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(listing['title']!),
            subtitle: Text(
              '${listing['size']} | ${listing['rooms']} Rooms | ${listing['amenities']}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(listing['price']!),
                Text(listing['status']!),
              ],
            ),
            onTap: () {
              // Handle navigation to edit or view more details about the property
            },
          ),
        );
      },
    );
  }
}

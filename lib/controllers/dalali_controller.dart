
class DalaliController {
  // Dummy data for listings
  List<Map<String, dynamic>> listings = [
    {'id': 1, 'status': 'For Sale', 'name': '2 Bedroom Apartment'},
    {'id': 2, 'status': 'For Rent', 'name': 'Luxury Villa'},
    {'id': 3, 'status': 'Under Contract', 'name': 'Modern Office Space'}
  ];

  // Dummy method to add new listing
  void addListing(String name, String status) {
    listings.add({'id': listings.length + 1, 'name': name, 'status': status});
  }

  // Dummy method to edit listing
  void editListing(int id, String name, String status) {
    final index = listings.indexWhere((listing) => listing['id'] == id);
    if (index != -1) {
      listings[index]['name'] = name;
      listings[index]['status'] = status;
    }
  }

  // Dummy method to fetch listings
  List<Map<String, dynamic>> getListings() {
    return listings;
  }
}

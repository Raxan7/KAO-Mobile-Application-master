import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kao_app/models/hostel.dart';
import 'package:kao_app/models/lodge.dart';
import 'package:kao_app/services/real_time_update_service.dart';
import '../../../models/hotel.dart';
import '../../../models/motel.dart';
import '../../../models/user_property.dart';
import '../../../services/api_service.dart';
import '../../../widgets/cards/simple_hotel_card.dart';

class AccomodationSidewaySlider extends StatefulWidget {
  const AccomodationSidewaySlider({super.key});

  @override
  State<AccomodationSidewaySlider> createState() => _AccomodationSidewaySliderState();
}

class _AccomodationSidewaySliderState extends State<AccomodationSidewaySlider> {
  final RealTimeUpdateService _realTimeUpdateService = RealTimeUpdateService();

  late PageController _hotelPageController;
  late PageController _motelPageController;
  late PageController _lodgePageController;
  late PageController _restaurantPageController;
  late PageController _hostelPageController;
  late PageController _propertyPageController;

  List<Hotel> hotels = [];
  List<Motel> motels = [];
  List<Lodge> lodges = [];
  List<Hostel> hostels = [];
  List<UserProperty> properties = [];

  int _currentHotelPageIndex = 0;
  int _currentMotelPageIndex = 0;
  int _currentLodgePageIndex = 0;
  int _currentRestaurantPageIndex = 0;
  int _currentHostelPageIndex = 0;
  int _currentPropertyPageIndex = 0;

  Timer? _hotelSlideTimer;
  Timer? _motelSlideTimer;
  Timer? _lodgeSlideTimer;
  Timer? _restaurantSlideTimer;
  Timer? _hostelSlideTimer;
  Timer? _propertySlideTimer;

  @override
  void initState() {
    super.initState();
    _realTimeUpdateService.onDataUpdated = (newHotels, newMotels, newLodges, newHostels, newProperties) {
      setState(() {
        hotels = newHotels;
        motels = newMotels;
        lodges = newLodges;
        hostels = newHostels;
        properties = newProperties;
      });
    };

    // Initialize data fetching
    _fetchData();

    // fetchAccomodations(); // Fetch hotels when the page initializes

    // Initialize PageControllers for each category
    _hotelPageController = PageController(initialPage: _currentHotelPageIndex);
    _motelPageController = PageController(initialPage: _currentMotelPageIndex);
    _lodgePageController = PageController(initialPage: _currentLodgePageIndex);
    _restaurantPageController = PageController(initialPage: _currentRestaurantPageIndex);
    _hostelPageController = PageController(initialPage: _currentHostelPageIndex);
    _propertyPageController = PageController(initialPage: _currentPropertyPageIndex);

    // Start auto-slide for each category with different intervals
    _startAutoSlide(_hotelPageController, 3000, (index) => _currentHotelPageIndex = index);
    _startAutoSlide(_motelPageController, 5000, (index) => _currentMotelPageIndex = index);
    _startAutoSlide(_lodgePageController, 4000, (index) => _currentLodgePageIndex = index);
    _startAutoSlide(_restaurantPageController, 4500, (index) => _currentRestaurantPageIndex = index);
    _startAutoSlide(_hostelPageController, 3500, (index) => _currentHostelPageIndex = index);
    _startAutoSlide(_propertyPageController, 5500, (index) => _currentPropertyPageIndex = index);
  }

  void _fetchData() {
    _realTimeUpdateService.fetchAccommodations();
  }

  @override
  void dispose() {
    // Cancel all timers and dispose all controllers
    _hotelSlideTimer?.cancel();
    _motelSlideTimer?.cancel();
    _lodgeSlideTimer?.cancel();
    _restaurantSlideTimer?.cancel();
    _hostelSlideTimer?.cancel();
    _propertySlideTimer?.cancel();

    _hotelPageController.dispose();
    _motelPageController.dispose();
    _lodgePageController.dispose();
    _restaurantPageController.dispose();
    _hostelPageController.dispose();
    _propertyPageController.dispose();
    super.dispose();
  }

  void fetchAccomodations() async {
    try {
      ApiService apiService = ApiService(); // Initialize your ApiService
      List<Hotel> fetchedHotels = await apiService.fetchHotels();
      List<Motel> fetchedMotels = await apiService.fetchMotels();
      List<Lodge> fetchedLodges = await apiService.fetchLodges();
      List<Hostel> fetchedHostels = await apiService.fetchHostels();
      List<UserProperty> fetchedProperties = await apiService.fetchPropertiesForUser();

      setState(() {
        hotels = fetchedHotels; // Update the hotels list
        motels = fetchedMotels;
        lodges = fetchedLodges;
        hostels = fetchedHostels;
        properties = fetchedProperties;
      });

    } catch (error) {
      // print('Failed to fetch hotels: $error');
    }
  }

  void _startAutoSlide(PageController controller, int interval, Function(int) updateIndex) {
    Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (controller.hasClients) {
        int nextPage = controller.page!.toInt() + 1;
        if (nextPage >= hotels.length) {
          nextPage = 0;
        }
        controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
        updateIndex(nextPage); // Update the corresponding page index
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // _buildCategorySlider('Hotels', _buildHotelItems(), _hotelPageController),
                // _buildCategorySlider('Motels', _buildMotelItems(), _motelPageController),
                // _buildCategorySlider('Lodges', _buildLodgeItems(), _lodgePageController),
                _buildCategorySlider('Properties', _buildPropertyItems(), _propertyPageController),
                // _buildCategorySlider('Hostels', _buildHostelItems(), _hostelPageController),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySlider(String title, List<Widget> items, PageController pageController) {
    // CHeck if the item is empty
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    double screenWidth = (MediaQuery.of(context).size.width);
    double divConstant = 1.451851852;
    double calculatedHeight = screenWidth / divConstant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: calculatedHeight,
          child: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children: items,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHotelItems() {
    return hotels.map((hotel) => SimpleHotelCard(hotel: hotel)).toList();
  }

  List<Widget> _buildMotelItems() {
    return motels.map((motel) => SimpleMotelCard(motel: motel)).toList();
  }

  List<Widget> _buildLodgeItems() {
    return lodges.map((lodge) => SimpleLodgeCard(lodge: lodge)).toList();
  }

  List<Widget> _buildPropertyItems() {
    // return properties.map((property) => SimplePropertyCard(property: property, propertyMedia: PropertyMedia())).toList();
    return [];
  }

  List<Widget> _buildRestaurantItems() {
    return List.generate(5, (index) {
      return _buildItemCard('Restaurant ${index + 1}', 'Restaurant Description', Colors.orange);
    });
  }

  List<Widget> _buildHostelItems() {
    return hostels.map((hostel) => SimpleHostelCard(hostel: hostel)).toList();
  }

  Widget _buildItemCard(String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

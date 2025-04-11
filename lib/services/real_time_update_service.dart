import 'dart:async';

import '../models/user_property.dart';
import 'api_service.dart'; 
import '../models/hotel.dart';
import '../models/motel.dart';
import '../models/lodge.dart';
import '../models/hostel.dart';

class RealTimeUpdateService {
  final ApiService _apiService = ApiService();

  // Callback to notify the app when new data is available
  Function(List<Hotel> hotels, List<Motel> motels, List<Lodge> lodges, List<Hostel> hostels, List<UserProperty>)? onDataUpdated;

  // Polling interval (e.g., every 30 seconds)
  int pollingInterval = 30000; 

  // Reference to the Timer
  Timer? _pollingTimer;

  // Start polling for real-time updates
  void startPolling() {
    _pollingTimer = Timer.periodic(Duration(milliseconds: pollingInterval), (timer) async {
      await fetchAccommodations();
    });
  }

  // Stop the polling
  void stopPolling() {
    _pollingTimer?.cancel();
  }

  // Fetch accommodations from the API using ApiService methods
  Future<void> fetchAccommodations() async {
    try {
      List<Hotel> hotels = await _apiService.fetchHotels();
      List<Motel> motels = await _apiService.fetchMotels();
      List<Lodge> lodges = await _apiService.fetchLodges();
      List<Hostel> hostels = await _apiService.fetchHostels();
      List<UserProperty> properties = await _apiService.fetchPropertiesForUser();

      // Notify listeners if there is new data
      if (onDataUpdated != null) {
        onDataUpdated!(hotels, motels, lodges, hostels, properties);
      }
    } catch (error) {
      // print('Failed to fetch accommodations: $error');
    }
  }
}

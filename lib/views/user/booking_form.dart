import 'package:flutter/material.dart';
import '../../models/room.dart'; // Import the Room model
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting the date

class BookingFormPage extends StatefulWidget {
  final Room room; // Room details passed to this page

  const BookingFormPage({super.key, required this.room});

  @override
  _BookingFormPageState createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final ApiService apiService = ApiService();
  DateTime? checkInDate;
  DateTime? checkOutDate;
  bool isLoading = false;

  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController(); // For showing the check-in date
  final TextEditingController _checkOutController = TextEditingController(); // For showing the check-out date

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user details when the page initializes
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _phoneController.text = prefs.getString('phonenum') ?? '';  // Assuming 'phone' key for the phone number
      _addressController.text = prefs.getString('address') ?? ''; // Assuming 'address' key for the address
    });
  }

  Future<void> _bookRoom() async {
    if (checkInDate != null && checkOutDate != null) {
      setState(() => isLoading = true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      // Prepare booking details
      final result = await apiService.bookRoom(
        widget.room.id.toString(),  // roomId
        checkInDate!.toIso8601String(),  // checkIn
        checkOutDate!.toIso8601String(),  // checkOut
        userId!,  // userId
        _nameController.text,  // userName
        _phoneController.text,  // phoneNum
        _addressController.text,  // address
        widget.room.name,  // roomName 
        widget.room.price.toString(),  // roomPrice 
      );

      if (result['status'] == 'success') {
        // Notify success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Successful!')));
      } else {
        // Notify failure
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking Failed: ${result['message']}')));
      }
      setState(() => isLoading = false);
    } else {
      // Notify that dates are not selected
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both check-in and check-out dates!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.room.name}'), // Change to use room's name
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Prefilled fields for name, phone, and address
            TextField(
              controller: _nameController, // Controller for the user's name
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _phoneController, // Controller for the user's phone
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _addressController, // Controller for the user's address
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            
            // Check-in date field
            TextField(
              controller: _checkInController, // Attach controller for check-in date
              decoration: const InputDecoration(labelText: 'Check-in Date'),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null) {
                  setState(() {
                    checkInDate = pickedDate;
                    _checkInController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Display selected date
                  });
                }
              },
            ),
            
            // Check-out date field
            TextField(
              controller: _checkOutController, // Attach controller for check-out date
              decoration: const InputDecoration(labelText: 'Check-out Date'),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null) {
                  setState(() {
                    checkOutDate = pickedDate;
                    _checkOutController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Display selected date
                  });
                }
              },
            ),
            
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _bookRoom,
                    child: const Text('Book Now'),
                  ),
          ],
        ),
      ),
    );
  }
}

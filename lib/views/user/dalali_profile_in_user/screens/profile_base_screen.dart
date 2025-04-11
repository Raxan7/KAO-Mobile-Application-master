import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kao_app/models/user_property.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:kao_app/utils/constants.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/gallery_screen.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/igtv_screen.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/reels_screen.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/widgets/profile_header_widget.dart';

class ProfileBaseScreen extends StatefulWidget {
  final String userId;

  const ProfileBaseScreen({super.key, required this.userId});

  @override
  _ProfileBaseScreenState createState() => _ProfileBaseScreenState();
}

class _ProfileBaseScreenState extends State<ProfileBaseScreen> {
  late String username;
  late String profilePicUrl;
  int rentCount = 0;
  int saleCount = 0;
  int forRent = 0;
  int forSale = 0;
  int totalProperties = 0;

  @override
  void initState() {
    super.initState();
    username = "Loading...";
    profilePicUrl = "";
    _fetchUserDetails();
    _fetchPropertyCounts();
  }

  Future<void> _fetchUserDetails() async {
    final String apiUrl =
        "$baseUrl/api/dalali/get_user_details.php?userId=${widget.userId}";
    const String imageUrl = "$baseUrl/images/users/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              profilePicUrl =
                  imageUrl + (responseData['data']['profile_picture'] ?? '');
              username = responseData['data']['name'] ?? 'Unknown User';
            });
          }
        } else {
          debugPrint("Error: ${responseData['message']}");
        }
      } else {
        debugPrint(
            "Error: Failed to load user details (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _fetchPropertyCounts() async {
    try {
      final properties = await _fetchPropertiesWithImages();
      setState(() {
        rentCount = properties.where((p) => p['status'] == 'Rent').length;
        saleCount = properties.where((p) => p['status'] == 'Sold').length;
        forRent = properties.where((p) => p['status'] == 'For Rent').length;
        forSale = properties.where((p) => p['status'] == 'For Sale').length;
        totalProperties = rentCount + saleCount + forRent + forSale;
        print(rentCount);
        print(saleCount);
        print(forRent);
        print(forSale);
        print(totalProperties);
      });
    } catch (e) {
      print("Error fetching property counts: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPropertiesWithImages() async {
    try {
      final allProperties =
          await ApiService().fetchPropertiesForUser(userId: widget.userId);

      final groupedProperties = <String, List<UserProperty>>{};
      for (final property in allProperties) {
        groupedProperties
            .putIfAbsent(property.propertyId, () => [])
            .add(property);
      }

      return groupedProperties.entries.map((entry) {
        final properties = entry.value;
        final firstProperty = properties.first;
        return {
          'property': firstProperty,
          'images': properties.map((p) => p.propertyImage).toList(),
          'status': firstProperty.status,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              username,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            elevation: 0,
            actions: const [
              // IconButton(
              //   icon: const Icon(
              //     Icons.add_box_outlined,
              //     color: Colors.black,
              //   ),
              //   onPressed: () => print("Add"),
              // ),
              // IconButton(
              //   icon: const Icon(
              //     Icons.menu,
              //     color: Colors.black,
              //   ),
              //   onPressed: () => print("Menu"),
              // )
            ],
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    profileHeaderWidget(context, username, profilePicUrl,
                        rentCount, saleCount, totalProperties),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[400],
                  indicatorWeight: 1,
                  indicatorColor: Colors.black,
                  tabs: [
                    const Tab(
                      icon: Icon(
                        Icons.grid_on_sharp,
                        color: Colors.black,
                      ),
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/icons/igtv.png',
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/icons/reels.png',
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Gallery(userId: widget.userId),
                    const Igtv(),
                    const Reels(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kao_app/models/lodge.dart';
import 'package:kao_app/models/motel.dart';
import 'package:kao_app/models/property_media.dart';
import 'package:kao_app/models/user_property.dart';
import 'package:kao_app/views/user/accommodation_room_list.dart';
import 'package:kao_app/widgets/cards/simple_accomodation_card.dart';
import '../../models/hostel.dart';
import '../../models/hotel.dart';

class SimpleHotelCard extends StatelessWidget {
  final Hotel hotel;

  const SimpleHotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return SimpleAccommodationCard(
      accommodation: hotel,
      roomListPage: () => AccommodationRoomList(
        accommodationId: hotel.id.toString(), 
        accommodationName: hotel.name,
        accommodationType: 'hotel',
      ),
    );
  }
}


class SimpleMotelCard extends StatelessWidget {
  final Motel motel;

  const SimpleMotelCard({super.key, required this.motel});

  @override
  Widget build(BuildContext context) {
    return SimpleAccommodationCard(
      accommodation: motel,
      roomListPage: () => AccommodationRoomList(
        accommodationId: motel.id.toString(), 
        accommodationName: motel.name, 
        accommodationType: 'motel'
      ),
    );
  }
}


class SimpleHostelCard extends StatelessWidget {
  final Hostel hostel;

  const SimpleHostelCard({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return SimpleAccommodationCard(
      accommodation: hostel,
      roomListPage: () => AccommodationRoomList(
        accommodationId: hostel.id.toString(), 
        accommodationName: hostel.name, 
        accommodationType: 'hostel'
      ),
    );
  }
}


class SimpleLodgeCard extends StatelessWidget {
  final Lodge lodge;

  const SimpleLodgeCard({super.key, required this.lodge});

  @override
  Widget build(BuildContext context) {
    return SimpleAccommodationCard(
      accommodation: lodge,
      roomListPage: () => AccommodationRoomList(
        accommodationId: lodge.id.toString(), 
        accommodationName: lodge.name, 
        accommodationType: 'lodge'
      ),
    );
  }
}

class SimplePropertyCard extends StatelessWidget {
  final UserProperty property;
  final PropertyMedia propertyMedia;

  const SimplePropertyCard({super.key, required this.property, required this.propertyMedia});

  @override
  Widget build(BuildContext context) {
    return SimplePropertyAccommodationCard(
      accommodation: property,
      imager: propertyMedia,
      roomListPage: () => AccommodationRoomList(
        accommodationId: property.propertyId, 
        accommodationName: property.title, 
        accommodationType: 'property'
      ),
    );
  }
}

